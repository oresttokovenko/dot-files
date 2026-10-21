# Field notes: measured behavior

Everything here was measured against the live API on 2026-10-21, mostly on `list=dev&domain=polaris.apache.org` (a list of ~841 threads). Numbers are here so that a future reader can tell whether the API still behaves this way, not as trivia.

The method for every date row: issue the same `stream.json` request with different `d` values and compare `total` and the spread of `last_epoch` (thread activity). A parameter that filters produces a smaller total and a narrower activity range than no parameter at all.

## The default window is one month

| Request | `total` | oldest activity |
|---|---|---|
| no `d` | 55 | 2026-09-21 |
| `d=lte=1M` | 55 | 2026-09-21 |

No date parameter behaves like "last month". That is why a keyword search without a window can come back with a handful of recent threads and look authoritative.

## A malformed date is dropped silently

| `d` value | `total` | activity range |
|---|---|---|
| `d=2026-7` | 58 | all July 2026 |
| `d=2026-07` | 58 | all July 2026 |
| `date=2026-7` | 58 | all July 2026 |
| `d=dfr=2026-07-01\|dto=2026-07-31` | 58 | all July 2026 |
| `d='2026-7'` (quotes reach the server) | 55 | Sep–Oct, i.e. the default |

The last row is the trap: identical intent, no error, and the answer silently becomes "the last month". Quoting is the usual culprit because shell wrappers add quotes that the date parser treats as part of the value.

## `gte=` spans do not filter; `lte=` does

| `d` value | `total` | oldest activity |
|---|---|---|
| `d=gte=1d` | 841 | 2026-08-03 |
| `d=gte=7d` | 838 | 2026-07-31 |
| `d=gte=30d` | 803 | 2026-07-08 |
| `d=gte=1M` | 803 | 2026-07-08 |
| `d=lte=10d` | 18 | 2026-10-12 |
| `d=lte=2M` | 84 | 2026-08-22 |
| `d=lte=1M` | 55 | 2026-09-21 |

`gte=` values land near the whole-list total with activity going back months, so they are being ignored rather than applied. `lte=` behaves as documented. `dfrom`/`dto` work but with a twist: `dfrom=30&dto=1` returned 10 threads with activity on 2026-09-21 and 09-22, i.e. `dto` is a *duration* measured from `dfrom`, not an end date.

## Search behavior

- `q` matches bodies, not just subjects: `q=Ossie&d=2026-7` returned 2 threads, including one whose subject never contains "Ossie", and `mbox.json?…&q=Ossie&d=2026-7` returned 21 messages.
- Quoting `q` is harmless — `q=semantic` and `q='semantic'` both matched (the analyzer ignores the punctuation). Quoting `d` is not.
- Search is stemmed: `semantics` and `semantic` return different counts but overlapping threads, so a single term is not always enough.

## Response shapes worth pinning down

- `thread.json` nodes: the **root** carries the starter's body (2,268 characters on a sample thread), every reply node returns an empty `body`. The tree gives `mid`, `from`, `subject`, `epoch`, `irt`, `message-id` and nested `children`; reply text needs `email.json?id=<mid>`.
- One discussion can occupy several `tid`s. A `q=Ossie` sweep over 2026-05…2026-10 on `dev@polaris.apache.org` returned separate threads for `[DISCUSS] Semantic Model REST API payload representation` and `Re: [DISCUSS] Semantic Model REST API payload representation`, and separately for the vote and its `Re:` thread. Merge by normalised subject as well as `tid`.
- Renames break keyword sweeps in one direction only: `q=Ossie` returns 0 hits for 2026-05, 23 for 2026-06, 21 for 2026-07, 4 for 2026-08, while the May threads exist under the old name. Sweep both names.
- The `tid` on a `stream.json` row equals the starter's `mid` — verified on two different threads, so one value addresses the thread (`thread.json`), the message (`email.json`), and the permalink (`/thread/<tid>`, HTTP 200).
- `from` is ellipsized (`di...@apache.org`); `from_raw` in `email.json` is the only complete address.
- An unknown `list`/`domain` combination returns `total: 0`, `firstYear: 1970`, and HTTP success — no error to catch.
- `stream.json` and `stats.json` share an envelope with `total`, `page`, `quant`, `mode`, `sort`, `list`, `domain`, `searchParams` and per-month activity metadata alongside `rows`.

## The failure this file exists for

A keyword search for `semantic` on `dev@polaris.apache.org` returned four threads, none about the project's semantic-model work, which looked like an indexing gap. The discussions were there all along — `q=semantic&d=2026-5` returns `[DISCUSS] Semantic Layer Support in Apache Polaris` and `q=semantic&d=2026-7` returns both the payload-representation thread and the specification vote thread. The searches were running against the one-month default because the date value arrived quoted.

## How to re-check when behavior looks wrong

Run the same query twice, once with a month (`d=2026-7`) and once with no date, and compare `total`. If both return the same number, the date parameter is not being applied — check the value for quotes or a broken `gte=` span. If a month query returns far fewer rows than the archive pages show for that month, treat the window as unverified and fall back to browsing month by month.
