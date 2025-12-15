$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$img  = Join-Path $here "boot.img"
if (!(Test-Path $img)) { throw "boot.img not found. Run build.ps1 first." }

qemu-system-i386 `
  -drive format=raw,file=$img  `
  -m 16 `
  -no-reboot `
  -no-shutdown
