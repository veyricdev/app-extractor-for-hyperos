param(
    [string]$RomFile,
    [string]$Partition = "system_ext"
)

# === PHAN 1: TIM FILE ROM ===
if (-not $RomFile) {
    if (Test-Path "payload.bin") {
        $RomFile = "payload.bin"
    } else {
        $zipFiles = Get-ChildItem -Filter "*.zip"
        if ($zipFiles.Count -eq 0) {
            Write-Error "Khong tim thay file .zip hoac payload.bin nao!"
            exit
        }
        $RomFile = $zipFiles[0].Name
    }
}

$7z_path = "C:\Program Files\7-Zip\7z.exe"
if (-not (Test-Path $7z_path)) {
    if (Get-Command "7z.exe" -ErrorAction SilentlyContinue) {
        $7z_path = "7z.exe"
    } else {
        Write-Error "Bat buoc phai cai dat 7-Zip!"
        exit
    }
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  MAY QUET SIEU TOC DO TIM KIEM DANH SACH APK " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Dang kiem tra o dia: $Partition" -ForegroundColor Yellow
Write-Host " Tu file ROM        : $RomFile" -ForegroundColor Yellow

if (Test-Path "extract_files") { Remove-Item -Recurse -Force "extract_files" }
if (-not (Test-Path "payload.bin") -and $RomFile -like "*.zip") {
    Write-Host "[1/3] Trich xuat payload.bin..."
    & $7z_path e $RomFile "payload.bin" -o"." -y | Out-Null
}

Write-Host "[2/3] Xar phan vung $Partition.img..."
.\payload-dumper-go.exe -p $Partition -o extract_files payload.bin

Write-Host "[3/3] Dung 7-Zip quet toan bo danh sach APK..."
$outDir = "apk_lists"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory $outDir | Out-Null }
$outputFile = "$outDir\Danh_Sach_APK_$Partition.txt"
& $7z_path l "extract_files\$Partition.img" -r "*.apk" | Select-String ".apk" > $outputFile

Write-Host ""
Write-Host "DA XUAT BAO CAO THANH CONG RA FILE:" -ForegroundColor Green
Write-Host "--> $outputFile" -ForegroundColor White
Write-Host ""
Write-Host "Ban hay mo file TXT day len de xem ten goc cua the loai App ma ban tim theo dung o dia nhe." -ForegroundColor Yellow
Write-Host "Don dep rac..."
if ((Test-Path "payload.bin") -and $RomFile -like "*.zip") { Remove-Item "payload.bin" -Force }
Remove-Item -Recurse -Force "extract_files"
Write-Host "KHOA HOC DA HOAN TAT!" -ForegroundColor Cyan
