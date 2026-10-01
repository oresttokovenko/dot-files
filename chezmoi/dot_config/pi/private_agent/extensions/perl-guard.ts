// Blocks sed/awk in agent bash calls, points the model at perl one-liners.
// Perl is a complete superset of both (substitution, line addressing, field
// splits, in-place editing, full PCRE).
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

// Programs under these wrappers are still the wrapper's argument being executed.
const WRAPPERS = new Set(["sudo", "env", "nohup", "time", "nice", "command", "exec", "stdbuf"]);
// After these operators the next string token is an executed program.
const SEP_TRUE = new Set(["|", "||", "&&", ";", "&", "(", "<(", "{"]);
// After these the next string token is a redirect target, not a program.
const REDIRECTS = new Set([">", ">>", "<", "<&", ">&", "&>", "2>", "2>>", "<>"]);

function cleanToken(t: string): string {
	return t.replace(/^[\s`'"]+/, "").replace(/^.*\//, "");
}

function walk(tokens: unknown[], out: Set<string>): void {
	let expect = true; // next string token is an executed program
	let skipTarget = false; // next string token is a redirect target
	for (const tok of tokens) {
		if (typeof tok === "object" && tok !== null) {
			if ((tok as { comment?: string }).comment !== undefined) continue;
			const op = (tok as { op?: string }).op;
			if (op && SEP_TRUE.has(op)) expect = true;
			else if (op && REDIRECTS.has(op)) skipTarget = true;
			else if (op) expect = false; // ) } and friends
			continue;
		}
		const s = String(tok);
		for (const m of s.matchAll(/\$\(([^)]*)\)/g)) walk(shellParse(m[1]), out);
		if (skipTarget) {
			skipTarget = false;
			continue;
		}
		if (!expect) continue;
		if (/^[A-Za-z_][A-Za-z0-9_]*=/.test(s)) continue; // VAR=val prefix
		if (WRAPPERS.has(s)) continue;
		if (s.startsWith("-") || /^\d+$/.test(s)) continue; // flags/args before program
		out.add(cleanToken(s));
		expect = false;
	}
}

export function executedPrograms(command: string): string[] {
	const out = new Set<string>();
	// shell-quote does not model backticks or multi-line input; normalize both.
	for (const line of command.replace(/`([^`]*)`/g, "$($1)").split("\n")) {
		walk(shellParse(line), out);
	}
	return [...out];
}

const REASON =
	"Blocked: sed/awk are not allowed here. Use perl one-liners. " +
	"Run `perl -h` to check syntax.";

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event) => {
		if (event.toolName !== "bash") return undefined;
		const command = String(event.input?.command ?? "").trim();
		const blocked = executedPrograms(command).some((p) => BLOCKED.has(p));
		if (!blocked) return undefined;
		return { block: true, reason: REASON };
	});
}
