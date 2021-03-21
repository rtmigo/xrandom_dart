#!/bin/bash
set -e && cd "${0%/*}"

# creates a copy of the project in temporary directory
# and prepares the copy to be published

temp_pub_dir=$(mktemp -d -t pub-XXXXXXX)

echo "$temp_pub_dir"

rsync -Rrv ./ "$temp_pub_dir" \
  --exclude=".git" \
  --exclude="pubpub.sh" \
  --exclude="test/" \
  --exclude="todo.txt" \
  --exclude="benchmark/" \
  --exclude="reference/" \
  --exclude="README.md" \
  --exclude="analysis_options.yaml" \
  --exclude=".github" \
  --exclude="labuda/" \
  --exclude="draft/" \
  --exclude="experiments"

# removing everything before "\n# ", the first header
old_readme=$(cat README.md | tr '\n' '\r')
new_readme=$(echo "$old_readme" | perl -p0e 's|^.*?\r# |# \1|')
new_readme=$(echo "$new_readme" |  tr '\r' '\n')
#№new_readme=$(echo $old_readme | perl -p0e 's|^.*?\r# |# \1|' | tr '\r' '\n')
echo "$new_readme" > "$temp_pub_dir/README.md"

cd "$temp_pub_dir"
dartfmt -w .
#dart pub publish --dry-run
dart pub publish
#open "$temp_pub_dir"