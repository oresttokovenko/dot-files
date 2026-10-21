# Pony Mail endpoints and parameters

Base: `https://lists.apache.org/api/<endpoint>.json`. Every call is a GET with query parameters, no authentication, JSON response (`mbox.json` returns an mbox stream instead). Invalid list/domain pairs and empty result sets are not errors: they return `total: 0` with `firstYear: 1970` placeholders.

## Contents

- [Search parameters](#search-parameters)
- [Date parameters](#date-parameters)
- [stream.json](#streamjson)
- [stats.json](#statsjson)
- [thread.json](#threadjson)
- [email.json](#emailjson)
- [mbox.json](#mboxjson)
- [source.json](#sourcejson)
- [pminfo.json](#pminfojson)
- [Identifiers and permalinks](#identifiers-and-permalinks)
- [Encoding](#encoding)

## Search parameters

| Parameter | Endpoints | Meaning |
|---|---|---|
| `list` | all | List id without domain, e.g. `dev`. `*` wildcards the list for discovery. |
| `domain` | all | Project domain, e.g. `iceberg.apache.org`. |
| `q` | stream, stats, mbox | Free text over subjects and bodies. Words are ANDed; `+term` is required, `-term` excluded, `"a phrase"` matches in order. Stemmed, so `semantic` also matches `semantics`. |
| `mode` | stream | `threads` (default) or `emails`. |
| `sort` | stream | `activity` (default, newest activity first), `upvotes`, `replies`; threads mode only. |
| `quant` | stream, stats, mbox | Page size, 1–100, default 25. |
| `page` | stream | 0-based page number. |
| `date`, `d` | stream, stats, mbox | Date window. See below — this is the parameter that decides whether your answer is right. |
| `header_from`, `header_subject`, `header_to`, `header_body`, `header_messageid` | stream | Phrase match on a single header. Rarely needed; `q` covers most cases. |

Threads are not always one row per discussion. When a reply lands without usable threading headers, the archive keeps it as its own thread with a `Re:` subject and a new `tid` — so a topic sweep can return several rows for one argument. Merge by normalised subject (strip `Re:`/`RE:`/`[list]` prefixes) as well as by `tid`.

The response envelope for `stream.json` and `stats.json` carries the search metadata along with the rows: `total` (matching items), `page`, `quant`, `mode`, `sort`, `list`, `domain`, `searchParams`, `firstYear`/`firstMonth`, `lastYear`/`lastMonth`, `active_months`, `participants`, `no_threads`.

## Date parameters

`d` is the general form; `date` is the special case for one month. What works, measured against a live list:

| Value | Filters? |
|---|---|
| `d=2026-7` or `d=2026-07` | yes — that calendar month |
| `date=2026-7` | yes — same thing |
| `d=dfr=2026-07-01\|dto=2026-07-31` | yes — inclusive day range |
| `d=lte=10d`, `d=lte=2M` | yes — last N days or months, relative to now |
| `dfrom=30&dto=1` | yes — starting 30 days ago, spanning 1 day (`dto` is a duration from `dfrom`, not an end date) |
| `d=gte=1d`, `d=gte=7d`, `d=gte=30d`, `d=gte=1M` | **no** — ignored, results come back unfiltered |
| anything malformed, e.g. `d='2026-7'` with quotes | **no** — silently ignored, falls back to the default window |

Units are `d`, `w`, `M`, `y`. Omitting a date parameter is equivalent to roughly `d=lte=1M`: about one month of activity. See [field-notes.md](field-notes.md) for the measurements behind this table.

## stream.json

The workhorse: search or browse, one page at a time.

```
stream.json?list=dev&domain=polaris.apache.org&mode=threads&d=2026-7&quant=100&page=0
```

`mode=threads` row fields:

| Field | Meaning |
|---|---|
| `tid` | Thread id — equal to the starter message's `mid`. Use it in `thread.json`, `email.json`, and the `/thread/<tid>` permalink. |
| `subject` | Thread subject (a reply-started thread keeps the `Re:` prefix). |
| `epoch`, `last_epoch` | Thread start and last activity, Unix seconds. |
| `replies`, `participants`, `upvotes` | Activity counts. |
| `last_from` | Author of the most recent message. |
| `starter` | Object with `mid`, `id`, `subject`, `from`, `epoch`, `list`, and a `body` snippet. |
| `children` | Array (the thread's message ids as the index knows them). |

`mode=emails` rows are flat messages with `mid`, `id`, `subject`, `from`, `epoch`, `list`, and the full `body`.

Sorting defaults to activity, so page 0 of a wide window gives you the busiest threads rather than the oldest. Page with `page=1,2,…` while `page * quant < total`.

## stats.json

Same search parameters, no rows. Returns `hits` (matching emails), `emails` (a per-month array), `participants`, `active_months`, `no_threads`. One request tells you whether a topic has 4 messages or 4000, which decides whether to page `stream.json` at all.

## thread.json

```
thread.json?id=<starter mid>
```

Returns `{ thread: { mid, subject, from, epoch, list, children: [ … ] } }`. Each node has `mid`, `from`, `subject`, `epoch`, `irt`, `list`, `message-id` and its own nested `children`.

Critical detail: **only the root node carries a body** (the starter message). Every reply node returns an empty `body`, so the tree gives you structure, authors, times and message ids, while reply text requires `email.json?id=<that node's mid>`.

## email.json

```
email.json?id=<mid>
```

Returns the whole message: `subject`, `from`, `from_raw` (the only unellipsized address), `to`, `cc`, `date`, `epoch`, `body` (with quoted replies inline), `body_short`, `message-id`, `in-reply-to`, `references`, `list`, `list_raw` (the `<dev.project.apache.org>` form), `permalinks`, `attachments`, `size`.

## mbox.json

Same parameters as `stream.json`; returns the result set as an mbox stream (RFC-822, `From ` separator lines). Use it when you want to grep or process many messages locally instead of making one request per message. A month plus a search term is a sane scope; whole years are large.

## source.json

```
source.json?id=<mid>
```

Raw RFC-822 of one message, headers intact. Use when you need the real `Message-ID`, `In-Reply-To`, `References`, or DKIM/archive headers rather than the parsed view.

## pminfo.json

No parameters. Site-wide stats across every Apache list: `hits`, `no_threads`, `no_active_lists`, `participants`. Useful for a sanity check that the service is up, not for project questions.

## Identifiers and permalinks

- `mid` — a message id, the value that `thread.json` and `email.json` accept, and what appears in `thread/<mid>` URLs.
- `tid` — in `stream.json` it is the starter's `mid`. Treat the two as interchangeable for addressing a thread.
- `id` — in `email.json` it echoes the `mid`. In `starter` objects it is the same value again.
- Permalink form: `https://lists.apache.org/thread/<tid>` (HTML, 200 for valid ids). Quote these in answers so a reader can verify you.

## Encoding

`q` and `d` values travel inside a query string. `dfr=…|dto=…` contains a pipe, and `q` may contain `+`/spaces; both need percent-encoding when the client doesn't do it for you (`%7C`, `%2B`, `%20`). Single quotes around a value are not encoding — they are characters, and for `d` they turn the whole parameter into something the server ignores.
