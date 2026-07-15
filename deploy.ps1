$ErrorActionPreference = "Stop"
$gh   = "C:\Users\taobs\gh\bin\gh.exe"
$site = $PSScriptRoot   # 自动识别=脚本所在文件夹（仓库根）；换电脑/移动仓库无需改路径
$src  = "D:\claude workspace1\赠品规则\玛鲁丸_赠品规则系统_v1.5.html"

if (Test-Path $src) { Copy-Item $src "$site\index.html" -Force }   # 源文件不存在(如换了电脑)则跳过刷新首页
git -C $site add -A
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git -C $site commit -m "update $ts" 2>$null
git -C $site pull --rebase origin main   # 先合并远端(含网页改动)，避免 push 被拒
git -C $site push
Write-Host "已推送。约 1 分钟后线上链接自动更新。" -ForegroundColor Green

