#!/usr/bin/env bash
set -euo pipefail
ld -m elf_i386 practice11.o -o practice11
chmod +x practice11
