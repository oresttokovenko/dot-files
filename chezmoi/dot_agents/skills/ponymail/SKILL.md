---
name: ponymail
description: Manual skill — fetch and summarize mailing-list discussions for any Apache project from Apache Pony Mail (lists.apache.org). Use when the user explicitly asks to pull dev@ discussions, latest threads, mailing list digest, or export an mbox for an Apache project (e.g. "what's being discussed on iceberg dev", "ponymail digest for nuttx", "export lucene dev mbox").
---

# Pony Mail (Apache mailing lists)

Read Apache project mailing list archives at `https://lists.apache.org` (Pony Mail "Foal").
Works for any Apache project. Never hardcode a project: the two required parameters
are `list` (e.g. `dev`) and `domain` (e.g. `iceberg.apache.org`); ask the user when
either is unclear.

Fetch with `xh` (`curl`/`wget` are blocked). Parse JSON with `perl -MJSON::PP`.
API spec: `https://lists.apache.org/openapi.yaml`.

A CLI helper lives next to this file — use it first, raw `xh` calls for anything
it doesn't cover:

```bash
S=~/.agents/skills/ponymail/ponymail.sh
$S lists  <domain> [days]           # which lists have recent activity
$S threads <list> <domain> [days]   # one line per thread: age/replies/participants/permalink
$S thread <mid>                     # one thread: starter body + reply outline
$S email <mid>                      # one email body
$S mbox <list> <domain> [date]      # raw mbox of a result set
```

`threads` fetches one page: the top 100 threads by activity. For more, page the raw
endpoint (`page=1,2,...`).

## Endpoints

All accept GET query params.

| Endpoint | Params | Returns |
|---|---|---|
| `GET /api/stream.json` | `list`, `domain`, `mode=threads\|emails`, `sort=activity\|upvotes\|replies`, `page` (0-based), `quant` (1-100, default 25), `d` (date: `2025-9`, `gte=1M`, `lte=10d`, `dfr=2025-9-1|dto=2025-10-1`), `q` (free text, `+required -excluded`), `header_from/subject/to/body/messageid` | One page of rows + stats. `mode=threads` rows: `tid`, `subject`, `epoch` (started), `last_epoch` (last activity), `replies`, `participants`, `starter` (with body snippet), `children`. `mode=emails` rows: flat `subject`, `from`, `id`, `epoch`, `body` |
| `GET /api/email.json` | `id=<mid or doc id>` | One email: `subject`, `from_raw` (full address), `message-id`, `body`, `epoch`, `list` |
| `GET /api/thread.json` | `id=<mid>` | Thread as nested JSON; replies under `thread.children` (recursively). `listid` is only needed to resolve a raw `Message-ID` header (see `openapi.yaml`) |
| `GET /api/mbox.json` | same SearchRequest params as `stream.json` | Raw mbox of the result set (for full offline processing) |
| `GET /api/source.json` | `id=<mid>` | Raw RFC-822 source of one email |
| `GET /api/stats.json` | same SearchRequest params | Aggregates: `hits`, `active_months`, `participants`, `list_stats` |
| `GET /api/atom` | `list`, `domain`, `quant` | Atom feed of latest threads (RSS readers) |
| `GET /api/pminfo.json` | — | Site-wide activity stats |

Base URL: `https://lists.apache.org`. Permalinks: `https://lists.apache.org/thread/<tid>`.

## Workflow

### 1. List discovery (which lists exist on a domain?)

Wildcards work on both parts. Threads mode rows carry the list under `starter.list`:

```bash
xh -b 'https://lists.apache.org/api/stream.json' \
  list=='*' domain=='iceberg.apache.org' mode==threads d=='gte=1M' quant==100 \
  -o /tmp/ponymail.json
perl -0777 -ne 'use JSON::PP; my $d=JSON::PP->new->decode($_);
  my %l; for my $r (@{$d->{rows}//[]}) { my $id=$r->{starter}{list}//""; $l{$id}++ }
  print "$_ ($l{$_})\n" for sort keys %l' /tmp/ponymail.json
```

Typical Apache projects have `dev@`, `users@`, `commits@`, `issues@` lists.

### 2. Latest discussions digest (the default ask)

```bash
xh -b 'https://lists.apache.org/api/stream.json' \
  list=='dev' domain=='iceberg.apache.org' mode==threads sort==activity \
  quant==100 page==0 -o /tmp/ponymail.json
```

- `total` counts result rows on all pages; page through with `page=1,2,...` if needed.
- One row per thread even when `starter.subject` says `Re:` (reply-starter threads).
- Filter fresh activity client-side: `last_epoch` is the last-activity unix time.
- Read the thread starter's `body` for what each discussion is about; fetch individual
  emails with `email.json?id=<mid>` when a thread deserves depth.

Digest format: group into "active design discussions" (newest `last_epoch` first, one
line each: subject, who started, what it decides, reply count) and "releases/ops"
([VOTE]/[RESULT]/[ANNOUNCE]/CVE). Link permalinks. Dates: state the archive date you
summarized up to.

### 3. Read one thread fully

```bash
~/.agents/skills/ponymail/ponymail.sh thread <mid>   # starter body + reply outline
xh -b "https://lists.apache.org/api/email.json?id=<mid>" -o /tmp/email.json
```

`thread.json` nests all replies under `thread.children` when you need the full tree.
Quoted replies are inside `body`; use `source.json` to inspect raw headers.

### 4. Export mbox for bulk/offline analysis

```bash
xh -b 'https://lists.apache.org/api/mbox.json' \
  list=='dev' domain=='iceberg.apache.org' d=='2025-9' -o /tmp/dev.mbox
```

## Quirks

- Addresses are ellipsized (`di...@apache.org`) in stream/email `from`; only
  `email.json` `from_raw` has the full address. Body text can contain quoted replies.
- Shell-quote `d` values containing `|` (e.g. `d=='dfr=2025-9-1|dto=2025-10-1'`).
- Wildcards (`list=dev&domain=*`) scan all domains — slow; scope to one domain.
- Empty result: `total: 0` with `firstYear: 1970` placeholders is normal, not an error.
- Unknown list/domain does NOT error; it returns zero hits.
