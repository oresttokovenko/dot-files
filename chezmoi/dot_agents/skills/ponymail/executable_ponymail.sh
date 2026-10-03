#!/usr/bin/env bash
# ponymail.sh — CLI helper for Apache Pony Mail (lists.apache.org).
# Usage:
#   ponymail.sh lists <domain> [days]            Discover lists with recent activity
#   ponymail.sh threads <list> <domain> [days]   Thread digest, top 100 by activity (default 30d)
#   ponymail.sh thread <mid-or-tid>              One thread: starter body + reply outline
#   ponymail.sh email <mid>                      One email body
#   ponymail.sh mbox <list> <domain> [date]      Export mbox (date: YYYY-M or lte=30d)
set -euo pipefail

BASE="${PONYMAIL_BASE:-https://lists.apache.org}"

die() { echo "ponymail: $*" >&2; exit 1; }
need() { [ -n "${2:-}" ] || die "$1 requires an argument"; }

TMPFILES=()
trap '[ ${#TMPFILES[@]} -eq 0 ] || rm -f "${TMPFILES[@]}"' EXIT

tf() {
  local f
  f=$(mktemp "${TMPDIR:-/tmp}/ponymail.XXXXXX")
  TMPFILES+=("$f")
  printf '%s' "$f"
}

# rows <file> <perl-expression-per-row>
rows() { perl -Mutf8 -CS -0777 -ne "use JSON::PP; my \$d=JSON::PP->new->decode(\$_); $2" "$1"; }

cmd_lists() {
  [ $# -ge 1 ] || die "lists <domain> [days]"
  local domain="$1" days="${2:-30}"
  local f; f=$(tf)
  xh -b "$BASE/api/stream.json" list=='*' domain=="$domain" \
    mode==threads d=="gte=${days}d" quant==100 -o "$f"
  rows "$f" 'my %l; for my $r (@{$d->{rows}//[]}) { my $id=$r->{starter}{list}//""; $l{$id}++ }
    print "$_ ($l{$_})\n" for sort keys %l'
}

cmd_threads() {
  [ $# -ge 2 ] || die "threads <list> <domain> [days]"
  local list="$1" domain="$2" days="${3:-30}"
  local f; f=$(tf)
  xh -b "$BASE/api/stream.json" list=="$list" domain=="$domain" \
    mode==threads sort==activity d=="gte=${days}d" quant==100 page==0 -o "$f"
  rows "$f" 'my $now=time(); for my $r (@{$d->{rows}//[]}) {
    my $age=int(($now-($r->{last_epoch}//0))/86400);
    my $s=$r->{starter}//{};
    printf "%3sd  %3s repl  %2s parts  %s\n  by %s\n  https://lists.apache.org/thread/%s\n",
      $age, ($r->{replies}//0), ($r->{participants}//0),
      ($r->{subject}//"?"), ($s->{from}//"?"), ($r->{tid}//"")
  }'
}

cmd_thread() {
  need "thread <mid-or-tid>" "${1:-}"
  local f; f=$(tf)
  xh -b "$BASE/api/thread.json" id=="$1" -o "$f"
  perl -Mutf8 -CS -0777 -ne '
    use JSON::PP; my $d = JSON::PP->new->decode($_);
    my $t = $d->{thread} // {};
    print "Subject: ", ($t->{subject} // "?"), "\nFrom: ", ($t->{from} // "?"), "\n\n";
    print "--- BODY ---\n", substr(($t->{body} // ""), 0, 4000), "\n";
    my $top = $t->{children} // [];
    sub walk {
      my ($n, $dep) = @_;
      printf "%s%s  %s\n", ("  " x $dep), ($n->{from} // "?"), ($n->{subject} // "?");
      walk($_, $dep + 1) for @{ $n->{children} // [] };
    }
    if (@$top) { print "--- REPLIES ---\n"; walk($_, 0) for @$top; }
  ' "$f"
}

cmd_email() {
  need "email <mid>" "${1:-}"
  local f; f=$(tf)
  xh -b "$BASE/api/email.json" id=="$1" -o "$f"
  perl -Mutf8 -CS -0777 -ne 'use JSON::PP; my $d=JSON::PP->new->decode($_);
    print "Subject: ", ($d->{subject}//"?"), "\nFrom: ", ($d->{from_raw}//"?"), "\n\n";
    print ($d->{body}//""), "\n";' "$f"
}

cmd_mbox() {
  [ $# -ge 2 ] || die "mbox <list> <domain> [date]"
  local list="$1" domain="$2" d="${3:-lte=30d}"
  xh -b "$BASE/api/mbox.json" list=="$list" domain=="$domain" d=="$d"
}

case "${1:-}" in
  lists)   shift; cmd_lists "$@" ;;
  threads) shift; cmd_threads "$@" ;;
  thread)  shift; cmd_thread "$@" ;;
  email)   shift; cmd_email "$@" ;;
  mbox)    shift; cmd_mbox "$@" ;;
  *) die "usage: ponymail.sh {lists|threads|thread|email|mbox} ..." ;;
esac
