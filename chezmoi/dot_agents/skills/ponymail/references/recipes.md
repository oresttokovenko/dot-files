# Task recipes

Each recipe is a URL shape plus what to read from the response. Substitute the HTTP and JSON tools the machine has; the requests are plain GETs. Keep the date window explicit in every request, and report it when you answer.

Parameter shapes and response fields: [endpoints.md](endpoints.md).

## Contents

- [Digest of a project's current discussions](#digest-of-a-projects-current-discussions)
- [Every thread about a topic](#every-thread-about-a-topic)
- [Read one thread end to end](#read-one-thread-end-to-end)
- [Was this ever discussed?](#was-this-ever-discussed)
- [Find the decision behind a change](#find-the-decision-behind-a-change)
- [Find a message from a link or Message-ID](#find-a-message-from-a-link-or-message-id)
- [Which lists does a project have](#which-lists-does-a-project-have)
- [Export for offline work](#export-for-offline-work)

## Digest of a project's current discussions

```
stream.json?list=dev&domain=<project>.apache.org&mode=threads&sort=activity&d=lte=1M&quant=100
```

Read `subject`, `replies`, `participants`, `last_epoch`, `starter.body` for each row. Separate design discussions from release and process traffic (`[VOTE]`, `[RESULT]`, `[ANNOUNCE]`, board reports). Quote the archive's dates, not the day you ran the query, and say the digest covers the last month.

`lte=1M` is what the API does anyway when you pass no date — passing it makes the window explicit and reviewable.

## Every thread about a topic

A single search only sees one window, so sweep month by month and merge:

```
stream.json?list=dev&domain=<project>.apache.org&mode=threads&q=<topic>&d=2026-5&quant=100
stream.json?list=dev&domain=<project>.apache.org&mode=threads&q=<topic>&d=2026-6
… through the range you care about
```

Why month by month rather than one range: the working date forms are a single month, a `dfr=…|dto=…` range, and `lte=` relative spans. Ranges work, but month-stepping gives you per-month counts, which is exactly what you need to say "nothing in June, 8 threads in July" instead of an unsupported "nothing found".

Search terms matter more than the query mechanics. Use the project's current name, its former name, the acronym, and the noun the question implies. A renamed project is the classic miss, and the numbers show it: on `dev@polaris.apache.org`, `q=Ossie` returns 0 hits for 2026-05, 23 for 2026-06, 21 for 2026-07 and 4 for 2026-08, because Open Semantic Interchange was renamed Apache Ossie in late June. Searching only the new name would have declared the whole preceding discussion nonexistent. When a name changed, sweep both names and merge.

Deduplicate by `tid` **and** by normalised subject. The archive splits one discussion into several threads whenever a reply arrives without usable threading headers: those rows keep a `Re:` subject and get their own `tid`. A sweep for "Ossie" over `dev@polaris.apache.org` returned four rows for two arguments — `[DISCUSS] Semantic Model REST API payload representation` plus a `Re:` thread of the same name, and `[VOTE] Accept OSI Semantic Model API Specification` plus a `Re:` thread — and a tid-only merge would have reported each of them twice.

## Read one thread end to end

1. `thread.json?id=<tid>` — the tree: subject, starter, and each reply's author, time and `mid`. This alone answers "who said what, when".
2. `email.json?id=<mid>` — only for the messages whose text you actually need. Bodies are absent from the tree by design, so there is no cheaper way to get wording.

When summarizing, attribute statements to the person and the date (`from_raw`, `date`), and skip quoted reply text — `body` includes it, and it repeats the message you already read.

## Was this ever discussed?

Sweep the whole plausible range, then report the negative explicitly with the windows you covered:

```
stats.json?list=dev&domain=<project>.apache.org&q=<topic>&d=2025-1
```

`hits` from `stats.json` is cheaper than paging `stream.json` when you only need existence. Sweep one or more years, test the name variants, and prefer `users`/`dev`/`commits` over a single list if you don't know which one carries the traffic — feature discussion is usually on `dev`, but release and CVE notices land elsewhere.

Never answer "it wasn't discussed" from a default-window search: that window is one month, and it is the single most common way to be wrong here.

## Find the decision behind a change

Design decisions usually leave a numbered trail: `[DISCUSS]` → `[VOTE]` → `[RESULT]`, sometimes with the PR or issue number in the subject. Search the window around the code change:

```
stream.json?list=dev&domain=<project>.apache.org&mode=threads&q=<PR number or feature name>&d=<month of the change>
```

Read the `[RESULT]` message for the binding outcome and the `[DISCUSS]` thread for the reasoning that the merge commit doesn't record. If a vote was cancelled, the archive shows it — that distinction changes how much weight the thread's "consensus" deserves, so check for `[CANCELLED]` or a later follow-up before describing something as agreed.

## Find a message from a link or Message-ID

- A `https://lists.apache.org/thread/<id>` link: the id is the starter `mid`. `thread.json?id=<id>` opens the thread; `email.json?id=<id>` opens that message.
- A raw `Message-ID:` header: `email.json?id=<message-id>` generally resolves it, but this is the one lookup that occasionally needs the list scope, so if it fails, search the subject with `d=<month from the Date header>` instead.

## Which lists does a project have

```
stream.json?list=*&domain=<project>.apache.org&mode=threads&d=lte=1M&quant=100
```

Each row's `starter.list` (or `list`) names the list. Aggregating those names gives the project's active lists — typically `dev`, `users`, `commits`, `issues`, sometimes `private` (which the public archive does not serve). Scope the domain; a wildcard domain scans every Apache project and is slow.

## Export for offline work

```
mbox.json?list=dev&domain=<project>.apache.org&d=2026-7&q=<topic>
```

You get RFC-822 messages, one per `From ` separator, which any local text processing can handle. Scope it to a month plus a term; a full year of a busy list is tens of megabytes and tells you less than the targeted query.

`source.json?id=<mid>` is the single-message equivalent when you need exact headers for one message.
