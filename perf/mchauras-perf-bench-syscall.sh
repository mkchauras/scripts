#!/usr/bin/env bash
#
# Run perf bench syscall all multiple times and output averages as a Markdown table
#

RUNS=${1:-10}
TMP_FILE=$(mktemp)

set -e

for i in $(seq 1 "$RUNS"); do
    echo "Running Iteration no. $i" >&2
    LC_ALL=C perf bench syscall all
done > "$TMP_FILE"

echo
echo "| Syscall | Avg usecs/op | Avg ops/sec |"
echo "|---------|--------------|-------------|"

awk '
/^# Running syscall\// {
    split($3, a, "/")
    name = a[2]
}
/usecs\/op/ {
    usecs[name] += $1
    ucnt[name]++
}
/ops\/sec/ {
    ops[name] += $1
    ocnt[name]++
}
END {
    for (n in usecs) {
        printf "| %-7s | %12.6f | %11.0f |\n",
               n,
               usecs[n] / ucnt[n],
               ops[n] / ocnt[n]
    }
}' "$TMP_FILE"

rm -f "$TMP_FILE"

