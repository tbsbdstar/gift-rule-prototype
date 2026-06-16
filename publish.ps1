param(
  [string]$Project = "",
  [Parameter(ValueFromRemainingArguments=$true)][string[]]$Files
)
# Publish to GitHub Pages, organized by project subfolder.
#   - Drag a PROJECT FOLDER onto the .bat  -> published as /<folder>/...
#   - Drag loose .html file(s)             -> .bat asks a project subfolder (Enter = root)
#   - Double-click with nothing            -> sync everything (and refresh gift-rule root)
$ErrorActionPreference = "Stop"
$repo = "C:\Users\taobs\gift-rule-site"
$base = "https://tbsbdstar.github.io/gift-rule-prototype/"
$giftSrc = "D:\claude workspace1\赠品规则\玛鲁丸_赠品规则系统_v1.5.html"

# keep gift-rule root index fresh
if (Test-Path $giftSrc) { Copy-Item $giftSrc (Join-Path $repo "index.html") -Force }

function Enc([string]$rel){ ($rel -split '/' | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/' }

$published = @()
foreach ($f in $Files) {
  if (-not (Test-Path $f)) { continue }
  if (Test-Path $f -PathType Container) {
    # a project folder -> /<folderName>/
    $proj = Split-Path $f -Leaf
    $target = Join-Path $repo $proj
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Copy-Item $f $target -Recurse -Force
    Get-ChildItem $target -Recurse -Filter *.html | ForEach-Object {
      $published += ($proj + "/" + $_.Name)
    }
    Write-Host ("[folder] " + $proj + "  (" + (Get-ChildItem $target -Recurse -Filter *.html).Count + " html)")
  }
  elseif ([IO.Path]::GetExtension($f) -ieq ".html") {
    $name = [IO.Path]::GetFileName($f)
    if ($Project -ne "") {
      $dir = Join-Path $repo $Project
      if (-not (Test-Path $dir)) { New-Item -ItemType Directory $dir | Out-Null }
      Copy-Item $f (Join-Path $dir $name) -Force
      $published += ($Project + "/" + $name)
    } else {
      Copy-Item $f (Join-Path $repo $name) -Force
      $published += $name
    }
    Write-Host ("[file] " + $name + $(if($Project){" -> "+$Project} else {""}))
  }
}

# auto-bump cache-buster ?v=N in each published project's *_README.md
$bumped = @{}
foreach ($rel in $published) {
  if ($rel -notmatch "/") { continue }            # only files placed inside a project folder
  $proj = ($rel -split "/")[0]
  if ($bumped.ContainsKey($proj)) { continue }
  $bumped[$proj] = $true
  Get-ChildItem (Join-Path $repo $proj) -Filter *_README.md -ErrorAction SilentlyContinue | ForEach-Object {
    $txt = [IO.File]::ReadAllText($_.FullName)
    $ms = [regex]::Matches($txt, '\?v=(\d+)')
    if ($ms.Count -eq 0) { return }
    $cur = ($ms | ForEach-Object { [int]$_.Groups[1].Value } | Measure-Object -Maximum).Maximum
    $nv = $cur + 1
    $txt = [regex]::Replace($txt, '\?v=\d+', "?v=$nv")
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $txt = $txt.TrimEnd() + "`n- v$nv  ($stamp)`n"   # append a version-log entry at EOF
    [IO.File]::WriteAllText($_.FullName, $txt, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host ("[readme] " + $_.Name + " -> v=" + $nv)
  }
}

# regenerate catalog.html grouped by top-level folder
$all = Get-ChildItem $repo -Recurse -Filter *.html | Where-Object { $_.FullName -notmatch "\\\.git\\" -and $_.Name -ne "catalog.html" }
$groups = @{}
foreach ($p in $all) {
  $rel = ($p.FullName.Substring($repo.Length + 1)) -replace "\\","/"
  $seg = $rel.Split("/")
  $g = if ($seg.Length -gt 1) { $seg[0] } else { "root" }
  if (-not $groups.ContainsKey($g)) { $groups[$g] = @() }
  $groups[$g] += $rel
}
$sections = ""
foreach ($g in ($groups.Keys | Sort-Object)) {
  $sections += "<h2>" + $g + "</h2><ul>"
  foreach ($rel in ($groups[$g] | Sort-Object)) {
    $enc = Enc $rel
    $sections += "<li><a href='$enc' target='_blank'>" + $rel + "</a><div class='u'>" + $base + $enc + "</div></li>"
  }
  $sections += "</ul>"
}
$html = "<!doctype html><html lang='zh-CN'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>Prototype Hub</title><style>body{font-family:'Microsoft YaHei',Arial,sans-serif;max-width:920px;margin:36px auto;padding:0 20px;color:#222;background:#fafafa}h1{font-size:20px}h2{font-size:15px;color:#1f3864;margin:22px 0 8px;border-left:3px solid #1890ff;padding-left:8px}ul{list-style:none;padding:0;margin:0}li{margin:8px 0;padding:11px 14px;background:#fff;border:1px solid #eee;border-radius:8px}a{color:#1890ff;text-decoration:none;font-weight:600;font-size:14px}.u{color:#999;font-size:12px;margin-top:4px;word-break:break-all}</style></head><body><h1>Prototype Hub</h1>" + $sections + "</body></html>"
$html | Out-File (Join-Path $repo "catalog.html") -Encoding utf8

git -C $repo config core.quotepath false 2>$null
git -C $repo add -A
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git -C $repo commit -m ("publish " + $ts) 2>$null
git -C $repo pull --rebase origin main   # 先合并远端(含网页改动)，避免 push 被拒
git -C $repo push

Write-Host ""
Write-Host "==================== ONLINE LINKS ===================="
Write-Host ("Catalog : " + $base + "catalog.html")
if ($published.Count -gt 0) {
  Write-Host "Published/updated this run:"
  foreach ($r in ($published | Sort-Object -Unique)) { Write-Host ("  " + $base + (Enc $r)) }
}
Write-Host "======================================================"
Write-Host "GitHub Pages takes ~1 min to update."

