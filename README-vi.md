# 📱 Android Target APK Extractor

*Đọc bằng [English](README.md)*

Một công cụ tinh gọn giúp tự động trích xuất bất kỳ ứng dụng `.apk` nào (ví dụ: Settings, Security, v.v.) từ các bản ROM Android định dạng phân vùng OTA (Payload.bin). Dự án mang đến **2 phương thức hoạt động song song**: một bản chạy qua **Docker** linh hoạt cho môi trường Linux và một bản chạy trực tiếp trên **Native Windows (PowerShell)** cực kỳ thân thiện với người dùng không chuyên. 

## ✨ Tính Năng Nổi Bật

- Hỗ trợ độc lập đa nền tảng: Chạy **Thuần Windows**, **Thuần Linux** hoặc kết hợp **Cỗ máy ảo Docker** (Giải pháp tuyệt vời cho macOS).
- Tự động quét và xẻ thịt ROM `.zip` để lấy `payload.bin`.
- Hỗ trợ linh động giải nén mọi phân vùng hệ thống (`system`, `system_ext`, `product`, `vendor`...).
- **Tự động tải Engine:** Công cụ `payload-dumper-go` sẽ được tự động tải về bổ sung nếu trên máy Windows gốc chưa tồn tại.
- Truy xuất thông minh bất kỳ file `.apk` nào được yêu cầu chỉ bằng tên, và đổi tên tệp chuẩn hóa ngay theo bản ROM đầu vào: `{Tên_App}_{codename}_from_{version}.apk` 
- Hệ thống tự dọn rác dọn sạch vài chục GB phân vùng ảo vứt đi lập tức sau khi trích xuất nhằm giải phóng dung lượng ổ cứng.

---

## 📥 Chuẩn Bị: Cách Lấy Nguồn ROM

