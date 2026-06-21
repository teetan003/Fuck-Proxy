#!/bin/bash

# Script cài đặt x-ui (phiên bản đã tối ưu) trực tiếp từ mã nguồn cho Ubuntu/Debian

set -e

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# Kiểm tra quyền root
[[ $EUID -ne 0 ]] && echo -e "${red}Lỗi: Vui lòng chạy script này dưới quyền root (sudo) \n${plain}" && exit 1

echo -e "${green}Đang tiến hành cài đặt phiên bản 3x-ui tối ưu cho Ubuntu...${plain}"

# 1. Cài đặt các gói cần thiết (Go và các tiện ích)
echo -e "${yellow}Cài đặt các gói phụ thuộc (nếu chưa có)...${plain}"
apt-get update
apt-get install -y curl tar tzdata socat ca-certificates openssl cron
if ! command -v go &> /dev/null; then
    echo -e "${yellow}Đang cài đặt Golang...${plain}"
    apt-get install -y golang
fi

# 2. Biên dịch mã nguồn Go
echo -e "${yellow}Đang biên dịch mã nguồn 3x-ui...${plain}"
# Tối ưu hoá dung lượng file binary cho server yếu
go build -trimpath -ldflags="-s -w" -o x-ui main.go

# 3. Tạo thư mục và copy file
echo -e "${yellow}Đang copy các file vào hệ thống...${plain}"
mkdir -p /usr/local/x-ui
cp x-ui /usr/local/x-ui/
cp x-ui.sh /usr/local/x-ui/
cp x-ui.sh /usr/bin/x-ui
chmod +x /usr/local/x-ui/x-ui
chmod +x /usr/local/x-ui/x-ui.sh
chmod +x /usr/bin/x-ui

mkdir -p /var/log/x-ui
mkdir -p /etc/x-ui

# 4. Copy và kích hoạt Service Systemd (bản đã thêm Memory limits)
echo -e "${yellow}Thiết lập systemd service tối ưu (cgroups)...${plain}"
cp x-ui.service.debian /etc/systemd/system/x-ui.service
chmod 644 /etc/systemd/system/x-ui.service

systemctl daemon-reload
systemctl enable x-ui
systemctl restart x-ui

# 5. Tối ưu hoá không gian ổ đĩa (Disk Space Optimization cho VPS 10GB)
echo -e "${yellow}Đang dọn dẹp hệ thống để tiết kiệm ổ cứng...${plain}"
# Xoá Go cache
go clean -cache -modcache || true
# Gỡ cài đặt Go compiler vì không còn dùng tới nữa (giải phóng ~500MB)
apt-get purge -y golang golang-go || true
apt-get autoremove -y || true
# Xoá cache tải gói apt
apt-get clean
rm -rf /var/lib/apt/lists/*

# Cấu hình giới hạn kích thước log của systemd (giới hạn 50MB)
sed -i 's/#SystemMaxUse=/SystemMaxUse=50M/g' /etc/systemd/journald.conf
systemctl restart systemd-journald
journalctl --vacuum-size=50M > /dev/null 2>&1

echo -e "${green}═══════════════════════════════════════════${plain}"
echo -e "${green} Cài đặt hoàn tất! Phiên bản tối ưu đã chạy ${plain}"
echo -e "${green}═══════════════════════════════════════════${plain}"
echo -e "Bạn có thể sử dụng lệnh ${yellow}x-ui${plain} để quản lý panel."
echo -e "Các thông số tối ưu RAM và tối ưu Ổ ĐĨA đã được tự động áp dụng."
