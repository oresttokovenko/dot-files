// Blocks sed/awk in agent bash calls, points the model at perl one-liners.
// Perl is a complete superset of both (substitution, line addressing, field
// splits, in-place editing, full PCRE).
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// sed/awk almost always appear mid-pipeline (cat x | awk '{print $2}'), so a
// first-token match like the xh guard would miss most usage. Instead, split on
// pipeline/shell boundaries and check the executed program of each segment.
// ponytail: segment split only — `bash -lc "sed ..."` or `xargs sed` slip
// through; add deeper shell parsing if that matters.
function executedPrograms(command: string): string[] {
	return command
		.split(/\|\||&&|\||;|\$\(|`|\(/)
		.map((segment) => {
			const first = segment.trim().split(/\s+/)[0] ?? "";
			return first.replace(/^.*\//, ""); // strip path prefix
		})
		.filter(Boolean);
}

const REASON =
	"Blocked: sed/awk are not allowed here. Use perl one-liners instead: " +
	"`perl -pe 's/old/new/g'` substitutes, " +
	"`perl -ne 'print if 100..200'` selects a line range, " +
	"`perl -lane 'print $F[1]'` extracts fields (awk-style; whitespace split by " +
	"default, add -F: for another separator), " +
	"`perl -i -pe 's/old/new/' file` edits in place.";

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event) => {
		if (event.toolName !== "bash") return undefined;
		const command = String(event.input?.command ?? "").trim();
		const blocked = executedPrograms(command).some((p) =>
			["sed", "awk", "gawk", "mawk"].includes(p),
		);
		if (!blocked) return undefined;
		return { block: true, reason: REASON };
	});
}
