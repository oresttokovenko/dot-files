---
name: ponymail
description: Search, read, and summarize Apache mailing-list archives at lists.apache.org (Pony Mail) for any ASF project and any list. Use whenever someone asks what a project's community said or is discussing ("what's the latest on <project> dev", "dev@ digest", "was this discussed on the list"), needs the [DISCUSS]/[VOTE]/[RESULT] record behind an ASF decision, wants mailing-list evidence for a design question in a repo, or needs an archive export. Covers every apache.org domain, so never assume the project — and always pass a date window, because the default one silently hides everything older than a month.
---

# Apache mailing-list archives (Pony Mail)

lists.apache.org publishes every Apache project's public lists as JSON over plain unauthenticated GET requests:

```
https://lists.apache.org/api/<endpoint>.json?<parameters>
```

Each thread has a stable human link: `https://lists.apache.org/thread/<starter-message-id>`.

Two behaviors make this archive easy to misread, and both fail silently — no error status, just a plausible answer:

**The default window is the last ~30 days.** If no date parameter is given, only threads with activity in the last month come back. Nearly every wrong "it was never discussed" conclusion is this. Always pass a window, and state which window you used.

**A malformed date parameter is dropped, not rejected.** The request still succeeds and quietly falls back to that one-month default. Quote characters inside the value are the usual cause, because shell quoting puts them there. When results look too recent or too few, fix the date parameter before doubting the archive.

The archive itself is complete; months and years of history are there for the asking.

## What each endpoint gives you

| Endpoint | What you get |
|---|---|
| `stream.json` | Search or browse. `mode=threads` returns one row per thread: subject, starter, start and last-activity times, reply count, participant count. `mode=emails` returns individual messages with bodies. This is the workhorse. |
| `stats.json` | Counts only: emails hit, months spanned, participants. Cheap way to size a search before paging it. |
| `thread.json` | One thread as a nested tree: subject, starter, and every reply's author and message id, nested under `children`. Reply *bodies* are not included. |
| `email.json` | One message in full: body, headers, participants, permalinks. |
| `mbox.json` | The result set as a raw mbox for offline or bulk processing. |
| `source.json` | One message's raw RFC-822 source. |
| `pminfo.json` | Site-wide totals across all Apache lists. |

Before building anything non-trivial, know the identifier convention: the `tid` that `stream.json` returns *is* the starter message's `mid`. `thread.json` and `email.json` both take a `mid`, so one value addresses the thread or the message. Full parameters and response fields: [references/endpoints.md](references/endpoints.md).

## Fetch with what the machine has

This is a URL and a JSON response, so nothing here depends on a particular client or parser. Use whatever HTTP and JSON tooling the environment already provides — a configured fetch tool, or e.g. curl, xh, wget, python, jq, node — and adapt rather than install anything. Two things matter more than the choice of tool: send parameter values unquoted (`&d=2026-7`, never `d='2026-7'`), and URL-encode `+`, `|` and spaces when they show up inside `q` or a `dfr=…|dto=…` range.

## Workflow

1. Pin `list` and `domain`. List ids are short (`dev`, `users`, `commits`, `issues`); domains are `<project>.apache.org`. A mismatched pair returns zero hits instead of an error, so confirm both before concluding anything is absent.
2. Choose the window deliberately: `date=2026-7` for a month, `d=2026-7` for the same thing through the generic date parameter, `d=dfr=2026-7-1|dto=2026-9-30` for a day range. Relative `lte=` spans work; `gte=` spans do not filter at all, so don't rely on them.
3. Enumerate either by searching inside the window with `q=` (stemmed free text over subjects and bodies; multiple words are ANDed, `+` forces a term, `-` excludes one, and `"quoted phrases"` match in order) or by listing a month and scanning subjects. Search terms should include the project's old and new names, abbreviations, and the noun the question implies, not only its exact wording.
4. Read what actually answers the question: `thread.json` for shape and who said what, then `email.json` for the individual bodies you need. Pulling a whole thread when a reply outline answers it wastes the reader's attention.
5. Answer with permalinks, the list and domain, the window you searched, and the archive's own timestamps. When the question is "is anyone working on X", report both the threads you found and the windows that came back empty — one empty window is not evidence of absence.

## Reference files

- [references/endpoints.md](references/endpoints.md) — every parameter, every response field, and which date forms actually filter.
- [references/recipes.md](references/recipes.md) — task recipes: all threads about a topic across months, a recent digest, reading one thread end to end, Message-ID lookup, mbox export, list discovery, and "was this ever discussed".
- [references/field-notes.md](references/field-notes.md) — measured quirks with numbers, dates and evidence, plus how to re-check them if behavior looks different.
