#!/bin/bash

set -e

[[ -d ./source ]] || echo "./source directory not exists" >&2

mkdir -p ./binary

for file in ./source/*.json; do
    name=$(basename $file .json)
    sing-box rule-set compile --output ./binary/$name.srs $file
done
