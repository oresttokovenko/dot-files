/**
 * model-failover: virtual models under the `failover` provider. Each routes to an
 * opencode-go model and, when that subscription's usage limit kills a request,
 * switches this conversation to its zai counterpart.
 *
 * Load: user extensions dir (this file). pi-subagents children load ambient
 * extensions, so agent overrides can pin `model: "failover/<id>"` and inherit the
 * same routing.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const VM_PROVIDER = "failover";
const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"] as const;

// Quota detection for tripping the failover. pi-ai surfaces provider errors to
// these hooks only as text, composed differently per adapter:
// openai-completions → `${status}: ${json-body}`; the anthropic SDK folds the
// body into error.message (e.g. `429 - {"type":"error","error":{...}}`). Find
// the embedded JSON object wherever it sits, then match the one error that
// means the opencode-go Go subscription limit is exhausted:
// {"type":"GoUsageLimitError"} flat (openai route) or inside the
// {"type":"error","error":{...}} envelope (anthropic route). Limitation: a
// body followed by appended text (pi-ai appends `\n${rawMetadata}` for
// OpenRouter-style bodies) makes JSON.parse fail — acceptable because
// opencode-go bodies carry no metadata.raw (verified from session logs).
function isQuotaError(text: string): boolean {
  const json = /\{.*\}/.exec(text)?.[0];
  if (!json) return false;
  try {
    const parsed = JSON.parse(json);
    return parsed?.type === "GoUsageLimitError" || parsed?.error?.type === "GoUsageLimitError";
  } catch {
    return false;
  }
}

type Target = { provider: string; id: string };
type RouteState = { failover?: boolean };

type Spec = {
  /** Virtual model id: `failover/<id>`. */
  id: string;
  name: string;
  primary: Target;
  /** Keep inside one capability tier of the primary. */
  fallback: Target;
  contextWindow: number;
  maxTokens: number;
};

const SPECS: Spec[] = [
  {
    id: "deepseek-flash",
    name: "DeepSeek V4.1 Flash → GLM-5.3-Flash",
    primary: { provider: "opencode-go", id: "deepseek-v4.1-flash" },
    fallback: { provider: "zai", id: "glm-5.3-flash" },
    contextWindow: 1_000_000,
    maxTokens: 384_000,
  },
  {
    id: "glm",
    name: "GLM-5.3 → GLM-5.3",
    primary: { provider: "opencode-go", id: "glm-5.3" },
    fallback: { provider: "zai", id: "glm-5.3" },
    contextWindow: 1_000_000,
    maxTokens: 131_072,
  },
  {
    id: "qwen-max",
    name: "Qwen3.8 Max → GLM-5.3",
    primary: { provider: "opencode-go", id: "qwen3.8-max" },
    fallback: { provider: "zai", id: "glm-5.3" },
    contextWindow: 1_000_000,
    maxTokens: 131_072,
  },
  {
    id: "glm-flash",
    name: "GLM-5.3-Flash → GLM-5.3-Flash",
    primary: { provider: "opencode-go", id: "glm-5.3-flash" },
    fallback: { provider: "zai", id: "glm-5.3-flash" },
    contextWindow: 1_000_000,
    maxTokens: 131_072,
  },
];

