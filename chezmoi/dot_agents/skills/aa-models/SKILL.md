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
GET https://artificialanalysis.ai/api/v2/data/llms/models
```

Returns `{data: [...]}` (~700 models). There is NO single-model endpoint — filter
client-side by `slug`. Send a browser `User-Agent` header if you get 405s.

```bash
xh -b GET 'https://artificialanalysis.ai/api/v2/data/llms/models' \
  X-API-Key:"$ARTIFICIAL_ANALYSIS_API_KEY" -o /tmp/aa.json
perl -MJSON::PP -0777 -ne 'my $d=JSON::PP->new->decode($_);
  for my $m (@{$d->{data}}) { my $s=$m->{slug}//""; print "$s  $m->{name}\n" if $s =~ /glm|qwen/ }' /tmp/aa.json
```

## Per-model record

`slug`, `name`, `model_creator.name`, `release_date`, `pricing`
(`price_1m_input_tokens`, `price_1m_output_tokens`, `price_1m_blended_3_to_1` — all
$/1M tokens, blended is 3:1 in:out), `median_output_tokens_per_second`,
`median_time_to_first_token_seconds`, `median_time_to_first_answer_token`, and
`evaluations`: `artificial_analysis_intelligence_index`, `artificial_analysis_coding_index`,
`gpqa`, `hle`, `lcr`, `scicode`, `tau_banking`, `terminalbench_v2_1`, `terminalbench_v4_0`,
... (fraction 0-1 or index; `null` = not benchmarked, not zero).

## Slug conventions

- Dots become dashes: GLM 5.3 → `glm-5-3`, Qwen 3.8 → `qwen3-8` (no dot at all).
- Bare slug = current flagship reasoning variant. `-low` = low reasoning, `-non-reasoning`
  = off, `-flash`/`-turbo`/`-highspeed` = fast tiers.
- Checkpoint suffixes (`-0803`, `-0902`) are older builds; the bare slug tracks the
  newest build but its `name` still shows which checkpoint it is (e.g.
  "Qwen3.8 Max (0902)"). For "model X vs Y" comparisons, say which checkpoint the
  numbers belong to.

## Output

For comparisons, print a markdown table (metric | model A | model B) covering
Intelligence Index, Coding Index, the headline evals with non-null values, output
tok/s, time to first answer, and blended price. State the release dates and
checkpoint names, then a one-line takeaway.

## Watch for deprecation

The v2 data route was deprecated (sunset 2026-11-04). On failure, read the `link`
rel=deprecation response header and `https://artificialanalysis.ai/data-api/migrate-v2-data`
for the successor, then update this file. Do NOT use `api.artificialanalysis.ai` —
that host is dead (Vercel DEPLOYMENT_NOT_FOUND).
