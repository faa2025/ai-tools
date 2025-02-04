#!/bin/bash
# Loop through all .jpg files in the current directory
for file in *.jpg; do
  # Check if the file exists (in case no .jpg files are found, the pattern is left as-is)
  [ -e "$file" ] || continue
  newname="yes-train-$file"
  echo "Renaming '$file' to '$newname'"
  mv -- "$file" "$newname"
done
