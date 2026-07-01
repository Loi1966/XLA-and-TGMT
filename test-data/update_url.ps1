# ============================================================
# Script cap nhat URL ngrok khi Colab khoi dong lai
#
# Su dung:
#   .\update_url.ps1 -NewUrl "https://TEN-MOI.ngrok-free.app"
# ============================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$NewUrl
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "Cap nhat Base URL moi: $NewUrl" -ForegroundColor Cyan

# 1. Cap nhat Postman collection
$postmanFile = Join-Path $scriptDir "VQA_Caption_Tests.postman_collection.json"
if (Test-Path $postmanFile) {
    $json = Get-Content $postmanFile -Raw | ConvertFrom-Json
    foreach ($var in $json.variable) {
        if ($var.key -eq "base_url") {
            $oldUrl = $var.value
            $var.value = $NewUrl
            Write-Host "  [OK] Postman: $oldUrl -> $NewUrl" -ForegroundColor Green
        }
    }
    $json | ConvertTo-Json -Depth 20 | Set-Content $postmanFile -Encoding UTF8
} else {
    Write-Host "  [WARN] Khong tim thay Postman collection" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Xong! Chay kiem thu ngay:" -ForegroundColor Green
Write-Host "  powershell -ExecutionPolicy Bypass -File run_tests.ps1 -BaseUrl '$NewUrl'" -ForegroundColor Cyan
Write-Host ""
