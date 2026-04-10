#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

cd "$(dirname "$0")"

ROM_FILE=""
PARTITION="system_ext"
APP_NAME="Settings.apk"

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--file) ROM_FILE="$2"; shift ;;
        -p|--partition) PARTITION="$2"; shift ;;
        -a|--app) APP_NAME="$2"; shift ;;
        *) ROM_FILE="$1" ;; # support positional argument for zip file
    esac
    shift
done

# === PHAN 1: TU DONG TIM FILE VA KIEM TRA ===
if [ -z "$ROM_FILE" ]; then
    for f in *.zip; do
        if [ -f "$f" ]; then
            ROM_FILE="$f"
            break
        fi
    done
    
    if [ -z "$ROM_FILE" ]; then
        echo "Khong tim thay file .zip nao!"
        exit 1
    fi
fi

if ! command -v payload-dumper-go &> /dev/null; then
    echo "Loi: payload-dumper-go chua duoc cai dat hoac khong co trong PATH."
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "Loi: lenh 'unzip' chua duoc cai dat!"
    exit 1
fi

# === PHAN 2: PHAN TICH TEN ===
file_name=$(basename "$ROM_FILE" .zip)
IFS=_ read -ra arr <<< "$file_name"
if [ ${#arr[@]} -lt 3 ]; then
    echo "Ten ROM khong dung dinh dang..."
    exit 1
fi
codename="${arr[1]}"
version="${arr[2]}"

echo -e "\e[36m====================================\e[0m"
echo -e "\e[36m ROM SETTINGS APK EXTRACTOR (LINUX) \e[0m"
echo -e "\e[36m====================================\e[0m"
echo " Xu ly: $ROM_FILE"
echo " May  : $codename"
echo " Ban  : $version"
echo -e "\e[36m------------------------------------\e[0m"

# === PHAN 3: BAT DAU QUA TRINH ===
echo "[*] Dang don dep rac cu..."
[ -f "payload.bin" ] && rm "payload.bin"
[ -d "extract_files" ] && sudo rm -rf "extract_files"
mkdir -p settings_apks

echo "[1/4] Dang trich xuat payload.bin..."
unzip -q "$ROM_FILE" payload.bin

if [ ! -f "payload.bin" ]; then
    echo "Loi: Trich xuat payload.bin that bai!"
    exit 1
fi

echo "[2/4] Dang dung payload-dumper-go xar $PARTITION..."
payload-dumper-go -p "$PARTITION" -o extract_files payload.bin

echo "[3/4] Dung mount cat ra $APP_NAME..."
mkdir -p extract_files/mount_files
sudo mount -o ro "./extract_files/$PARTITION.img" ./extract_files/mount_files

# Tim file APK thay vi hardcode duong dan (giong nhu cach 7z -r hoat dong)
found_app=$(find ./extract_files/mount_files -type f -name "$APP_NAME" | head -n 1)

base_app_name="${APP_NAME%.*}"
dest_apk_name="${base_app_name}_${codename}_from_${version}.apk"
dest_apk_path="settings_apks/${dest_apk_name}"

if [ -n "$found_app" ]; then
    cp "$found_app" "$dest_apk_path"
    echo ""
    echo -e "\e[32m[HOAN TAT!] Da luu tai: $dest_apk_path\e[0m"
else
    echo ""
    echo -e "\e[31m[LOI TAM TRONG] Khong tim thay $APP_NAME trong phan vung $PARTITION!\e[0m"
fi

sudo umount ./extract_files/mount_files

echo "[4/4] Don dep chien truong..."
rm -f payload.bin
sudo rm -rf extract_files
echo -e "\e[36mXONG!\e[0m"