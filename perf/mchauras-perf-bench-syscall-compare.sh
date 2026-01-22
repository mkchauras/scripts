#!/usr/bin/env bash
#
# Compare two perf bench syscall Markdown tables
# Output separate tables for latency and throughput
#

BASE=$1
NEW=$2

if [ $# -ne 2 ]; then
    echo "Usage: $0 baseline test"
    exit 1
fi

########################
# Latency table
########################

echo
echo "### Latency (usecs/op)"
echo
echo "| Syscall | Base | test | Δ % |"
echo "|---------|------|------|-----|"

awk -F'|' '
$2 ~ /Syscall/ || $2 ~ /^-+/ || NF < 4 { next }

NR==FNR {
    gsub(/^[ \t]+|[ \t]+$/, "", $2)
    gsub(/^[ \t]+|[ \t]+$/, "", $3)
    base_u[$2] = $3
    next
}

{
    gsub(/^[ \t]+|[ \t]+$/, "", $2)
    gsub(/^[ \t]+|[ \t]+$/, "", $3)

    n = $2
    new_u = $3

    d = ((new_u - base_u[n]) / base_u[n]) * 100

    printf "| %-7s | %6.6f | %6.6f | %+5.2f |\n",
           n, base_u[n], new_u, d
}
' "$BASE" "$NEW" | sort

########################
# Throughput table
########################

echo
echo "### Throughput (ops/sec)"
echo
echo "| Syscall | Base | New | Δ % |"
echo "|---------|------|-----|-----|"

awk -F'|' '
$2 ~ /Syscall/ || $2 ~ /^-+/ || NF < 4 { next }

NR==FNR {
    gsub(/^[ \t]+|[ \t]+$/, "", $2)
    gsub(/^[ \t]+|[ \t]+$/, "", $4)
    base_o[$2] = $4
    next
}

{
    gsub(/^[ \t]+|[ \t]+$/, "", $2)
    gsub(/^[ \t]+|[ \t]+$/, "", $4)

    n = $2
    new_o = $4

    d = ((new_o - base_o[n]) / base_o[n]) * 100

    printf "| %-7s | %10.0f | %10.0f | %+6.2f |\n",
           n, base_o[n], new_o, d
}
' "$BASE" "$NEW" | sort

