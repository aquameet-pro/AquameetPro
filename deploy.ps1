# AquaMeet Pro — deploy script
# Usage:
#   .\deploy.ps1                     # commit message = "Update"
#   .\deploy.ps1 "Fix bell notif"    # custom commit message
param(
    [string]$msg = "Update"
)

$ErrorActionPreference = "Stop"

# 1. Auto-update cache version in sw.js (use Python to avoid PowerShell encoding corruption)
$ts    = Get-Date -Format "yyyyMMdd-HHmm"
$cache = "aquameet-$ts"
python -c "
import re, sys
with open('sw.js', 'r', encoding='utf-8') as f:
    s = f.read()
s = re.sub(r\"const CACHE = 'aquameet-[^']*'\", \"const CACHE = 'aquameet-$ts'\", s)
with open('sw.js', 'w', encoding='utf-8') as f:
    f.write(s)
print('SW cache updated')
"
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
