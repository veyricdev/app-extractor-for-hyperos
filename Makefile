IMAGE_NAME = app-rom-extractor
ROM_FILE ?= $(firstword $(wildcard *.zip))
APP ?= Settings.apk
PARTITION ?= system_ext

.PHONY: help build extract clean prune shutdown

help:
	@echo "--------------------------------------------------------"
	@echo "                MENU TỰ ĐỘNG HÓA TRÍCH XUẤT APK                  "
	@echo "--------------------------------------------------------"
	@echo "  make build                : Build sẵn môi trường Docker ảo"
	@echo "  make extract              : Tự động lấy ngẫu nhiên 1 file .zip có ở đây và trích xuất"
	@echo "  make extract ROM=file.zip : Chỉ định đích danh một file .zip cần giải nén"
	@echo "                              (Hỗ trợ thêm tuỳ chọn: APP=... PARTITION=...)"
	@echo "  make clean                : Xóa file hệ thống rác tạm (Giữ lại file sản phẩm APK)"
	@echo "  make prune                : Lệnh mạnh xóa sạch rác của Docker trên ổ C"
	@echo "  make shutdown             : Tắt lõi WSL ngầm để hoàn lại RAM lập tức"
	@echo "--------------------------------------------------------"

build:
	docker build -t $(IMAGE_NAME) .

extract:
ifeq ($(ROM_FILE),)
	$(error Lỗi: Hiện không tìm thấy file có đuôi .zip nào trong thư mục. Hãy copy một ROM vào đã nhé!)
endif
	@echo "====> Quá trình đang thiết lập ROM: $(ROM_FILE) (App: $(APP) - Phân vùng: $(PARTITION)) <===="
	docker run --rm --privileged -v "$(CURDIR):/workspace" $(IMAGE_NAME) bash -c "dos2unix extract.sh && bash extract.sh -f \"$(ROM_FILE)\" -p \"$(PARTITION)\" -a \"$(APP)\""

clean:
	-rm -rf extract_files payload.bin
	@echo "Đã dọn dẹp xong dung lượng bẩn. Tổ ấm APKs được an toàn!"

prune:
	docker system prune -a -f

shutdown:
	wsl --shutdown
