param(
    [string]$InputFile
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " TIA X: NOI SOI BEN TRONG PAYLOAD ROM  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Kiem tra/tai cong cu payload-dumper-go giong voi phan extract hien tai
if (-not (Test-Path "payload-dumper-go.exe")) {
    Write-Host "[*] Dang tai engine payload-dumper-go..." -ForegroundColor Yellow
    $dl_url = "https://github.com/ssut/payload-dumper-go/releases/download/1.2.2/payload-dumper-go_1.2.2_windows_amd64.tar.gz"
    $dl_file = "payload-dumper-win.tar.gz"
    try {
        Invoke-WebRequest -Uri $dl_url -OutFile $dl_file
        New-Item -ItemType Directory "temp_dumper" -Force | Out-Null
        tar -xzf $dl_file -C "temp_dumper"
        Move-Item "temp_dumper\payload-dumper-go.exe" ".\" -Force
        Remove-Item "temp_dumper" -Recurse -Force
        Remove-Item $dl_file -Force
        Write-Host "--> Engine san sang!" -ForegroundColor Green
    } catch {
        Write-Error "Khong the tai tool tu dong."
        exit
    }
}

# 2. Tim kiem file dich de quet
if (-not $InputFile) {
    if (Test-Path "payload.bin") {
        $InputFile = "payload.bin"
    } else {
        $zipFiles = Get-ChildItem -Filter "*.zip"
        if ($zipFiles.Count -gt 0) {
            $InputFile = $zipFiles[0].Name
        } else {
            Write-Error "Khong the tim thay file payload.bin hoac bat ky file .zip nao trong thu muc!"
            exit
        }
    }
}

if (-not (Test-Path $InputFile)) {
    Write-Error "File khong ton tai: $InputFile"
    exit
}

Write-Host "`n[*] Dang chup X-Quang file: $InputFile" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Cyan

# 3. Quet vach ngan
# Cong cu payload-dumper-go ho tro doc truc tiep tu ca payload.bin lan viec tich xuat xuyen qua file .zip
.\payload-dumper-go.exe -l $InputFile

Write-Host "----------------------------------------" -ForegroundColor Cyan
Write-Host "HOAN TAT!" -ForegroundColor Green
