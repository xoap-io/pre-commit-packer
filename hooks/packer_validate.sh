#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

if [ -z "$(command -v packer)" ]; then
  echo "packer is required"
  exit 1
fi

error=0
current_dir="$(pwd)"
for file in "$@"; do
  file_path=$(readlink -f "$file")
  directory=$(dirname "$file_path")
  cd "$directory"
  var_file=$(find "$directory" -name '*.pkrvars.hcl')
  packer_param=""
  if [ -z "$var_file" ]; then
    echo "No .pkrvars.hcl file found in $directory"
  else
    packer_param="-var-file=$(basename "$var_file")"
  fi

  if ! packer validate "$packer_param" "$(basename "$file")" ; then
    error=1
    echo
    echo "Failed path: $file"
    echo "packer validate "$packer_param" "$(basename "$file")" failed"
    echo "Working directory was: $directory"
    echo "================================"
  fi
  cd "$current_dir"
done

if [[ $error -ne 0 ]]; then
  exit 1
fi
