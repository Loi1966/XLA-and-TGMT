# Script tải ảnh test cho đề tài: Phát hiện và phân vùng tổn thương y tế
# Mô tả ảnh và trả lời câu hỏi dựa trên nội dung hình ảnh (VQA & Captioning)
#
# 3 nhóm ảnh:
#   1. X-quang / Y tế (xray)       - 10 ảnh từ Unsplash (chủ đề y tế)
#   2. Lâm sàng / Tổn thương (clinical) - 10 ảnh từ Unsplash (chủ đề lâm sàng)
#   3. COCO tổng quát (general)     - 10 ảnh từ COCO val2017 (benchmark)
#
# Chạy: powershell -ExecutionPolicy Bypass -File download_images.ps1

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$xrayDir     = Join-Path $baseDir "images\xray"
$clinicalDir = Join-Path $baseDir "images\clinical"
$generalDir  = Join-Path $baseDir "images\general"

# Tạo thư mục nếu chưa có
New-Item -ItemType Directory -Force -Path $xrayDir, $clinicalDir, $generalDir | Out-Null

# ===== XRAY (Ảnh chủ đề X-quang / Y tế) =====
# Nguồn: Unsplash (miễn phí, không cần API key) - Chủ đề bệnh viện, CT scan, chẩn đoán
$xrayImages = @(
    @{ Name="xray_01.jpg"; Url="https://images.unsplash.com/photo-1530497610245-94d3c16cda28?w=800&q=80" },  # Xem phim X-quang trên bảng sáng
    @{ Name="xray_02.jpg"; Url="https://images.unsplash.com/photo-1526256262350-7da7584cf5eb?w=800&q=80" },  # CT scan não
    @{ Name="xray_03.jpg"; Url="https://images.unsplash.com/photo-1559757175-5700dde675bc?w=800&q=80" },   # Ảnh phim X-quang
    @{ Name="xray_04.jpg"; Url="https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&q=80" },   # Não MRI/CT scan
    @{ Name="xray_05.jpg"; Url="https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800&q=80" },  # Bác sĩ đọc phim X-quang
    @{ Name="xray_06.jpg"; Url="https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800&q=80" },  # Thiết bị y tế bệnh viện
    @{ Name="xray_07.jpg"; Url="https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=800&q=80" },  # Bác sĩ phòng X-quang
    @{ Name="xray_08.jpg"; Url="https://images.unsplash.com/photo-1504813184591-01572f98c85f?w=800&q=80" },  # Bàn tay/thiết bị y tế
    @{ Name="xray_09.jpg"; Url="https://images.unsplash.com/photo-1538108149393-fbbd81895907?w=800&q=80" },  # Phổi / hô hấp
    @{ Name="xray_10.jpg"; Url="https://images.unsplash.com/photo-1564325724739-bae0bd08762c?w=800&q=80" }   # Cột sống / xương
)

# ===== CLINICAL (Ảnh lâm sàng / Khám bệnh) =====
# Nguồn: Unsplash (miễn phí, không cần API key) - Chủ đề da liễu, khám bệnh, thiết bị
$clinicalImages = @(
    @{ Name="clinical_01.jpg"; Url="https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=800&q=80" },  # Bác sĩ da liễu khám bệnh
    @{ Name="clinical_02.jpg"; Url="https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800&q=80" },  # Quy trình y tế / thủ thuật
    @{ Name="clinical_03.jpg"; Url="https://images.unsplash.com/photo-1551884831-bbf3cdc6469e?w=800&q=80" },   # Khám lâm sàng
    @{ Name="clinical_04.jpg"; Url="https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&q=80" }, # Kiểm tra mắt
    @{ Name="clinical_05.jpg"; Url="https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=800&q=80" }, # Kính hiển vi phòng lab
    @{ Name="clinical_06.jpg"; Url="https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=800&q=80" }, # Ống nghe (stethoscope)
    @{ Name="clinical_07.jpg"; Url="https://images.unsplash.com/photo-1574169208507-84376144848b?w=800&q=80" }, # Phòng lab phân tích
    @{ Name="clinical_08.jpg"; Url="https://images.unsplash.com/photo-1504439468489-c8920d796a29?w=800&q=80" }, # Thiết bị y tế / phòng phẫu thuật
    @{ Name="clinical_09.jpg"; Url="https://images.unsplash.com/photo-1584515933487-779824d29309?w=800&q=80" }, # Bác sĩ với bệnh nhân
    @{ Name="clinical_10.jpg"; Url="https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&q=80" }  # Scan y tế
)

