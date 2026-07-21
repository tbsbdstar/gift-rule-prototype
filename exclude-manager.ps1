# exclude-manager.ps1 —— 维护某个项目的 README 排除名单 _exclude.txt
# 用法：把一个项目文件夹拖到「设置不列入.bat」上运行。被排除的页面仍会在线，只是不列进 README。
# 注意：本脚本必须以 UTF-8 带 BOM 保存，否则 PowerShell 5.1 会把中文读成乱码。
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$folder = $Args | Where-Object { $_ } | Select-Object -First 1
if (-not $folder -or -not (Test-Path $folder -PathType Container)) {
  Write-Host "请把一个【项目文件夹】拖到本 .bat 上运行（需要一个文件夹路径）。"
  return
}
$pages = Get-ChildItem $folder -Filter *.html -ErrorAction SilentlyContinue | Sort-Object Name
if (-not $pages) { Write-Host ("该文件夹里没有 .html 页面：" + $folder); return }

$ef = Join-Path $folder "_exclude.txt"
$excl = @()
if (Test-Path $ef) { $excl = @([IO.File]::ReadAllLines($ef) | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }) }

Write-Host ""
Write-Host ("项目：" + (Split-Path $folder -Leaf))
Write-Host "页面列表（ [×]=不列入README（但仍在线），[  ]=正常列入 ）："
for ($i = 0; $i -lt $pages.Count; $i++) {
  $mark = if ($excl -contains $pages[$i].Name) { "[×]" } else { "[  ]" }
  Write-Host ("  {0}. {1} {2}" -f ($i + 1), $mark, $pages[$i].Name)
}
Write-Host ""
$sel = Read-Host "输入要【切换 列入/不列入】的编号（多个用逗号分隔，如 1,3）；直接回车=不改动"

if ($sel -and $sel.Trim()) {
  $nums = $sel -split '[,\s]+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
  foreach ($n in $nums) {
    if ($n -ge 1 -and $n -le $pages.Count) {
      $name = $pages[$n - 1].Name
      if ($excl -contains $name) { $excl = @($excl | Where-Object { $_ -ne $name }) }
      else { $excl += $name }
    }
  }
  $header  = "# 本文件列出【不写入 README 链接】的页面文件名（每行一个）。页面仍会上线，可直链访问。"
  $header2 = "# 由「设置不列入.bat」维护。改完后再运行「发布HTML到在线.bat」即可生效。"
  $out = @($header, $header2) + @($excl | Sort-Object -Unique)
  [IO.File]::WriteAllText($ef, (($out -join "`r`n") + "`r`n"), (New-Object System.Text.UTF8Encoding($false)))
  Write-Host ""
  Write-Host ("已保存 _exclude.txt。当前不列入的页面：" + $(if(@($excl).Count){ (@($excl | Sort-Object -Unique) -join "，") } else { "（无）" }))
  Write-Host "==> 现在去运行「发布HTML到在线.bat」，改动即会应用到 README。"
} else {
  Write-Host "未做改动。"
}