Trước khi chạy tool, bạn cần tải hệ điều hành ROM chính thức về:
1. Vào trang web [https://mifirm.net/](https://mifirm.net/).
2. Đánh tên/mã thiết bị của bạn vào ô tìm kiếm.
3. Chuyển sang bảng để tải bản **Recovery ROM**. *(Lưu ý: Bắt buộc là đuôi `.zip`! Vui lòng đừng tải lộn bản Fastboot `.tgz` vì nó là bản đã bị bung lõi `payload.bin`, tool tự động này sẽ không định dạng được)*.

---

## 🚀 CÁCH 1: GIẢI NÉN THUẦN TRÊN WINDOWS NATIVE (KHUYÊN DÙNG)

Phương thức này ép hệ thống PowerShell của Windows kết hợp với sức mạnh của **7-Zip** làm việc, bạn hoàn toàn **không cần Docker** hay kiến thức máy ảo, không lo việc đầy dung lượng ổ C đột ngột.

### 🛠️ Yêu Cầu
- Máy dùng Windows 10/11 có sẵn Windows PowerShell.
- **Bắt buộc** có phần mềm [7-Zip](https://www.7-zip.org/download.html) đã cài trên máy (Phải nằm trong vị trí mặc định `C:\Program Files\7-Zip`).

### ⚙️ Cách Chạy (Chỉ 1 lệnh)
1. Hãy ném file hệ điều hành ROM `.zip` của bạn vào cùng thư mục này (không giải nén).
2. Mở Terminal / PowerShell và dọn thẳng dòng lệnh sau để uỷ quyền tự động 100%:

(Mặc định tool sẽ tìm và lấy `Settings.apk` ở phân vùng `system_ext`)
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\extract.ps1
```

**🔥 Mở rộng: Trích xuất App tùy chỉnh**
Bạn có thể trích xuất bất kỳ ứng dụng nào bằng cách truyền thêm tham số lệnh:
- Ví dụ - Lấy ứng dụng Settings gốc:
  ```powershell
  powershell.exe -ExecutionPolicy Bypass -File .\extract.ps1 -Partition "system_ext" -App "Settings.apk"
  ```
- Ví dụ - Lấy ứng dụng Bảo mật (Security):
  ```powershell
  powershell.exe -ExecutionPolicy Bypass -File .\extract.ps1 -Partition "product" -App "MIUISecurityCenterGlobal.apk"
  ```

*(💡 Mẹo 1: Nếu bạn dùng hệ thống Linux/macOS và mở bằng Terminal Bash, script `extract.sh` kèm theo cũng tự hào hỗ trợ cú pháp lệnh y hệt: `./extract.sh -p product -a MIUISecurityCenterGlobal.apk`)*  
*(💡 Mẹo 2: Nếu bạn đang gõ lệnh từ cửa sổ của phần mềm Git Bash, hãy chú ý đổi chiều thanh gạch chéo thành `./extract.ps1` nha)*

Toàn bộ quá trình cắt ROM -> Load tool -> Lấy APK sẽ chạy và lưu APK thành quả vào mục `settings_apks/`. Rác đệm sẽ tự được xoá.

---

## 🐧 CÁCH 2: GIẢI NÉN THUẦN TRÊN NATIVE LINUX (BASH SCRIPT)

Nếu bạn là người dùng Linux (Ubuntu, Arch, v.v.), bạn có thể chạy trực tiếp script Bash mà không cần phải gọi ảo hoá Docker.

### 🛠️ Yêu Cầu
- Máy tính chạy hệ điều hành Linux.
- Đã cài lệnh `unzip` và công cụ `payload-dumper-go` trên máy.
- Tài khoản có quyền `sudo` (vì script cần dùng tính năng `mount` để đọc phân vùng Android ảo).

### ⚙️ Cách Chạy
```bash
# Lấy file Settings mặc định
./extract.sh

# Hoặc tùy biến App Security
./extract.sh -p product -a MIUISecurityCenterGlobal.apk
```
> **⚠️ Lưu ý cho người dùng macOS:** Mặc dù máy Mac có Terminal và gõ được lệnh Bash, hệ điều hành macOS không hỗ trợ lệnh `mount` các định dạng ảnh đĩa hệ thống Android (như ext4/erofs) thuần tủy. Xin mời bạn chuyển xuống dùng Cách 3 (Docker) phía dưới!

---

## 🐋 CÁCH 3: GIẢI NÉN QUA DOCKER (ĐẶC BIỆT DÀNH CHO MACOS & WSL2)

Sử dụng môi trường cách ly mạnh mẽ để tránh xả rác phần mềm lên máy chủ.

### 🛠️ Yêu Cầu
1. Cần cài đặt **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** (Bật backend WSL2).
2. Lệnh tắt tiện ích **Make** (Sẵn có trên Git Bash, Linux/macOS).

### ⚙️ Cách Chạy
1. Vẫn đặt file `.zip` chung thư mục này.
2. Build và tạo nền kiến trúc image chạy ẩn (Chỉ gõ lần đầu):
   ```bash
   make build
   ```
3. Khởi lệnh tự động tìm file zip và trích xuất `Settings.apk`:
   ```bash
   make extract
   ```

**🔥 Mở rộng: Trích xuất bằng Docker với tùy chọn tuỳ chỉnh**
Giống như câu lệnh của bản Windows, bạn hoàn toàn có thể trích xuất các phân vùng và app tùy thích thông qua việc truyền biến nối tiếp ngay sau lệnh `make extract`:
- Ví dụ - Chỉ định rõ tên file `.zip` (khi bạn có nhiều file trong thư mục):
  ```bash
  make extract ROM=ten_file_rom.zip
  ```
- Ví dụ - Lấy ứng dụng Bảo mật (Security) ở phân vùng product:
  ```bash
  make extract PARTITION=product APP=MIUISecurityCenterGlobal.apk
  ```

---

## 🔍 TIỆN ÍCH MỞ RỘNG (Dành cho Cửa sổ PowerShell)

Bên cạnh giải nén, bộ công cụ cung cấp thêm 2 tính năng soi chiếu chuyên sâu file ROM trước khi bạn bấm nút trích xuất:

### 1. Soi danh sách phân vùng (`list-partitions.ps1`)
Lệnh này cho bạn biết bên trong file ZIP hoặc payload.bin của ROM hiện đang chứa những phân vùng nào (ví dụ: boot, system, vendor, product, system_ext...).
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\list-partitions.ps1
```
*(Nếu muốn kiểm tra cứng một file cụ thể, thêm tham số `-InputFile "ten_file.zip"`)*

### 2. Quét xuất danh sách APK (`list-apks.ps1`)
Nếu bạn không biết tên chính xác ứng dụng bạn cần tìm (hiện tên là gì và nằm trong phân vùng nào), script này sẽ quét toàn bộ phân vùng nội tại và tạo ra một file text cho bạn tra cứu thủ công bằng mắt (VD: `Danh_Sach_APK_product.txt`).
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\list-apks.ps1 -Partition "product"
```
*(Thay thế "product" bằng bất kì tên phân vùng nào vừa được dò ra ở Lệnh 1 bạn muốn soi).*

---

## 🧹 Cứu Hộ Máy Tính & Fix Tràn Ổ C (Cho người dùng Docker)

Việc chạy Docker trên Windows để xả ổ đĩa ảo dễ khiến file trung gian `ext4.vhdx` của hệ điều hành Windows phình lên cực lớn nhưng không xẹp đi.

Nắm trọn bí kíp sau để dọn dẹp nhà cửa:

- **1. Xoá mọi rác tàn hình, tàn dư sau khi bóc ROM (giữ lại Apk):**
  ```bash
  make clean
  ```

- **2. Nhả lại toàn bộ Cấu hình Cache bị Docker ép chiếm:**
  ```bash
  make prune
  ```
  Tắt nóng toàn bộ lõi nhân WSL2 để ép Windows trả lại RAM:
  ```bash
  make shutdown
  ```

> ⚠️ **Bí kíp DiskPart thần thánh bóp ổ C**:
> Nếu ổ C của bạn thất thoát kịch liệt vài chục GB, hãy mở PowerShell bằng **Quyền Administrator**, gõ `diskpart` > Gõ chọn file `select vdisk file="đường/dẫn/đến/ext4.vhdx"` > Gõ khoá ổ cứng bằng lệnh `attach vdisk readonly` > Và cuối cùng gõ lệnh vắt kiệt mỡ: `compact vdisk`. Ổ máy tính của bạn sẽ rộng thênh thang trở lại.
