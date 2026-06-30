# Script tải ảnh test từ Unsplash (miễn phí, không cần API key)
# Chạy: powershell -ExecutionPolicy Bypass -File download_images.ps1

$baseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$urbanDir = Join-Path $baseDir "images\urban"
$humanDir = Join-Path $baseDir "images\human"
$foodDir  = Join-Path $baseDir "images\food"

# Tạo thư mục nếu chưa có
New-Item -ItemType Directory -Force -Path $urbanDir, $humanDir, $foodDir | Out-Null

# ===== URBAN (Phong cảnh đô thị) =====
$urbanImages = @(
    @{ Name="urban_01.jpg"; Url="https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=800&q=80" },  # City skyline
    @{ Name="urban_02.jpg"; Url="https://images.unsplash.com/photo-1514565131-fce0801e5785?w=800&q=80" },  # Night city
    @{ Name="urban_03.jpg"; Url="https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&q=80" },  # City street
    @{ Name="urban_04.jpg"; Url="https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=800&q=80" },  # Buildings
    @{ Name="urban_05.jpg"; Url="https://images.unsplash.com/photo-1444723121867-7a241cacace9?w=800&q=80" },  # Bridge city
    @{ Name="urban_06.jpg"; Url="https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=800&q=80" },  # Urban park
    @{ Name="urban_07.jpg"; Url="https://images.unsplash.com/photo-1517732306149-e8f829eb588a?w=800&q=80" },  # Train station
    @{ Name="urban_08.jpg"; Url="https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=800&q=80" },  # Modern architecture
    @{ Name="urban_09.jpg"; Url="https://images.unsplash.com/photo-1518391846015-55a9cc003b25?w=800&q=80" },  # Traffic road
    @{ Name="urban_10.jpg"; Url="https://images.unsplash.com/photo-1476231682828-37e571bc172f?w=800&q=80" }   # Rainy street
)

# ===== HUMAN (Hoạt động con người) =====
$humanImages = @(
    @{ Name="human_01.jpg"; Url="https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800&q=80" },  # Person running
    @{ Name="human_02.jpg"; Url="https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80" },  # Group of friends
    @{ Name="human_03.jpg"; Url="https://images.unsplash.com/photo-1511988617509-a57c8a288659?w=800&q=80" },  # People working
    @{ Name="human_04.jpg"; Url="https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800&q=80" },  # Person cooking
    @{ Name="human_05.jpg"; Url="https://images.unsplash.com/photo-1461896836934-bd45ba8fcbdb?w=800&q=80" },  # Person with phone
    @{ Name="human_06.jpg"; Url="https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=800&q=80" },  # Group studying
    @{ Name="human_07.jpg"; Url="https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&q=80" },  # Person exercising
    @{ Name="human_08.jpg"; Url="https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=800&q=80" },  # Child playing
    @{ Name="human_09.jpg"; Url="https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800&q=80" },  # People in office
    @{ Name="human_10.jpg"; Url="https://images.unsplash.com/photo-1506869640319-fe1a24fd76cb?w=800&q=80" }   # Person reading
)

# ===== FOOD (Bữa ăn / Đồ vật) =====
$foodImages = @(
    @{ Name="food_01.jpg"; Url="https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80" },  # Pizza
    @{ Name="food_02.jpg"; Url="https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&q=80" },  # Pancakes breakfast
    @{ Name="food_03.jpg"; Url="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80" },  # Salad bowl
    @{ Name="food_04.jpg"; Url="https://images.unsplash.com/photo-1488477181946-6428a0291777?w=800&q=80" },  # Fruits
    @{ Name="food_05.jpg"; Url="https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80" },  # Grilled food
    @{ Name="food_06.jpg"; Url="https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=800&q=80" },  # Eggs toast
    @{ Name="food_07.jpg"; Url="https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800&q=80" },  # Coffee cup
    @{ Name="food_08.jpg"; Url="https://images.unsplash.com/photo-1563379926898-05f4575a45d8?w=800&q=80" },  # Pasta
    @{ Name="food_09.jpg"; Url="https://images.unsplash.com/photo-1551024601-bec78aea704b?w=800&q=80" },  # Donuts
    @{ Name="food_10.jpg"; Url="https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&q=80" }   # Food platter
)

function Download-Images($images, $dir, $category) {
    $count = 0
    foreach ($img in $images) {
        $count++
        $dest = Join-Path $dir $img.Name
        if (Test-Path $dest) {
            Write-Host "  [SKIP] $($img.Name) da ton tai" -ForegroundColor Yellow
            continue
        }
        Write-Host "  [$count/10] Dang tai $($img.Name)..." -ForegroundColor Cyan -NoNewline
        try {
            Invoke-WebRequest -Uri $img.Url -OutFile $dest -TimeoutSec 30
            Write-Host " OK" -ForegroundColor Green
        } catch {
            Write-Host " THAT BAI: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host "`n===== TAI ANH TEST =====" -ForegroundColor Magenta
Write-Host "`n[1/3] Phong canh do thi (urban)..." -ForegroundColor White
Download-Images $urbanImages $urbanDir "urban"

Write-Host "`n[2/3] Hoat dong con nguoi (human)..." -ForegroundColor White
Download-Images $humanImages $humanDir "human"

Write-Host "`n[3/3] Bua an / Do vat (food)..." -ForegroundColor White
Download-Images $foodImages $foodDir "food"

Write-Host "`n===== HOAN TAT! =====" -ForegroundColor Green
Write-Host "Tong cong: 30 anh trong 3 thu muc" -ForegroundColor White
Write-Host "  - $urbanDir"
Write-Host "  - $humanDir"
Write-Host "  - $foodDir"
