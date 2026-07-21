param(
  [Parameter(Position=0, ValueFromRemainingArguments=$true)][string[]]$Files,   # 拖入的文件/文件夹(全部进这里)
  [string]$Docs = "ask",   # 文档类 md(项目内非README, 如需求/规则说明)是否入库: ask(交互询问,默认) | yes | no。只能具名传 -Docs
  [switch]$Y               # 跳过"未拖文件时的同步确认"(供 Claude 无人值守调用；.bat 不传, 用户会看到确认)
)
# ============================================================================
# 发布HTML到在线 —— 把原型 HTML 发布到 GitHub Pages（tbsbdstar/gift-rule-prototype）
# 完整设计与背景见同目录 工具说明.md（换电脑/新会话读它即可上手）。
#
# 用法（对应 发布HTML到在线.bat）：
#   - 拖单个 .html 到 .bat    -> 自动以"该文件名(去扩展名)"建同名文件夹并发布，不询问
#   - 拖一个项目文件夹到 .bat -> 询问"全部发布 / 选哪几个页面"，只发所选
#   - 直接双击（不拖任何东西）-> 同步全部改动 + 刷新赠品规则首页
# 无论哪种：目标文件夹有 README 就更新版本/链接，没有就自动创建（含链接、按页 ?v= 版本）
#
# 本脚本每次运行会自动：
#   1) 刷新首页 index.html（= 赠品规则源文件）
#   2) 对每个"项目文件夹"（含 .html 的顶层子目录）：
#        · 没有 *_README.md -> 用 _readme_template.md 自动生成一份（含链接、?v=1、版本记录、哈希标记）
#        · 有 *_README.md   -> 只在页面内容变化时，自动把 ?v= 数字 +1 并追加一条版本记录
#      （内容是否变化 = 对文件夹内所有 .html 算 MD5，与 README 里 <!-- pagehash:... --> 比对）
#   3) 重新生成 catalog.html 目录页
#   4) git add/commit/pull --rebase/push（提交者固定 tbsbdstar）
# ----------------------------------------------------------------------------
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8   # 正确解码 git 输出的中文路径
$repo = $PSScriptRoot   # 自动识别=脚本所在文件夹（仓库根）；仓库整体移动/换电脑也无需改路径
$base = "https://tbsbdstar.github.io/gift-rule-prototype/"
$giftSrc = "D:\claude workspace1\赠品规则\玛鲁丸_赠品规则系统_v1.5.html"

# keep gift-rule root index fresh
if (Test-Path $giftSrc) { Copy-Item $giftSrc (Join-Path $repo "index.html") -Force }

