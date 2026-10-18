/**
 * model-failover: virtual model "failover/glm-flash" that routes to
 * opencode-go/glm-5.3-flash and, when that provider's usage limit kills a
 * request, switches this conversation to zai/glm-5.3-flash.
 *
 * Load: user extensions dir (this file). Also eligible as a pi-subagents
 * requiredExtensions entry so child sessions get the same model.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const VM = { provider: "failover", id: "glm-flash" };
const PRIMARY = { provider: "opencode-go", id: "glm-5.3-flash" };
const FALLBACK = { provider: "zai", id: "glm-5.3-flash" };

// Mirrors pi core's NON_RETRYABLE_PROVIDER_LIMIT_ERROR_PATTERN: terminal
// quota/billing errors that core deliberately will not retry.
const QUOTA_ERROR =
  /GoUsageLimitError|FreeUsageLimitError|Monthly usage limit reached|available balance|insufficient_quota|out of budget|quota exceeded|billing|subscription_sharing_usage_limit_exceeded/i;

type RouteState = { failover?: boolean };

export default function (pi: ExtensionAPI) {
  let tripped = false;
  // Event-handler ctx lacks getModel in some modes; track selection instead.
  let usingVM = false;
  pi.on("model_select", (event) => {
    // Reset when the user moves off the virtual model; route() re-arms it.
    if (event.model.provider !== VM.provider || event.model.id !== VM.id) usingVM = false;
  });

  pi.registerVirtualModel<RouteState>({
    provider: VM.provider,
    id: VM.id,
    name: "GLM Flash failover (opencode-go → zai)",
    thinkingLevels: ["off", "low", "medium", "high", "max"],
    route(request, ctx) {
      usingVM = true;
      const find = (p: string, id: string) => ctx.modelRegistry.find(p, id);

      // A retried request whose failure looks like a quota error: switch now.
      const failedError = request.failed?.message?.errorMessage ?? "";
      const failOnRetry = request.reason === "retry" && QUOTA_ERROR.test(failedError);
      if (process.env.MF_DEBUG) console.error("[MF] route reason=" + request.reason + " failOnRetry=" + failOnRetry + " tripped=" + tripped);
      if (failOnRetry) tripped = true;

      const useFallback = tripped || request.state?.failover === true;

      // Keep continuations/retries sticky on the model that served the turn
      // (prompt cache + thinking signatures), unless we must break away.
      if (!failOnRetry && request.reason !== "user" && request.reason !== "direct") {
        const sticky = request.failed?.model ?? request.previous?.model;
        if (sticky && (!useFallback || sticky.provider !== PRIMARY.provider)) {
          return {
            model: sticky,
            thinkingLevel: request.failed?.thinkingLevel ?? request.previous?.thinkingLevel ?? request.thinkingLevel,
          };
        }
      }

      const target = useFallback ? FALLBACK : PRIMARY;
      const model = find(target.provider, target.id);
      if (!model) {
        // Registry gap: degrade to the other side rather than failing the request.
        const alt = find(useFallback ? PRIMARY.provider : FALLBACK.provider, useFallback ? PRIMARY.id : FALLBACK.id);
        if (alt) return { model: alt, thinkingLevel: request.thinkingLevel };
        throw new Error(`model-failover: no physical model found for ${target.provider}/${target.id}`);
      }

      // Return state only when it changes (pi stores any returned object).
      const nextState: RouteState | undefined =
        (request.state?.failover ?? false) !== useFallback ? { failover: useFallback } : undefined;
      return { model, thinkingLevel: request.thinkingLevel, state: nextState };
    },
  });

  // Core does not auto-retry quota errors, so route() never sees them as
  // "retry" requests. Detect the terminal error at settle time, trip the
  // router, and continue the run once — the next request routes to zai.
  pi.on("agent_before_settle", async (event) => {
    if (event.outcome !== "error" || tripped || !usingVM) return;

    const pool = [...(event.context?.pendingMessages ?? []), ...(event.context?.contextMessages ?? [])];
    const failed = [...pool]
      .reverse()
      .find((m) => m.role === "assistant" && (m as { stopReason?: string }).stopReason === "error") as
      | { errorMessage?: string; provider?: string; model?: string }
      | undefined;
    if (!failed || !QUOTA_ERROR.test(failed.errorMessage ?? "")) return;
    if (failed.provider !== PRIMARY.provider) return;

    tripped = true;
    pi.appendEntry("model-failover", {
      from: `${failed.provider}/${failed.model}`,
      to: `${FALLBACK.provider}/${FALLBACK.id}`,
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
        details: { failover: `${failed.provider} -> ${FALLBACK.provider}` },
      },
      { triggerTurn: true },
    );
  });

  pi.registerCommand("failover", {
    description: "Show or reset model-failover state (/failover reset)",
    handler: async (args) => {
      if (args.trim() === "reset") {
        tripped = false;
        console.log("model-failover: tripped flag cleared (branch state resets on next user turn via route()).");
        return;
      }
      console.log(
        `model-failover: virtual model ${VM.provider}/${VM.id}\n` +
          `  primary : ${PRIMARY.provider}/${PRIMARY.id}\n` +
          `  fallback: ${FALLBACK.provider}/${FALLBACK.id}\n` +
          `  status  : ${tripped ? "TRIPPED — routing to fallback for new turns" : "healthy — routing to primary"}`,
      );
    },
  });
}