export default function (pi: ExtensionAPI) {
  // Per virtual model: tripped = spending the fallback now, inUse = routed this
  // process, so the settle hook only acts on conversations that use a virtual model.
  const tripped = new Set<string>();
  const inUse = new Set<string>();

  pi.on("model_select", (event) => {
    if (event.model.provider !== VM_PROVIDER) inUse.clear();
  });

  for (const spec of SPECS) {
    pi.registerVirtualModel<RouteState>({
      provider: VM_PROVIDER,
      id: spec.id,
      name: spec.name,
      thinkingLevels: [...THINKING_LEVELS],
      contextWindow: spec.contextWindow,
      maxTokens: spec.maxTokens,
      route(request, ctx) {
        inUse.add(spec.id);
        const find = (target: Target) => ctx.modelRegistry.find(target.provider, target.id);

        // A retried request whose failure looks like a quota error: switch now.
        const failedError = request.failed?.message?.errorMessage ?? "";
        const failOnRetry = request.reason === "retry" && isQuotaError(failedError);
        if (process.env.MF_DEBUG)
          console.error(
            `[MF] ${spec.id} reason=${request.reason} failOnRetry=${failOnRetry} tripped=${tripped.has(spec.id)}`,
          );
        if (failOnRetry) tripped.add(spec.id);

        const useFallback = tripped.has(spec.id) || request.state?.failover === true;

        // Keep continuations/retries sticky on the model that served the turn
        // (prompt cache + thinking signatures), unless we must break away.
        if (!failOnRetry && request.reason !== "user" && request.reason !== "direct") {
          const sticky = request.failed?.model ?? request.previous?.model;
          if (sticky && (!useFallback || sticky.provider !== spec.primary.provider)) {
            return {
              model: sticky,
              thinkingLevel: request.failed?.thinkingLevel ?? request.previous?.thinkingLevel ?? request.thinkingLevel,
            };
          }
        }

        const target = useFallback ? spec.fallback : spec.primary;
        const model = find(target);
        if (!model) {
          // Registry gap: degrade to the other side rather than failing the request.
          const alt = find(useFallback ? spec.primary : spec.fallback);
          if (alt) return { model: alt, thinkingLevel: request.thinkingLevel };
          throw new Error(`model-failover: no physical model found for ${target.provider}/${target.id}`);
        }

        // Return state only when it changes (pi stores any returned object).
        const nextState: RouteState | undefined =
          (request.state?.failover ?? false) !== useFallback ? { failover: useFallback } : undefined;
        return { model, thinkingLevel: request.thinkingLevel, state: nextState };
      },
    });
  }

  // Core does not auto-retry quota errors, so route() never sees them as
  // "retry" requests. Detect the terminal error at settle time, trip the
  // router, and continue the run once — the next request routes to zai.
  pi.on("agent_before_settle", async (event) => {
    if (event.outcome !== "error" || inUse.size === 0) return;

    const pool = [...(event.context?.pendingMessages ?? []), ...(event.context?.contextMessages ?? [])];
    const failed = [...pool]
      .reverse()
      .find((m) => m.role === "assistant" && (m as { stopReason?: string }).stopReason === "error") as
      | { errorMessage?: string; provider?: string; model?: string }
      | undefined;
    if (!failed || !isQuotaError(failed.errorMessage ?? "")) return;

    // Assistant messages name the physical model, so the failure identifies its route.
    const spec = SPECS.find(
      (s) => s.primary.provider === failed.provider && s.primary.id === failed.model && !tripped.has(s.id),
    );
    if (!spec) return;

    tripped.add(spec.id);
    pi.appendEntry("model-failover", {
      from: `${failed.provider}/${failed.model}`,
      to: `${spec.fallback.provider}/${spec.fallback.id}`,
      at: new Date().toISOString(),
      error: failed.errorMessage,
    });
    // Prefer continuing the same run; after a terminal provider error the
    // boundary has no runnable context, so re-trigger via a follow-up turn.
    if (event.context?.canContinue) return { continue: true };
    pi.sendMessage(
      {
        customType: "model-failover",
        content:
          "The previous provider hit a usage limit (quota error). Answer the user's pending request now.",
        display: true,
        details: { failover: `${failed.provider}/${failed.model} -> ${spec.fallback.provider}/${spec.fallback.id}` },
      },
      { triggerTurn: true },
    );
  });

  pi.registerCommand("failover", {
    description: "Show or reset model-failover state (/failover reset)",
    handler: async (args) => {
      if (args.trim() === "reset") {
        tripped.clear();
        console.log("model-failover: tripped flags cleared (branch state resets on next user turn via route()).");
        return;
      }
      console.log(
        `model-failover: virtual models under ${VM_PROVIDER}/\n` +
          SPECS.map(
            (s) =>
              `  ${s.id.padEnd(16)} ${s.primary.provider}/${s.primary.id} -> ${s.fallback.provider}/${s.fallback.id}` +
              (tripped.has(s.id) ? "  [TRIPPED: using fallback]" : ""),
          ).join("\n"),
      );
    },
  });
}
