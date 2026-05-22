# AquaMeet Pro — deploy script
# Usage:
#   .\deploy.ps1                     # commit message = "Update"
#   .\deploy.ps1 "Fix bell notif"    # custom commit message
param(
    [string]$msg = "Update"
)

$ErrorActionPreference = "Stop"

# 1. Auto-update cache version in sw.js
$ts    = Get-Date -Format "yyyyMMdd-HHmm"
$cache = "aquameet-$ts"
$sw    = Get-Content "sw.js" -Raw
$sw    = $sw -replace "const CACHE = 'aquameet-[^']*'", "const CACHE = '$cache'"
[System.IO.File]::WriteAllText("$PSScriptRoot\sw.js", $sw)
Write-Host "SW cache: $cache"

# 2. Copy main file to index.html
Copy-Item "AquaMeet_Pro_Supabase.html" "index.html" -Force
Write-Host "index.html updated"

# 3. Git commit & push
git add AquaMeet_Pro_Supabase.html index.html sw.js
git commit -m $msg
git push origin main

Write-Host ""
Write-Host "Deployed successfully!" -ForegroundColor Green
Write-Host "Cache version: $cache" -ForegroundColor Cyan
