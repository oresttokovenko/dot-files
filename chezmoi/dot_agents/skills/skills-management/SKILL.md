---
name: skills-management
description: >
  Classify, update, and manage the agent's installed skills across their three
  management origins (skills CLI, uv tool packages, local hand-made) plus the
  chezmoi backup layer. Use when installing, updating, auditing, or troubleshooting
  skills, when a skill is stale or drifted, when asked what manages a given skill,
  or before/after running skills update or uv tool upgrade.
---

# Skills Management — Three Origins + One Backup Layer

Skills live in `~/.agents/skills/`. Every skill belongs to exactly one of three
management origins, and `~/.agents` as a whole sits under chezmoi. Classify by
mechanism, never by name — skills come and go; the mechanisms do not.

## Classify a skill

Run in order; first match wins:

1. **Symlink?** (`readlink -f ~/.agents/skills/<name>`) — points into
   `~/.local/share/uv/tools/<package>/...` → **uv-tool-managed**. It ships inside
   a Python package and cannot be updated on its own.
2. **In the lockfile?** Check `~/.agents/.skill-lock.json` (JSON, key `skills`)
   for the directory name → **skills-CLI-managed**. Real directory, GitHub-sourced.
3. **Otherwise** (real directory, absent from lockfile) → **local**. Hand-made,
   hand-maintained.

Bulk-classify the whole directory:

```bash
perl -MJSON::PP -e '
  local $/; open F,"<",$ENV{HOME}."/.agents/.skill-lock.json"; my $j=decode_json(<F>);
  my %c;
  for my $d (glob "$ENV{HOME}/.agents/skills/*") {
    my ($n) = $d =~ m{/([^/]+)$};
    if (-l $d) { $c{"uv-tool"}++ }
    elsif (exists $j->{skills}{$n}) { $c{"skills-cli"}++ }
    else { $c{local}++; print "local: $n\n" }
  }
  print "$_: $c{$_}\n" for sort keys %c;
'
```

(Counts on 2026-10-17: 109 skills-cli, 40 uv-tool, 5 local. Expect the numbers
to move; expect the buckets to stay.)

## Update each origin

**skills-CLI origin** — the CLI is `skills` (also runnable as `npx skills`;
docs at skills.sh):

```bash
skills update -g -y        # update all global skills (skip scope + confirm prompts)
skills add <owner/repo>    # install
skills remove <name>       # remove
skills ls                  # list what the CLI knows
```

Updates overwrite files in place. Never hand-edit a skills-CLI skill expecting
edits to survive; fix-forward upstream or fork the source repo.

**uv-tool origin** — skills are package payload; upgrade the whole tool:

```bash
uv tool upgrade <package>   # e.g. the wiki/knowledge tooling package
uv tool list                # installed packages + versions
```

One upgrade can change many skills at once. Re-read any skill you loaded earlier
in the session before trusting your memory of its rules.

**local origin** — edit the files directly. No update mechanism exists; that is
the point. Keep local skills in this directory only if they are machine-specific
(or personal); anything generally useful should be published to a repo and
installed through the skills CLI.

## The chezmoi layer

`~/.agents` is under chezmoi: the lockfile, `AGENTS.md`, and the file contents
of skills-CLI skills are tracked. Consequences:

- After `skills update`, the changed files are **chezmoi drift** until re-added:
  `chezmoi re-add ~/.agents/skills` (or the project's usual sync workflow).
- uv-tool symlinks are package-owned and **not** chezmoi-tracked — nothing to
  re-add after `uv tool upgrade`.
- Local skills are tracked once re-added; a brand-new local skill directory is
  invisible to chezmoi until then.

## Recipes

- "Is skill X up to date?" → classify it; skills-CLI: `skills update -g -y` and
  read the per-skill output; uv-tool: `uv tool upgrade <package>` and read
  "Nothing to upgrade" vs the version line.
- "Where did this skill come from?" → classify, then for skills-CLI read its
  `source`/`sourceUrl` in the lockfile; for uv-tool `readlink` gives the package;
  for local, ask the user.
- "A skill's behavior changed after an update" → diff against chezmoi's copy:
  `chezmoi diff ~/.agents/skills/<name>`; the source dir has the previous version.
- "Audit everything at once" → run the bulk-classify one-liner, then update the
  two manager origins, then `chezmoi re-add` the drift.
