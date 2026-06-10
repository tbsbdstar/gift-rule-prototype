$ErrorActionPreference = "Stop"
$gh   = "C:\Users\taobs\gh\bin\gh.exe"
$site = "C:\Users\taobs\gift-rule-site"
$src  = "D:\claude workspace1\赠品规则\玛鲁丸_赠品规则系统_v1.5.html"

Copy-Item $src "$site\index.html" -Force
git -C $site add -A
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git -C $site commit -m "update $ts" 2>$null
git -C $site push
Write-Host "已推送。约 1 分钟后线上链接自动更新。" -ForegroundColor Green
