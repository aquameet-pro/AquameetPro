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
# Write Python helper to temp file — avoids quote-escaping in inline -c
$pyScript = "$PSScriptRoot\_sw_bump.py"
Set-Content -Path $pyScript -Value @"
import re
cache = 'aquameet-$ts'
with open('sw.js', 'r', encoding='utf-8') as f:
    s = f.read()
s = re.sub(r"const CACHE = 'aquameet-[^']*'", "const CACHE = '" + cache + "'", s)
with open('sw.js', 'w', encoding='utf-8') as f:
    f.write(s)
# Stamp APP_BUILD in the app HTML so the running version is visible in the UI
with open('AquaMeet_Pro_Supabase.html', 'r', encoding='utf-8') as f:
    h = f.read()
h = re.sub(r"const APP_BUILD='[^']*'", "const APP_BUILD='$ts'", h)
with open('AquaMeet_Pro_Supabase.html', 'w', encoding='utf-8') as f:
    f.write(h)
"@ -Encoding utf8
python $pyScript
Remove-Item $pyScript -ErrorAction SilentlyContinue
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