# ===== GENERAL (Ảnh COCO tổng quát - Benchmark so sánh) =====
# Nguồn: COCO val2017 dataset (Microsoft COCO)
$generalImages = @(
    @{ Name="general_01.jpg"; Url="http://images.cocodataset.org/val2017/000000039769.jpg" },   # Mèo trên sofa
    @{ Name="general_02.jpg"; Url="http://images.cocodataset.org/val2017/000000252219.jpg" },   # Người trượt ván
    @{ Name="general_03.jpg"; Url="http://images.cocodataset.org/val2017/000000087038.jpg" },   # Xe buýt
    @{ Name="general_04.jpg"; Url="http://images.cocodataset.org/val2017/000000174482.jpg" },   # Người với chó
    @{ Name="general_05.jpg"; Url="http://images.cocodataset.org/val2017/000000403385.jpg" },   # Hươu cao cổ
    @{ Name="general_06.jpg"; Url="http://images.cocodataset.org/val2017/000000296649.jpg" },   # Cảnh đường phố
    @{ Name="general_07.jpg"; Url="http://images.cocodataset.org/val2017/000000037777.jpg" },   # Trượt tuyết
    @{ Name="general_08.jpg"; Url="http://images.cocodataset.org/val2017/000000006471.jpg" },   # Máy bay
    @{ Name="general_09.jpg"; Url="http://images.cocodataset.org/val2017/000000082807.jpg" },   # Người cầm ô
    @{ Name="general_10.jpg"; Url="http://images.cocodataset.org/val2017/000000140270.jpg" }    # Lướt sóng
)

function Download-Images($images, $dir, $category) {
    $count = 0
    $total = $images.Count
    foreach ($img in $images) {
        $count++
        $dest = Join-Path $dir $img.Name
        if (Test-Path $dest) {
            Write-Host "  [SKIP] $($img.Name) da ton tai" -ForegroundColor Yellow
            continue
        }
        Write-Host "  [$count/$total] Dang tai $($img.Name)..." -ForegroundColor Cyan -NoNewline
        try {
            $userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            Invoke-WebRequest -Uri $img.Url -OutFile $dest -TimeoutSec 60 -UseBasicParsing -UserAgent $userAgent
            $size = [math]::Round((Get-Item $dest).Length / 1KB, 1)
            Write-Host " OK (${size} KB)" -ForegroundColor Green
        } catch {
            Write-Host " THAT BAI: $($_.Exception.Message)" -ForegroundColor Red
        }
        Start-Sleep -Milliseconds 1500  # Tranh rate limit
    }
}

Write-Host "`n===== TAI ANH TEST - DE TAI Y TE =====" -ForegroundColor Magenta
Write-Host "De tai: Phat hien va phan vung ton thuong y te" -ForegroundColor White
Write-Host ""

Write-Host "[1/3] Anh X-quang / Y te (xray)..." -ForegroundColor White
Download-Images $xrayImages $xrayDir "xray"

Write-Host "`n[2/3] Anh lam sang / Ton thuong da (clinical)..." -ForegroundColor White
Download-Images $clinicalImages $clinicalDir "clinical"

Write-Host "`n[3/3] Anh COCO tong quat (general - benchmark)..." -ForegroundColor White
Download-Images $generalImages $generalDir "general"

Write-Host "`n===== HOAN TAT! =====" -ForegroundColor Green
Write-Host "Tong cong: 30 anh trong 3 thu muc" -ForegroundColor White
Write-Host "  - $xrayDir     (10 anh X-quang)" -ForegroundColor Gray
Write-Host "  - $clinicalDir (10 anh lam sang)" -ForegroundColor Gray
Write-Host "  - $generalDir  (10 anh COCO)" -ForegroundColor Gray
Write-Host ""
Write-Host "LUU Y: Neu anh y te nao tai that bai, co the tai thu cong tu:" -ForegroundColor Yellow
Write-Host "  - Wikimedia Commons: https://commons.wikimedia.org" -ForegroundColor Yellow
Write-Host "  - ISIC Archive: https://www.isic-archive.com" -ForegroundColor Yellow
Write-Host "  - NIH Chest X-ray: https://nihcc.app.box.com/v/ChestXray-NIHCC" -ForegroundColor Yellow
