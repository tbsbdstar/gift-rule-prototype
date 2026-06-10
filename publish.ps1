# Publish dropped HTML files to GitHub Pages and print links.
#   - Drag .html file(s) onto the .bat  -> copy + publish
#   - Double-click the .bat with nothing -> sync current repo (and refresh gift-rule index)
$ErrorActionPreference = "Stop"
$repo = "C:\Users\taobs\gift-rule-site"
$base = "https://tbsbdstar.github.io/gift-rule-prototype/"
$giftSrc = "D:\claude workspace1\赠品规则\玛鲁丸_赠品规则系统_v1.5.html"

if (Test-Path $giftSrc) { Copy-Item $giftSrc (Join-Path $repo "index.html") -Force }

$copied = @()
foreach ($f in $args) {
  if ((Test-Path $f -PathType Leaf) -and ([IO.Path]::GetExtension($f) -ieq ".html")) {
    $name = [IO.Path]::GetFileName($f)
    Copy-Item $f (Join-Path $repo $name) -Force
    $copied += $name
    Write-Host ("[copied] " + $name)
  }
}

$all = Get-ChildItem $repo -Filter *.html | Where-Object { $_.Name -ne "catalog.html" } | Sort-Object Name
$rows = ""
foreach ($p in $all) {
  $enc = [uri]::EscapeDataString($p.Name)
  $rows += "<li><a href='$enc' target='_blank'>" + $p.Name + "</a><div class='u'>" + $base + $enc + "</div></li>`n"
}
$html = "<!doctype html><html lang='zh-CN'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>Prototype Hub</title><style>body{font-family:'Microsoft YaHei',Arial,sans-serif;max-width:900px;margin:40px auto;padding:0 20px;color:#222;background:#fafafa}h1{font-size:20px}ul{list-style:none;padding:0}li{margin:10px 0;padding:12px 14px;background:#fff;border:1px solid #eee;border-radius:8px}a{color:#1890ff;text-decoration:none;font-weight:600;font-size:15px}.u{color:#999;font-size:12px;margin-top:4px;word-break:break-all}</style></head><body><h1>Prototype Hub - 原型库</h1><ul>" + $rows + "</ul></body></html>"
$html | Out-File (Join-Path $repo "catalog.html") -Encoding utf8

git -C $repo config core.quotepath false 2>$null
git -C $repo add -A
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git -C $repo commit -m ("publish " + $ts) 2>$null
git -C $repo push

Write-Host ""
Write-Host "==================== ONLINE LINKS ===================="
Write-Host ("Catalog : " + $base + "catalog.html")
if ($copied.Count -gt 0) {
  Write-Host "Published/updated this run:"
  foreach ($n in $copied) { Write-Host ("  " + $base + [uri]::EscapeDataString($n)) }
}
Write-Host "All pages:"
foreach ($p in $all) { Write-Host ("  " + $p.Name + "  ->  " + $base + [uri]::EscapeDataString($p.Name)) }
Write-Host "======================================================"
Write-Host "GitHub Pages takes ~1 min to update."

