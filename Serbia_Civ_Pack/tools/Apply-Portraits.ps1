$ErrorActionPreference = "Stop"
$Art = Join-Path $PSScriptRoot "..\Art"
$Data = Join-Path $PSScriptRoot "portrait_data"
if (-not (Test-Path $Art)) { New-Item -ItemType Directory -Path $Art | Out-Null }
if (-not (Test-Path $Data)) { throw "Missing tools\portrait_data folder" }
Write-Host "Installing leader portraits from portrait_data..."
$count = 0
Get-ChildItem (Join-Path $Data "*.b64") | ForEach-Object {
  $out = Join-Path $Art ($_.BaseName)
  [IO.File]::WriteAllBytes($out, [Convert]::FromBase64String((Get-Content $_.FullName -Raw)))
  Write-Host "  wrote $($_.BaseName)"
  $count++
}
Write-Host "Done ($count files)."
Write-Host "Fully quit Civ 6, then start a NEW game."
