// Blocks curl/wget in agent bash calls, points the model at xh.
// Install: this dir is auto-loaded by pi (user extensions directory).
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Matches only when curl/wget is the executed program: optional
// sudo/env/nohup/time/nice prefixes, optional path prefix, word boundary.
// ponytail: first-token match only — `bash -lc "curl ..."` or `foo | curl`
// slip through. Extend to a full-command scan if that matters.
const BLOCKED =
	/^\s*(?:(?:env|sudo|nohup|time|nice)\s+)*(?:\S*\/)?(?:curl|wget)\b/;

const REASON =
	"Blocked: curl/wget are not allowed here. Use xh (HTTPie-style syntax), " +
	"which is installed. Examples:\n" +
	"- xh GET https://example.com/api\n" +
	"- xh POST https://example.com/api key:value-header field=value\n" +
	"- xh DELETE https://example.com/api/1 Authorization:Bearer+xyz\n" +
	"- echo '{\"json\":\"body\"}' | xh POST https://example.com/api --raw @-\n" +
	"Query params use key==value, headers use key:value. Run `xh --help` for details.";

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event) => {
		if (event.toolName !== "bash") return undefined;
		const command = String(event.input?.command ?? "").trim();
		if (!BLOCKED.test(command)) return undefined;
		return { block: true, reason: REASON };
	});
}
