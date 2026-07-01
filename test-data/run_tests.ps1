# ============================================================
# Script kiểm thử tự động: VQA & Caption API
# Đề tài: Phát hiện và phân vùng tổn thương y tế
# Thành viên 5 - Tester
#
# Chạy: powershell -ExecutionPolicy Bypass -File run_tests.ps1
# ============================================================

param(
    [string]$BaseUrl = "https://tile-clover-apple.ngrok-free.dev"
)

$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$csvInput    = Join-Path $scriptDir "test_cases.csv"
$csvOutput   = Join-Path $scriptDir "results.csv"
$logFile     = Join-Path $scriptDir "test_log.txt"
$imagesRoot  = Join-Path $scriptDir "images"

$timestamp   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$headers     = @{ "ngrok-skip-browser-warning" = "true" }

Write-Host ""
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host "  KIEM THU TU DONG - API Y TE" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host "  Base URL : $BaseUrl" -ForegroundColor Cyan
Write-Host "  Thoi gian: $timestamp" -ForegroundColor Cyan
Write-Host "  CSV Input: $csvInput" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host ""

# --- Kiem tra API truoc ---
Write-Host "[*] Kiem tra Health API..." -ForegroundColor Yellow -NoNewline
try {
    $health = Invoke-RestMethod -Uri "$BaseUrl/health" -Method GET -Headers $headers -TimeoutSec 15
    Write-Host " OK - Status: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host " THAT BAI!" -ForegroundColor Red
    Write-Host "    Loi: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "    -> Kiem tra lai BaseUrl hoac API con song khong." -ForegroundColor Yellow
    Write-Host "    -> Chay lai: .\run_tests.ps1 -BaseUrl 'URL_MOI'" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# --- Doc CSV ---
$rows = Import-Csv -Path $csvInput -Encoding UTF8
$results = @()
$total = $rows.Count
$idx   = 0
$okVqa = 0
$okCap = 0
$failCount = 0

foreach ($row in $rows) {
    $idx++
    $imageName = $row."Ten anh"
    $question  = $row."Cau hoi tieng Anh"

    # Xac dinh thu muc anh (xray / clinical / general)
    if     ($imageName -like "xray_*")     { $folder = "xray" }
    elseif ($imageName -like "clinical_*") { $folder = "clinical" }
    else                                    { $folder = "general" }

    $imagePath = Join-Path $imagesRoot "$folder\$imageName"

    Write-Host "[$idx/$total] $imageName" -ForegroundColor White -NoNewline

    # Kiem tra file ton tai
    if (-not (Test-Path $imagePath)) {
        Write-Host " -> SKIP (khong tim thay file)" -ForegroundColor Yellow
        $row."Ket qua VQA"    = "FILE_NOT_FOUND"
        $row."Caption AI sinh" = "FILE_NOT_FOUND"
        $row."Dung/Sai VQA"   = "?"
        $row."Dung/Sai Caption"= "?"
        $results += $row
        $failCount++
        continue
    }

    # ---- Goi Caption API ----
    $captionResult = "ERROR"
    try {
        $form = @{ file = Get-Item $imagePath }
        $resp = Invoke-RestMethod -Uri "$BaseUrl/caption" -Method POST -Headers $headers -Form $form -TimeoutSec 60
        # Ket qua co the la .caption hoac .result hoac .answer
        if     ($resp.caption)  { $captionResult = $resp.caption }
        elseif ($resp.result)   { $captionResult = $resp.result }
        elseif ($resp.answer)   { $captionResult = $resp.answer }
        else                    { $captionResult = $resp | ConvertTo-Json -Compress }
    } catch {
        $captionResult = "API_ERROR: $($_.Exception.Message)"
        $failCount++
    }

    # ---- Goi VQA API ----
    $vqaResult = "ERROR"
    try {
        $form = @{
            file     = Get-Item $imagePath
            question = $question
        }
        $resp = Invoke-RestMethod -Uri "$BaseUrl/vqa" -Method POST -Headers $headers -Form $form -TimeoutSec 60
        if     ($resp.answer)   { $vqaResult = $resp.answer }
        elseif ($resp.result)   { $vqaResult = $resp.result }
        elseif ($resp.caption)  { $vqaResult = $resp.caption }
        else                    { $vqaResult = $resp | ConvertTo-Json -Compress }
    } catch {
        $vqaResult = "API_ERROR: $($_.Exception.Message)"
        $failCount++
    }

    # Cap nhat row
    $row."Ket qua VQA"     = $vqaResult
    $row."Caption AI sinh" = $captionResult
    # Dung/Sai se dien tay sau
    $row."Dung/Sai VQA"    = "?"
    $row."Dung/Sai Caption" = "?"

    $results += $row

    # In ket qua ngan
    $vqaShort = if ($vqaResult.Length -gt 50) { $vqaResult.Substring(0,50) + "..." } else { $vqaResult }
    $capShort = if ($captionResult.Length -gt 50) { $captionResult.Substring(0,50) + "..." } else { $captionResult }
    Write-Host ""
    Write-Host "    VQA    : $vqaShort" -ForegroundColor $(if ($vqaResult -like "API_ERROR*" -or $vqaResult -eq "ERROR") {"Red"} else {"Green"})
    Write-Host "    Caption: $capShort" -ForegroundColor $(if ($captionResult -like "API_ERROR*" -or $captionResult -eq "ERROR") {"Red"} else {"Cyan"})
}

# --- Luu CSV ket qua ---
$results | Export-Csv -Path $csvOutput -NoTypeInformation -Encoding UTF8
Write-Host ""
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host "  HOAN TAT KIEM THU" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host "  Tong so anh da test : $total" -ForegroundColor White
Write-Host "  So loi API          : $failCount" -ForegroundColor $(if ($failCount -gt 0) {"Red"} else {"Green"})
Write-Host "  Ket qua luu tai    : $csvOutput" -ForegroundColor Cyan
Write-Host ""
Write-Host "BUOC TIEP THEO:" -ForegroundColor Yellow
Write-Host "  1. Mo file results.csv" -ForegroundColor Yellow
Write-Host "  2. Dien cot 'Dung/Sai VQA' va 'Dung/Sai Caption' (Dung/Sai)" -ForegroundColor Yellow
Write-Host "  3. Chup man hinh 5 case tot + 2 case sai" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Magenta

# Ghi log
"[$timestamp] Test chay xong. Total=$total, Fail=$failCount, Output=$csvOutput" | Out-File $logFile -Append
