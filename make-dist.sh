#!/bin/bash
# Frostbyte: build archive
cd "$(dirname "$0")"
OUT="${1:-$HOME}/frostbyte-1.0.tar.gz"
tar --exclude=.git -czf "$OUT" -C "$(dirname "$PWD")" "$(basename "$PWD")"
ls -lh "$OUT"
