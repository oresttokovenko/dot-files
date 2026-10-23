// Blocks sed/awk and inline python in agent bash calls, points the model at
// perl. Running real script files stays allowed: `python3 x.py`,
// `uv run x.py`, and `uv run python x.py` pass; `python -c`, `python -m`,
// and stdin/heredoc python (no script argument) are blocked. The guard is
// style enforcement, not a security boundary.
//
// Perl is a complete superset of sed and awk (substitution, line addressing,
// field splits, in-place editing, full PCRE) and replaces python for the
// inline data-extraction tasks agents generate in bash.
//
// shell-quote is already inside pi's own dependency tree (@anthropic-ai/
// sandbox-runtime uses it), so this adds no new supply-chain surface.
//
// Parsing uses shell-quote's quote-aware tokenizer: quoted operators stay
// inside string tokens (sed 's/a|b/c/' stays a single token), operators
// arrive as {op} objects, and $(...) exposes inner programs as tokens.
// Cost: ~2-5 µs per call (measured 1.7-5.3 µs across command shapes, 10k
// iterations each) — 0.01% of the child-process spawn each bash call pays;
// ~15 ms total across a 3,000-call session.
// Residual gaps by design: xargs, bash -lc "sed ...", find -exec, eval —
// deeper shell parsing only if that ever matters.
import * as shellQuoteParseModule from "shell-quote/parse";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// shell-quote is CommonJS (module.exports = the parse function), and the
// runtime's interop shape differs between loaders (esbuild namespaces, node
// ESM, plain require). Resolve the function from whichever shape is exposed —
// getting this wrong fails every bash call, not just blocked ones.
const parseModule = shellQuoteParseModule as {
	parse?: unknown;
	default?: unknown;
};
const shellParse: (cmd: string) => unknown[] =
	typeof parseModule.parse === "function"
		? (parseModule.parse as (cmd: string) => unknown[])
		: typeof parseModule.default === "function"
			? (parseModule.default as (cmd: string) => unknown[])
			: (shellQuoteParseModule as unknown as (cmd: string) => unknown[]);

const BLOCKED = new Set(["sed", "awk", "gawk", "mawk"]);

const isPython = (p: string) => p === "python" || p === "python3" || /^python3\.\d+$/.test(p);

// An invocation is allowed python only when it runs a script file, never
// inline code (`-c`), module execution (`-m`), or stdin (`-`, heredoc).
function pythonAllowed(args: string[]): boolean {
	if (args.some((a) => a === "-" || /^-[cm]/.test(a))) return false;
	return args.some((a) => a.endsWith(".py"));
}

// `uv run` follows the same rule for a python it launches; `uv run x.py`,
// `uv run --with pkg x.py`, and non-python `uv` subcommands all pass.
function uvAllowed(args: string[]): boolean {
	const runAt = args.indexOf("run");
	if (runAt === -1) return true;
	const positional = args.slice(runAt + 1).filter((a) => !a.startsWith("-"));
	if (positional.length > 0 && isPython(positional[0]!)) return pythonAllowed(positional.slice(1));
	return true;
}

// Programs under these wrappers are still the wrapper's argument being executed.
const WRAPPERS = new Set(["sudo", "env", "nohup", "time", "nice", "command", "exec", "stdbuf"]);
// After these operators the next string token is an executed program.
const SEP_TRUE = new Set(["|", "||", "&&", ";", "&", "(", "<(", "{"]);
// After these the next string token is a redirect target, not a program.
const REDIRECTS = new Set([">", ">>", "<", "<&", ">&", "&>", "2>", "2>>", "<>"]);

function cleanToken(t: string): string {
	return t.replace(/^[\s`'"]+/, "").replace(/^.*\//, "");
}

function walk(tokens: unknown[], programs: Set<string>, invocations: Invocation[]): void {
	let expect = true; // next string token is an executed program
	let skipTarget = false; // next string token is a redirect target
	let current: Invocation | null = null;
	for (const tok of tokens) {
		if (typeof tok === "object" && tok !== null) {
			if ((tok as { comment?: string }).comment !== undefined) continue;
			const op = (tok as { op?: string }).op;
			if (op && SEP_TRUE.has(op)) {
				expect = true;
				current = null;
			} else if (op && REDIRECTS.has(op)) skipTarget = true;
			else if (op) {
				expect = false;
				current = null;
			} // ) } and friends
			continue;
		}
		const s = String(tok);
		for (const m of s.matchAll(/\$\(([^)]*)\)/g)) walk(shellParse(m[1]), programs, invocations);
		if (skipTarget) {
			skipTarget = false;
			continue;
		}
		if (!expect) {
			if (current) current.args.push(s);
			continue;
		}
		if (/^[A-Za-z_][A-Za-z0-9_]*=/.test(s)) continue; // VAR=val prefix
		if (WRAPPERS.has(s)) continue;
		if (s.startsWith("-") || /^\d+$/.test(s)) continue; // flags/args before program
		const prog = cleanToken(s);
		programs.add(prog);
		current = { prog, args: [] };
		invocations.push(current);
		expect = false;
	}
}

export type Invocation = { prog: string; args: string[] };

// shell-quote does not model backticks or multi-line input; normalize both.
const commandLines = (command: string): string[] =>
	command.replace(/`([^`]*)`/g, "$($1)").split("\n");

export function commandInvocations(command: string): Invocation[] {
	const programs = new Set<string>();
	const invocations: Invocation[] = [];
	for (const line of commandLines(command)) walk(shellParse(line), programs, invocations);
	return invocations;
}

export function executedPrograms(command: string): string[] {
	const programs = new Set<string>();
	for (const line of commandLines(command)) walk(shellParse(line), programs, []);
	return [...programs];
}

const REASON =
	"Blocked: sed/awk are not allowed here; use perl for text manipulation. " +
	"Python is allowed only to run script files (python3 x.py, uv run x.py), " +
	"not for inline text processing.";

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event) => {
		if (event.toolName !== "bash") return undefined;
		const command = String(event.input?.command ?? "").trim();
		const blocked = commandInvocations(command).some(
			(inv) =>
				BLOCKED.has(inv.prog) ||
				(isPython(inv.prog) && !pythonAllowed(inv.args)) ||
				(inv.prog === "uv" && !uvAllowed(inv.args)),
		);
		if (!blocked) return undefined;
		return { block: true, reason: REASON };
	});
}
