#!/bin/bash

set -e

nasm -f win64 os.asm -o os.obj

lld-link \
  /subsystem:efi_application \
  /entry:_e \
  /machine:x64 \
  os.obj \
  /out:BOOTX64.EFI

echo ok
