---
name: aa-models
description: Look up LLM benchmarks, pricing, and speed from Artificial Analysis (AA) via their API — Intelligence Index, Coding Index, GPQA, HLE, SciCode, Terminal-Bench, tok/s, $/1M tokens. Use when comparing or choosing models ("how does X compare to Y", "which model is cheaper/faster", "AA data for <model>") or when the user mentions Artificial Analysis.
---

# Artificial Analysis (model benchmarks)

Fetches AA's LLM leaderboard data. Auth: `X-API-Key` header, key in
`ARTIFICIAL_ANALYSIS_API_KEY` (~/.zshenv). Fetch with `xh` (`curl` is blocked);
parse with `perl -MJSON::PP`.

## Endpoint

```
GET https://artificialanalysis.ai/api/v2/language/models/free   # Free tier
GET https://artificialanalysis.ai/api/v2/language/models        # Pro tier, 403 on Free
```

The legacy `/api/v2/data/llms/models` route returns `410 Gone` (retired
2026-11-04). Envelope: `{tier, intelligence_index_version, pagination, data:[...]}`.
Paginated at 200/page — walk `?page=N&page_size=200` until `pagination.has_more`
is false (4 pages, ~750 models). No single-model endpoint; filter by `slug`.

```bash
for p in 1 2 3 4; do
  xh -b GET "https://artificialanalysis.ai/api/v2/language/models/free?page=$p&page_size=200" \
    X-API-Key:"$ARTIFICIAL_ANALYSIS_API_KEY" -o /tmp/aa_p$p.json
done
perl -MJSON::PP -0777 -ne 'my $d=JSON::PP->new->decode($_);
  for my $m (@{$d->{data}}) { next unless ($m->{slug}//"") =~ /glm|qwen/;
    printf "%-28s int=%-5s %stok/s ttfa=%s %s\n", $m->{slug},
      ($m->{evaluations}{artificial_analysis_intelligence_index}//"null"),
      ($m->{performance_v3}{mean_output_tokens_per_second}//"null"),
      ($m->{performance_v3}{mean_time_to_first_answer_token_seconds}//"null"), $m->{name} }' \
  /tmp/aa_p*.json
```

## Per-model record

`slug`, `name`, `model_creator.name`, `release_date`, `pricing`
(`price_1m_input_tokens`, `price_1m_output_tokens`, `price_1m_cache_hit_tokens` —
$/1M; the old blended field is gone), `performance` (`median_*`), `performance_v3`
(`mean_*` of the same, the current methodology), and `evaluations`.

Three caveats from the 2026 schema:

- `artificial_analysis_coding_index` and `artificial_analysis_agentic_index` are
  **always null** — AA no longer publishes them. On the Free tier the six
  Capability Indexes and per-eval scores (gpqa, hle, scicode, terminalbench, …)
  are absent too; only `artificial_analysis_intelligence_index` (v5.x) survives.
- `performance` returns null from 2026-12-10; prefer `performance_v3`. The two
  disagree sharply on TTFA for reasoning models (median vs mean over a long
  tail) — quote output tok/s, which agrees, and say which field any TTFA came from.
- Cost fields named `artificial_analysis_*_index_cost` are null on Free.

`null` = not benchmarked, not zero.

## Slug conventions

- Dots become dashes: GLM 5.3 → `glm-5-3`, Qwen 3.8 → `qwen3-8` (no dot at all).
- Bare slug = current flagship reasoning variant. `-low` = low reasoning, `-non-reasoning`
  = off, `-flash`/`-turbo`/`-highspeed` = fast tiers.
- Checkpoint suffixes (`-0803`, `-0902`) are older builds; the bare slug tracks the
  newest build but its `name` still shows which checkpoint it is (e.g.
  "Qwen3.8 Max (0902)"). For "model X vs Y" comparisons, say which checkpoint the
  numbers belong to.

## Output

For comparisons, print a markdown table covering Intelligence Index, output tok/s,
time to first answer, and $/1M in-out. State the release dates, checkpoint names,
and the index version, then a one-line takeaway. When models differ only by
thinking level, note that the bare slug is the flagship reasoning tier and that
dropping a level rarely buys latency — the reasoning is often short anyway.

## Watch for deprecation

On failure, read the `link` rel=deprecation response header and
`https://artificialanalysis.ai/data-api/migrate-v2-data` for the successor, then
update this file. Do NOT use `api.artificialanalysis.ai` — that host is dead
(Vercel DEPLOYMENT_NOT_FOUND). `/api/data/v1/*` is next: `410 Gone` from
2026-12-16 (see `/data-api/migrate-v1`).

Rate limits: Free 100 requests/24h window, Pro 500, shared per organisation.
Headers `X-RateLimit-{Limit,Remaining,Reset}`; a `429` carries `Retry-After`.