function Enc([string]$rel){ ($rel -split '/' | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/' }

# 用新内容替换 README 里 <!--AUTO-LINKS:TAG--> 与 <!--/AUTO-LINKS:TAG--> 之间的部分（找不到标记则原样返回）
function Set-Region([string]$text,[string]$tag,[string]$body){
  $a = "<!--AUTO-LINKS:$tag-->"; $b = "<!--/AUTO-LINKS:$tag-->"
  $i = $text.IndexOf($a); $j = $text.IndexOf($b)
  if ($i -lt 0 -or $j -lt 0 -or $j -le $i) { return $text }
  return $text.Substring(0, $i + $a.Length) + "`n" + $body + "`n" + $text.Substring($j)
}
# 根据文件夹内实际页面重建"直接链接/Axure链接"两段。$vmap = 每个文件名 -> 版本号；axure 链接用各页自己的版本号
function Build-Links($pages,$proj,$base,$fence,$vmap,$withV){
  ($pages | ForEach-Object {
    $u = $base + (Enc ($proj + "/" + $_.Name))
    if ($withV) { $vv = if ($vmap.ContainsKey($_.Name)) { $vmap[$_.Name] } else { 1 }; $u = $u + "?v=$vv" }
    "- " + $_.Name + "`n  " + $fence + "`n  " + $u + "`n  " + $fence
  }) -join "`n"
}
# 从 README 解析每页版本状态：返回 文件名 -> @{v=版本; h=MD5}（藏在 <!--PAGEVERS ... --> 里，每行 名<Tab>版本<Tab>哈希）
function Get-PageVers([string]$text){
  $map = @{}
  $m = [regex]::Match($text, '(?s)<!--PAGEVERS\s*(.*?)-->')
  if ($m.Success) {
    foreach ($line in ($m.Groups[1].Value -split "`n")) {
      $line = $line.Trim(); if (-not $line) { continue }
      $p = $line -split "`t"
      if ($p.Count -ge 3) { $map[$p[0]] = @{ v = [int]$p[1]; h = $p[2] } }
    }
  }
  return $map
}
# 生成 <!--PAGEVERS ... --> 块（按当前页面顺序，记录每页版本与哈希）
function Build-PageVers($state,$pages){
  $lines = @('<!--PAGEVERS')
  foreach ($p in $pages) { $e = $state[$p.Name]; $lines += ($p.Name + "`t" + $e.v + "`t" + $e.h) }
  $lines += '-->'
  return ($lines -join "`n")
}

# 没有拖入任何文件 = "同步模式"：把本地所有改动一次性发布。给出确认，避免误触。
# （-Y 可跳过，供 Claude 无人值守调用；平时用户双击 .bat 不带 -Y，会看到确认）
if ((-not $Files -or @($Files).Count -eq 0) -and -not $Y) {
  $chg = @(git -C $repo status --porcelain 2>$null)
  Write-Host ""
  if ($chg.Count -gt 0) { Write-Host ("你没有拖入文件。检测到本地有 " + $chg.Count + " 处改动（你直接改过的文件）。") }
  else { Write-Host "你没有拖入文件，且没检测到本地改动（继续的话只会刷新首页/目录页）。" }
  Write-Host "提示：要发布某个页面/项目，请把 .html 或文件夹【拖到本 .bat 上】。"
  $go = Read-Host "现在是否【同步全部本地改动】到线上？(回车=是，全部同步 / 输 N=取消)"
  if ($go -match '^[Nn]') { Write-Host "已取消，未做任何发布。"; return }
}

$published = @()
foreach ($f in $Files) {
  if (-not (Test-Path $f)) { continue }

  if (Test-Path $f -PathType Container) {
    # ===== 拖入文件夹：询问发布哪些页面（全部 / 部分）=====
    $proj = Split-Path $f -Leaf
    $srcPages = @(Get-ChildItem $f -Filter *.html -ErrorAction SilentlyContinue | Sort-Object Name)
    if (-not $srcPages) { Write-Host ("[跳过] 文件夹里没有 html 页面：" + $proj); continue }
    $pick = @()
    if ($srcPages.Count -eq 1) {
      $pick = $srcPages
    } else {
      Write-Host ""
      Write-Host ("【" + $proj + "】共有 " + $srcPages.Count + " 个页面：")
      for ($i = 0; $i -lt $srcPages.Count; $i++) { Write-Host ("  {0}. {1}" -f ($i + 1), $srcPages[$i].Name) }
      $sel = Read-Host "要发布哪些？直接回车=全部发布；或输入编号（逗号分隔，如 1,3）"
      if (-not $sel -or -not $sel.Trim()) {
        $pick = $srcPages
      } else {
        $nums = $sel -split '[,\s]+' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
        $pick = @(foreach ($n in $nums) { if ($n -ge 1 -and $n -le $srcPages.Count) { $srcPages[$n - 1] } })
      }
    }
    if (-not $pick) { Write-Host "[跳过] 未选择任何页面。"; continue }
    $target = Join-Path $repo $proj
    if (-not (Test-Path $target)) { New-Item -ItemType Directory $target | Out-Null }
    foreach ($pg in $pick) { Copy-Item $pg.FullName (Join-Path $target $pg.Name) -Force; $published += ($proj + "/" + $pg.Name) }
    Write-Host ("[文件夹] " + $proj + "  已发布 " + @($pick).Count + "/" + $srcPages.Count + " 个页面")
  }
  elseif ([IO.Path]::GetExtension($f) -ieq ".html") {
    # ===== 拖入单个 html：以该 html 名建同名文件夹，直接发布（不询问）=====
    $name = [IO.Path]::GetFileName($f)
    $projName = [IO.Path]::GetFileNameWithoutExtension($f)
    $target = Join-Path $repo $projName
    if (-not (Test-Path $target)) { New-Item -ItemType Directory $target | Out-Null }
    Copy-Item $f (Join-Path $target $name) -Force
    $published += ($projName + "/" + $name)
    Write-Host ("[单页] " + $name + "  ->  " + $projName + "\")
  }
}

# For every project folder (top-level subdir containing .html):
#   - NO *_README.md   -> auto-generate one from _readme_template.md (starts at v1)
#   - HAS *_README.md  -> bump ?v= + append a version-log line, ONLY when page content changed
# All change-detection is filesystem-only: an MD5 of the folder's pages is stored in the
# README as <!-- pagehash:... -->. This avoids parsing git output, which mangles Chinese
# paths on Windows PowerShell 5.1. (See 工具说明.md for the full design.)
$tpl = Join-Path $repo "_readme_template.md"
$fence = '```'
# 悬浮"重置演示"按钮：中文放数据文件 _reset_widget.html（避免脚本中文乱码），下面读进来备用
$resetWidget = if (Test-Path (Join-Path $repo "_reset_widget.html")) { ([IO.File]::ReadAllText((Join-Path $repo "_reset_widget.html"))).Trim() } else { "" }
Get-ChildItem $repo -Directory | Where-Object { $_.Name -notmatch '^[._]' } | ForEach-Object {
  $dir = $_.FullName; $proj = $_.Name
  $allPages = Get-ChildItem $dir -Filter *.html -ErrorAction SilentlyContinue | Sort-Object Name
  if (-not $allPages) { return }
  # 自动给"用了 localStorage 演示数据、但还没有任何重置按钮"的页面注入悬浮"重置演示"按钮（判断是否需要加；幂等）
  if ($resetWidget) {
    foreach ($pg in $allPages) {
      $c = [IO.File]::ReadAllText($pg.FullName)
      if ($c.Contains('localStorage') -and -not $c.Contains('RESET-WIDGET') -and -not $c.Contains('resetDemo')) {
        [IO.File]::WriteAllText($pg.FullName, $c.TrimEnd() + "`n" + $resetWidget + "`n", (New-Object System.Text.UTF8Encoding($false)))
        Write-Host ("[重置按钮] 已注入 -> " + $proj + "/" + $pg.Name)
      }
    }
  }
  # optional exclude list "_exclude.txt" (one filename per line): keep the page ONLINE but omit it from the README
  $excl = @()
  $ef = Join-Path $dir "_exclude.txt"
  if (Test-Path $ef) { $excl = @([IO.File]::ReadAllLines($ef) | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') }) }
  $pages = $allPages | Where-Object { $excl -notcontains $_.Name }
  if (-not $pages) { return }   # every page excluded -> nothing to list
  $readme = Get-ChildItem $dir -Filter *_README.md -ErrorAction SilentlyContinue | Select-Object -First 1
  # current MD5 of each listed page
  $cur = @{}; foreach ($p in $pages) { $cur[$p.Name] = (Get-FileHash $p.FullName -Algorithm MD5).Hash }

  if (-not $readme) {
    # ---- first publish: auto-generate README; every page starts at v1 ----
    if (-not (Test-Path $tpl)) { Write-Host ("[README] 缺少模板，跳过 " + $proj); return }
    $vmap = @{}; $state = @{}
    foreach ($p in $pages) { $vmap[$p.Name] = 1; $state[$p.Name] = @{ v = 1; h = $cur[$p.Name] } }
    $pagesList = ($pages | ForEach-Object {
      $t = ""
      $head = (Get-Content $_.FullName -TotalCount 40 -Encoding UTF8 -ErrorAction SilentlyContinue) -join "`n"
      if ($head -match '<title>\s*(.*?)\s*</title>') { $t = " - " + $Matches[1] }
      "- " + $_.Name + $t
    }) -join "`n"
    $md = [IO.File]::ReadAllText($tpl)
    $md = $md.Replace('{{PROJECT}}', $proj)
    $md = $md.Replace('{{PAGE_COUNT}}', [string]$pages.Count)
    $md = $md.Replace('{{PAGES_LIST}}', $pagesList)
    $md = $md.Replace('{{DIRECT_LINKS}}', (Build-Links $pages $proj $base $fence $vmap $false))
    $md = $md.Replace('{{AXURE_LINKS}}',  (Build-Links $pages $proj $base $fence $vmap $true))
    $md = $md.Replace('{{DATE}}', (Get-Date -Format 'yyyy-MM-dd'))
    $md = $md.Replace('{{PAGEVERS}}', (Build-PageVers $state $pages))
    [IO.File]::WriteAllText((Join-Path $dir ($proj + "_README.md")), $md, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host ("[README] 已自动生成 " + $proj + "_README.md（各页从 v1 起）")
    return
  }

  # ---- existing README: PER-PAGE versioning (change one page -> only that page's ?v= bumps) ----
  $rf = $readme.FullName
  $orig = [IO.File]::ReadAllText($rf)
  $txt = $orig
  $prev = Get-PageVers $txt
  if ($prev.Count -eq 0) {
    # migrate old project-level README: seed every page at current project ?v= + current hash (no bump this run)
    $seedV = if ($txt -match '\?v=(\d+)') { ([regex]::Matches($txt,'\?v=(\d+)') | ForEach-Object { [int]$_.Groups[1].Value } | Measure-Object -Maximum).Maximum } else { 1 }
    foreach ($p in $pages) { $prev[$p.Name] = @{ v = $seedV; h = $cur[$p.Name] } }
  }
  # per-page: bump only the pages whose content changed
  $vmap = @{}; $state = @{}; $bumped = @()
  foreach ($p in $pages) {
    $n = $p.Name
    if ($prev.ContainsKey($n)) {
      if ($prev[$n].h -eq $cur[$n]) { $v = $prev[$n].v }
      else { $v = $prev[$n].v + 1; $bumped += ($n + " -> v" + $v) }
    } else { $v = 1; $bumped += ($n + " -> v1 (new)") }
    $vmap[$n] = $v; $state[$n] = @{ v = $v; h = $cur[$n] }
  }
  # refresh link blocks (each Axure link uses its own version)
  $txt = Set-Region $txt 'DIRECT' (Build-Links $pages $proj $base $fence $vmap $false)
  $txt = Set-Region $txt 'AXURE'  (Build-Links $pages $proj $base $fence $vmap $true)
  # strip trailing markers (per-page block and any legacy combined pagehash)
  $txt = [regex]::Replace($txt, '(?s)\s*<!--PAGEVERS.*?-->\s*$', '')
  $txt = [regex]::Replace($txt, '(?s)\s*<!--\s*pagehash:[0-9A-Fa-f-]+\s*-->\s*$', '')
  # append a version-log line per bumped page
  if ($bumped.Count -gt 0) {
    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $log = ($bumped | ForEach-Object { "- " + $_ + "  (" + $stamp + ")" }) -join "`n"
    $txt = $txt.TrimEnd() + "`n" + $log + "`n"
    Write-Host ("[README] " + $readme.Name + " 版本更新：" + ($bumped -join "; "))
  }
  # re-append the per-page version state as the very last block
  $txt = $txt.TrimEnd() + "`n`n" + (Build-PageVers $state $pages) + "`n"
  if ($txt -ne $orig) { [IO.File]::WriteAllText($rf, $txt, (New-Object System.Text.UTF8Encoding($false))) }
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

# 文档类 md（项目文件夹内、非 *_README.md，如"需求规则/说明"文档）是否随发布入库。
# -Docs ask(默认,交互询问) | yes | no。用纯 ASCII pathspec 圈定，不涉及中文路径。
$docSpec = @('*/*.md', ':(exclude)*/*_README.md')
git -C $repo diff --cached --quiet -- @docSpec
if ($LASTEXITCODE -ne 0) {                       # 有暂存的文档改动
  $ans = $Docs
  if ($ans -eq 'ask') {
    $docNames = (Get-ChildItem $repo -Recurse -Filter *.md | Where-Object { $_.Name -notlike '*_README.md' -and $_.Directory.FullName -ne $repo } | ForEach-Object { $_.Name }) -join ', '
    Write-Host ""
    Write-Host ("[文档] 检测到文档改动：" + $docNames)
    $r = Read-Host "这些文档要提交到线上仓库吗？(y=推送上线 / 直接回车=只留本地)"
    $ans = if ($r -match '^[Yy]') { 'yes' } else { 'no' }
  }
  if ($ans -eq 'no') { git -C $repo reset -q -- @docSpec; Write-Host "[文档] 已保留本地（本次不提交）。" }
  else { Write-Host "[文档] 将随本次发布提交到仓库。" }
}

$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git -C $repo commit -m ("publish " + $ts) 2>$null
git -C $repo pull --rebase origin main   # 先合并远端(含网页改动)，避免 push 被拒
git -C $repo push
if ($LASTEXITCODE -ne 0) {               # push 失败(网络等) -> 重试一次
  Write-Host "[推送] 第一次失败，正在重试……"
  git -C $repo pull --rebase origin main
  git -C $repo push
}
if ($LASTEXITCODE -ne 0) {               # 仍失败 -> 醒目报错(改动只在本地)
  Write-Host ""
  Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  Write-Host "!!! 推送失败！改动只在本地，【尚未上线】。"
  Write-Host "!!! 请检查网络/VPN，然后再双击一次 .bat 重新发布。"
  Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
} else {
  Write-Host "[推送] 成功，已同步到 GitHub。"
}

Write-Host ""
Write-Host "==================== 在线链接 ===================="
Write-Host ("目录页：" + $base + "catalog.html")
if ($published.Count -gt 0) {
  Write-Host "本次发布/更新："
  foreach ($r in ($published | Sort-Object -Unique)) { Write-Host ("  " + $base + (Enc $r)) }
}
Write-Host "=================================================="
Write-Host "GitHub Pages 约 1 分钟后生效。"

