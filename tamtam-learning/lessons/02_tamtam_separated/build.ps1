$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$src  = Join-Path $here "boot.asm"
$out  = Join-Path $here "boot.img"

nasm -f bin $src -o $out

$size = (Get-Item $out).Length
if ($size -ne 512) { throw "boot.img must be exactly 512 bytes, got $size" }

Write-Host "Built: $out ($size bytes)"
