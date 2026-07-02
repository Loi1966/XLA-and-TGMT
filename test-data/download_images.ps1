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
    @{ Name="clinical_03.jpg"; Url="https://images.unsplash.com/photo-1631217868264-e5b90bb7e133?w=800&q=80" },  # Bác sĩ tư vấn bệnh nhân
    @{ Name="clinical_04.jpg"; Url="https://images.unsplash.com/photo-1585435557343-3b092031a831?w=800&q=80" }, # Thuốc / vật tư y tế
    @{ Name="clinical_05.jpg"; Url="https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=800&q=80" }, # Kính hiển vi phòng lab
    @{ Name="clinical_06.jpg"; Url="https://images.unsplash.com/photo-1505751172876-fa1923c5c528?w=800&q=80" }, # Ống nghe (stethoscope)
    @{ Name="clinical_07.jpg"; Url="https://images.unsplash.com/photo-1607619056574-7b8d3ee536b2?w=800&q=80" }, # Thuốc viên các loại
    @{ Name="clinical_08.jpg"; Url="https://images.unsplash.com/photo-1504439468489-c8920d796a29?w=800&q=80" }, # Thiết bị y tế / phòng phẫu thuật
    @{ Name="clinical_09.jpg"; Url="https://images.unsplash.com/photo-1584515933487-779824d29309?w=800&q=80" }, # Bác sĩ với bệnh nhân
    @{ Name="clinical_10.jpg"; Url="https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&q=80" }  # Scan y tế
)

# Nguồn: Unsplash (miễn phí, không cần API key) - Ảnh y tế tổng quát (ống nghe, ống nghiệm, thuốc, phòng khám)
$generalImages = @(
    @{ Name="general_01.jpg"; Url="https://images.unsplash.com/photo-1576671081837-49000212a370?w=800&q=80" },  # Lọ thuốc thủy tinh
    @{ Name="general_02.jpg"; Url="https://images.unsplash.com/photo-1559757175-0eb30cd8c063?w=800&q=80" },  # Mô hình não
    @{ Name="general_03.jpg"; Url="https://images.unsplash.com/photo-1628348068343-c6a848d2b6dd?w=800&q=80" },  # Thiết bị/máy tính bảng y tế
    @{ Name="general_04.jpg"; Url="https://images.unsplash.com/photo-1516549655169-df83a0774514?w=800&q=80" },  # Phòng mổ
    @{ Name="general_05.jpg"; Url="https://images.unsplash.com/photo-1603398938378-e54eab446dde?w=800&q=80" },  # Ống nghe và nhiệt kế
    @{ Name="general_06.jpg"; Url="https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=800&q=80" },  # Pipette và ống nghiệm
    @{ Name="general_07.jpg"; Url="https://images.unsplash.com/photo-1551190822-a9333d879b1f?w=800&q=80" },  # Ca phẫu thuật
    @{ Name="general_08.jpg"; Url="https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=800&q=80" },  # Viên thuốc màu cam
    @{ Name="general_09.jpg"; Url="https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=800&q=80" },  # Quầy lễ tân bệnh viện
    @{ Name="general_10.jpg"; Url="https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&q=80" }   # Các vỉ thuốc
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
