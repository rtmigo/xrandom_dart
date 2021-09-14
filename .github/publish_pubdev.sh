#!/bin/bash -e

# Patching '.gitignore' for PubDev instead of GitHub
echo 'test/' >> .gitignore
echo '.github/' >> .gitignore
echo 'todo.txt' >> .gitignore
cat .gitignore

# Patching 'README.md' for PubDev instead of GitHub
# removing everything before "\n# ", the first header
readme_text=$(cat README.md | tr '\n' '\r')
readme_text=$(echo "$readme_text" | perl -p0e 's|^.*?\r# |# \1|')
readme_text=$(echo "$readme_text" | tr '\r' '\n')
echo "$readme_text" > README.md

# Install dependencies
dart pub get

# Reformat code
dart format .

# Analyze reformatted
dart analyze --fatal-infos

#- name: Unit-tests for reformatted code
#  run: dart test

# Publish package

pub publish --dry-run
