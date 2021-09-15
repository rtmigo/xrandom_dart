#!/bin/bash -e


# Patching 'README.md' for PubDev instead of GitHub
# removing everything before "\n# ", the first header
cp README.md README.md.bak
readme_text=$(cat README.md | tr '\n' '\r')
readme_text=$(echo "$readme_text" | perl -p0e 's|^.*?\r# |# \1|')
readme_text=$(echo "$readme_text" | tr '\r' '\n')
echo "$readme_text" > README.md

cat README.md
