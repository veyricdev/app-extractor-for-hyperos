param(
    [string]$RomFile,
    [string]$Partition = "system_ext",
    [string]$App = "Settings.apk"
)

# === PHAN 1: TU DONG TIM FILE VA KIEM TRA ===
if (-not $RomFile) {
    $zipFiles = Get-ChildItem -Filter "*.zip"
    if ($zipFiles.Count -eq 0) {
        Write-Error "Khong tim thay file .zip nao!"
        exit
    }
    $RomFile = $zipFiles[0].Name
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

if (-not (Test-Path "payload-dumper-go.exe")) {
    Write-Host ""
    Write-Host "[*] Dang tu dong tai payload-dumper-go..." -ForegroundColor Yellow
    $dl_url = "https://github.com/ssut/payload-dumper-go/releases/download/1.2.2/payload-dumper-go_1.2.2_windows_amd64.tar.gz"
    $dl_file = "payload-dumper-win.tar.gz"
    
    try {
        Invoke-WebRequest -Uri $dl_url -OutFile $dl_file
        New-Item -ItemType Directory "temp_dumper" -Force | Out-Null
        tar -xzf $dl_file -C "temp_dumper"
        Move-Item "temp_dumper\payload-dumper-go.exe" ".\" -Force
        Remove-Item "temp_dumper" -Recurse -Force
        Remove-Item $dl_file -Force
        Write-Host "--> Da thiet lap xong Engine!" -ForegroundColor Green
    } catch {
        Write-Error "Loi tai payload-dumper. Hay tai thu cong."
        exit
    }
}

# === PHAN 2: PHAN TICH TEN ===
$fileName = [System.IO.Path]::GetFileNameWithoutExtension($RomFile)
$parts = $fileName.Split("_")
if ($parts.Length -lt 3) {
    Write-Error "Ten ROM khong dung dinh dang..."
    exit
}
$codename = $parts[1]
$version = $parts[2]

Write-Host "====================================" -ForegroundColor Cyan
Write-Host " ROM SETTINGS APK EXTRACTOR (WIN NATIVE) " -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host " Xu ly: $RomFile"
Write-Host " May  : $codename"
Write-Host " Ban  : $version"
Write-Host "------------------------------------" -ForegroundColor Cyan

# === PHAN 3: BAT DAU QUA TRINH ===
Write-Host "[*] Dang don dep rac cu..."
if (Test-Path "payload.bin") { Remove-Item "payload.bin" -Force }
if (Test-Path "extract_files") { Remove-Item -Recurse -Force "extract_files" }
if (-not (Test-Path "settings_apks")) { New-Item -ItemType Directory "settings_apks" | Out-Null }

Write-Host "[1/4] Dang trich xuat payload.bin..."
& $7z_path e $RomFile "payload.bin" -o"." -y | Out-Null

if (-not (Test-Path "payload.bin")) {
    Write-Error "Loi: Trich xuat payload.bin that bai!"
    exit
}

Write-Host "[2/4] Dang dung payload-dumper xar $Partition..."
.\payload-dumper-go.exe -p $Partition -o extract_files payload.bin

Write-Host "[3/4] Dung 7-zip cat ra $App..."
New-Item -ItemType Directory "extract_files\mount_files" -Force | Out-Null
& $7z_path e "extract_files\$Partition.img" $App -r -o"extract_files\mount_files" -y | Out-Null

$baseAppName = [System.IO.Path]::GetFileNameWithoutExtension($App)
$destApkName = "${baseAppName}_${codename}_from_${version}.apk"
$destApkPath = "settings_apks\$destApkName"

if (Test-Path "extract_files\mount_files\$App") {
    Copy-Item "extract_files\mount_files\$App" -Destination $destApkPath -Force
    Write-Host ""
    Write-Host "[HOAN TAT!] Da luu tai: $destApkPath" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Error "[LOI TAM TRONG] Khong tim thay $App trong phan vung $Partition!"
}

Write-Host "[4/4] Don dep chien truong..."
Remove-Item "payload.bin" -Force
Remove-Item -Recurse -Force "extract_files"
Write-Host "XONG!" -ForegroundColor Cyan
