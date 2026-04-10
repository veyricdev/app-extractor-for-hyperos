# 📱 Android Target APK Extractor

*Read this in [Tiếng Việt](README-vi.md)*

A streamlined tool to automatically extract *any* desired `.apk` (such as Settings, Security, etc.) from Android OTA Payload ROMs. This project provides **two parallel operation methods**: a **Docker** version for the Linux ecosystem and a **Native Windows (PowerShell)** version that is extremely friendly for non-technical users.

## ✨ Key Features

- Independent multi-platform support: Run natively on **Windows**, natively on **Linux**, or via a **Docker Container** (Optimised for macOS).
- Automatically extracts `.zip` ROMs to get `payload.bin`.
- Supports targeted unpacking of any partition (`system`, `system_ext`, `product`, `vendor`, etc.).
- **Auto-Download Engine:** Automatically downloads `payload-dumper-go` on Windows if it doesn't exist.
- Smart recursive scanning to extract any specified APK dynamically, instantly renaming it based on the input ROM name: `{App_Name}_{codename}_from_{version}.apk`
- Smart system that automatically cleans up gigabytes of temporary virtual partition data immediately after extraction to save disk space.

---

## 📥 Preparation: Where to Get the ROM

Before running the tools, you need the official ROM file:
1. Visit [https://mifirm.net/](https://mifirm.net/).
2. Search for your specific device.
3. Download the **Recovery ROM** version. *(Note: Must be a `.zip` file! Do not download the Fastboot ROM `.tgz` as it has a different structural layout without the `payload.bin` core)*.

---



## 🚀 METHOD 1: EXTRACT ON NATIVE WINDOWS (RECOMMENDED)

This method utilizes Windows PowerShell combined with the power of **7-Zip**. You absolutely **do not need Docker** or virtual machine knowledge, and you won't have to worry about sudden C drive bloating.

### 🛠️ Requirements
- Windows 10/11 with Windows PowerShell.
- **Mandatory:** [7-Zip](https://www.7-zip.org/download.html) installed (Must be in the default location `C:\Program Files\7-Zip`).

### ⚙️ Usage (Just 1 command)
1. Place your ROM `.zip` file in this same directory (do not extract).
2. Open Terminal / PowerShell and run the following command for 100% automation:

(By default, it extracts `Settings.apk` from the `system_ext` partition)
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\extract.ps1
```

**🔥 Advanced: Extracting Custom Apps**
You can extract any app by providing command arguments:
- Example - Extracting Settings app:
  ```powershell
  powershell.exe -ExecutionPolicy Bypass -File .\extract.ps1 -Partition "system_ext" -App "Settings.apk"
  ```
- Example - Extracting Security app:
  ```powershell
  powershell.exe -ExecutionPolicy Bypass -File .\extract.ps1 -Partition "product" -App "MIUISecurityCenterGlobal.apk"
  ```

*(💡 Tip 1: If using Linux/macOS Native Bash, `extract.sh` script supports identical flags: `./extract.sh -p product -a MIUISecurityCenterGlobal.apk`)*  
*(💡 Tip 2: If you are typing this from Git Bash, make sure to change the backslash to a forward slash like `./extract.ps1`)*

The whole process of cracking the ROM -> Loading tool -> Extracting APK will run, and the final APK will be saved in the `settings_apks/` folder. Temporary files will be deleted automatically.

---

## 🐧 METHOD 2: EXTRACT ON NATIVE LINUX (BASH SCRIPT)

If you are using Linux (Ubuntu, Arch, etc.), you can run the Bash script directly without having to set up Docker containers.

### 🛠️ Requirements
- A Linux operating system.
- `unzip` installed and `payload-dumper-go` binary available in your `$PATH`.
- `sudo` privileges (required to automatically mount the virtual Android partitions internally).

### ⚙️ Usage
```bash
# Default extraction (Settings.apk)
./extract.sh

# Or extract a custom app like Security
./extract.sh -p product -a MIUISecurityCenterGlobal.apk
```
> **⚠️ Note for macOS users:** Although Macs use Bash/Zsh natively, macOS does not natively support the `mount` command for Android filesystems (ext4/erofs). Attempting to run this natively on macOS will fail. Please use Method 3 (Docker) below instead!

---

## 🐋 METHOD 3: EXTRACT VIA DOCKER (SPECIALLY FOR MACOS & WSL2)

Uses a heavily isolated environment to avoid cluttering your host machine.

### 🛠️ Requirements
1. **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** (WSL2 backend enabled).
2. **Make** command utility (Available on Git Bash, Linux/macOS).

### ⚙️ Usage
1. Keep the `.zip` file in this directory.
2. Build and create the container image architecture (Type only once):
   ```bash
   make build
   ```
3. Execute the command to automatically find the zip file and extract `Settings.apk`:
   ```bash
   make extract
   ```

**🔥 Advanced: Extracting Custom Apps via Docker**
Just like the Windows version, you can specify custom parameters and target different partitions/apps directly when calling `make extract`:
- Example - Specify a specific `.zip` file (if there are multiple in the folder):
  ```bash
  make extract ROM=your_rom_file.zip
  ```
- Example - Extract the Security app from the product partition:
  ```bash
  make extract PARTITION=product APP=MIUISecurityCenterGlobal.apk
  ```

---

## 🔍 EXTRA UTILITIES (For PowerShell)

Besides extraction, the toolkit provides two in-depth inspection scripts to analyze the ROM payload before extracting:

### 1. Identify partitions (`list-partitions.ps1`)
This command lists all the available internal partitions inside your ROM's payload (e.g., boot, system, vendor, product, system_ext...).
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\list-partitions.ps1
```
*(To enforce a specific file, append `-InputFile "filename.zip"`)*

### 2. Scan and list APKs (`list-apks.ps1`)
If you don't know the exact internal name or location of the app you're looking for, this script recursively scans a specific partition and outputs a text file list (e.g., `Danh_Sach_APK_product.txt`) for you to search through manually.
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\list-apks.ps1 -Partition "product"
```
*(Replace "product" with whichever partition you want to inspect).*

---

## 🧹 PC Rescue & Fix C Drive Bloat (For Docker Users)

Running Docker on Windows to extract virtual disks can easily cause the intermediate `ext4.vhdx` WSL file to bloat significantly without shrinking back down.

Grasp these secrets to clean up your system:

- **1. Delete all temporary/invisible files after ROM extraction (keeps the Apk):**
  ```bash
  make clean
  ```

- **2. Release all Cache occupied by Docker:**
  ```bash
  make prune
  ```
  Hard shut down the WSL2 core to force Windows to free up RAM/Storage:
  ```bash
  make shutdown
  ```

> ⚠️ **The Ultimate DiskPart Trick to shrink C Drive**:
> If your C drive has drastically lost tens of GBs, open PowerShell as **Administrator**, type `diskpart` > Select the file by typing `select vdisk file="path/to/ext4.vhdx"` > Lock the drive by typing `attach vdisk readonly` > Finally, squeeze it by typing `compact vdisk`. Your drive will be spacious again.
