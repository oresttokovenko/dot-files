# Global agent instructions

## Text manipulation via bash

Use perl for all text manipulation in bash: stream substitution, line
selection, field extraction, in-place edits, and HTML/log/data extraction
scripts.

- Substitution: `perl -pe 's/old/new/g'` (slurp mode for whole-file work: `perl -0777 -pe ...`)
- Line ranges: `perl -ne 'print if 55..78'`
- Field extraction: `perl -lane 'print $F[1]'` (0-based; `-F:` sets the separator)
- In-place edit: `perl -i -pe 's/old/new/' file` (backup: `-i.bak`)
- Built-in function docs: `perldoc -T -f FUNC`; one-liner switch manual: `perldoc -T perlrun`
- Stdlib module lookup: `perl -MModule::CoreList -e 'print "$_\n" for sort keys
  %{$Module::CoreList::version{$]}}'` lists every module shipped with the
  running perl — pipe through `grep -i json` when unsure which module fits a
  task (JSON → JSON::PP, dates → Time::Piece). Check one directly with
  `perl -MJSON::PP -e1`. Module docs: `perldoc -T Module::Name`

`sed`, `awk`, `python`, `curl` and `wget` are blocked by tool guards. Use
perl instead of sed/awk/python and `xh` instead of curl/wget. Run
`perl -h` or `xh help` when unsure of syntax.
