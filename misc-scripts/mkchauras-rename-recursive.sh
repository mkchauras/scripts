#!/bin/bash

# Find all files starting with mchauras- recursively
find . -type f -name 'mukesh-*' | while read -r file; do
    dir=$(dirname "$file")
    base=$(basename "$file")

    # Replace only the first occurrence of "mchauras-" with "mkchauras-"
    #newbase="${base/mchauras-/mkchauras-}"
    newbase="${base/mukesh-/mkchauras-}"
    newpath="$dir/$newbase"

    echo "Renaming: $file -> $newpath"
    mv -- "$file" "$newpath"
done

