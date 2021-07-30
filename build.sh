#! /usr/bin/env bash
# Made to work on Mac version of `stat`

rm -f readme.md

printf "# Testing Notes - Table of Contents\n\n" >> readme.md

for mdFile in **/*.md; do
  title=$(sed -n "s/^# \(.*\)/\1/p" "$mdFile")
  updated=$(stat -f "%Sm" "$mdFile")
  printf "[%s](%s) - updated %s\n\n" "$title" "$mdFile" "$updated" >> readme.md
done