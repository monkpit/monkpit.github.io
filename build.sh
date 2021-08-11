#! /usr/bin/env bash
# Made to work on Mac version of `stat`

rm -f readme.md

cat readme.header.md >> readme.md

mdFiles=$(find ./**/* -name \*.md)

for mdFile in $mdFiles; do
  title=$(sed -n "s/^# \(.*\)/\1/p" "$mdFile")
  updated=$(stat -f "%Sm" "$mdFile")
  printf "* [%s](%s) - updated %s\n" "$title" "$mdFile" "$updated" >> readme.md
done

cat readme.footer.md >> readme.md