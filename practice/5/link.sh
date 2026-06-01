#!/usr/bin/env bash
set -euo pipefail
ld -m elf_i386 practice5.o -o practice5
chmod +x practice5
