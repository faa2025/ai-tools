#!/bin/bash
# Loop through all .jpg files in the current directory
for file in *.jpg; do
  # Check if the file exists (skip the loop iteration if no .jpg file is found)
  [ -e "$file" ] || continue
  newname="no-train-$file"
  echo "Renaming '$file' to '$newname'"
  mv -- "$file" "$newname"
done
