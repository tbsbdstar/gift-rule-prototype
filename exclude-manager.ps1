# exclude-manager.ps1 —— 维护某项目的 README 排除名单 _exclude.txt
# 拖一个项目文件夹到 设置不列入.bat 即可运行。被排除的页面仍会在线，只是不列进 README。
# 说明：本脚本提示语一律用 ASCII（PS5.1 读无 BOM 脚本时中文字面量会乱码）；文件名从磁盘读取，显示中文正常。
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$folder = $Args | Where-Object { $_ } | Select-Object -First 1
if (-not $folder -or -not (Test-Path $folder -PathType Container)) {
  Write-Host "Please DRAG A PROJECT FOLDER onto 设置不列入.bat (a folder path is required)."
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
  $header = "# Pages excluded from the README link list (still deployed & reachable by direct URL)."
  $header2 = "# One filename per line. Managed by 设置不列入.bat . Re-run 发布HTML到在线 to apply."
  $out = @($header, $header2) + @($excl | Sort-Object -Unique)
  [IO.File]::WriteAllLines($ef, $out, (New-Object System.Text.UTF8Encoding($false)))
  Write-Host ""
  Write-Host ("Saved _exclude.txt. Excluded now: " + (@($excl | Sort-Object -Unique) -join ", "))
  Write-Host "==> Now run 发布HTML到在线 to apply the change to the README."
} else {
  Write-Host "No change."
}
