# exclude-manager.ps1 - maintain a project's README exclude list "_exclude.txt".
# Drag a PROJECT FOLDER onto 设置不列入.bat to run. Excluded pages stay ONLINE, just not listed in the README.
# NOTE: all echoed/written strings are ASCII on purpose (PS 5.1 mangles Chinese string
# literals in a no-BOM .ps1). File names are read from disk, so they display fine.
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$folder = $Args | Where-Object { $_ } | Select-Object -First 1
if (-not $folder -or -not (Test-Path $folder -PathType Container)) {
  Write-Host "Please DRAG A PROJECT FOLDER onto this .bat (a folder path is required)."
  return
}
$pages = Get-ChildItem $folder -Filter *.html -ErrorAction SilentlyContinue | Sort-Object Name
if (-not $pages) { Write-Host ("No .html found in: " + $folder); return }

$ef = Join-Path $folder "_exclude.txt"
$excl = @()
if (Test-Path $ef) { $excl = @([IO.File]::ReadAllLines($ef) | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }) }

Write-Host ""
Write-Host ("Project: " + (Split-Path $folder -Leaf))
Write-Host "Pages ( [x] = excluded from README, but still online ):"
for ($i = 0; $i -lt $pages.Count; $i++) {
  $mark = if ($excl -contains $pages[$i].Name) { "[x]" } else { "[ ]" }
  Write-Host ("  {0}. {1} {2}" -f ($i + 1), $mark, $pages[$i].Name)
}
Write-Host ""
$sel = Read-Host "Enter numbers to TOGGLE (e.g. 1,3), or just Enter to keep unchanged"

if ($sel -and $sel.Trim()) {
  $nums = $sel -split '[,\s]+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
  foreach ($n in $nums) {
    if ($n -ge 1 -and $n -le $pages.Count) {
      $name = $pages[$n - 1].Name
      if ($excl -contains $name) { $excl = @($excl | Where-Object { $_ -ne $name }) }
      else { $excl += $name }
    }
  }
  $header  = "# Pages excluded from the README link list (still deployed, reachable by direct URL)."
  $header2 = "# One filename per line. Edited by the exclude .bat. Re-run the publish .bat to apply."
  $out = @($header, $header2) + @($excl | Sort-Object -Unique)
  [IO.File]::WriteAllLines($ef, $out, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host ""
  Write-Host ("Saved _exclude.txt. Excluded now: " + (@($excl | Sort-Object -Unique) -join ", "))
  Write-Host "==> Now run the publish tool (the HTML publish .bat) to apply it to the README."
} else {
  Write-Host "No change."
}
