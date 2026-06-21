#!/bin/bash

# Script Cài đặt Public Web Panel cho Fuck-Proxy

set -e

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

[[ $EUID -ne 0 ]] && echo -e "${red}Lỗi: Vui lòng chạy script này dưới quyền root \n${plain}" && exit 1

echo -e "${green}Đang tiến hành cài đặt Public Web Panel...${plain}"

# 1. Cài đặt Python3 (nếu chưa có)
apt-get update
apt-get install -y python3 curl

# 2. Tạo thư mục chứa Panel
echo -e "${yellow}Tạo thư mục cho Panel tại /usr/local/public_panel...${plain}"
mkdir -p /usr/local/public_panel
cd /usr/local/public_panel

# 3. Tải giao diện web
echo -e "${yellow}Tải giao diện Web (index.html)...${plain}"
wget -4 -qO index.html "https://raw.githubusercontent.com/teetan003/Fuck-Proxy/main/public_panel/index.html" || curl -4 -sLo index.html "https://raw.githubusercontent.com/teetan003/Fuck-Proxy/main/public_panel/index.html"

# 4. Yêu cầu nhập Proxy Link
echo -e ""
echo -e "${green}Vui lòng dán Link Proxy (VLESS/VMESS) mà bạn muốn chia sẻ cho người dùng:${plain}"
read -p "Link Proxy: " proxy_link < /dev/tty || proxy_link="Chưa thiết lập link"

# Tạo config.json
cat > config.json <<EOF
{
    "proxy_link": "$proxy_link"
}
EOF

# 5. Tạo Systemd Service để chạy Python Web Server ngầm ở port 8080
echo -e "${yellow}Thiết lập dịch vụ chạy ngầm trên cổng 8080...${plain}"
cat > /etc/systemd/system/fuckproxy-panel.service <<EOF
[Unit]
Description=FuckProxy Public Web Panel
After=network.target

[Service]
User=root
WorkingDirectory=/usr/local/public_panel
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable fuckproxy-panel
systemctl restart fuckproxy-panel

echo -e "${green}═══════════════════════════════════════════${plain}"
echo -e "${green} Cài đặt Web Panel hoàn tất! ${plain}"
echo -e "Bạn có thể truy cập bằng trình duyệt tại:"
echo -e "${yellow} http://$(curl -s4 ip.sb):8080 ${plain}"
echo -e "Lưu ý: Bạn phải mở khoá (allow) cổng 8080 trên VPS Firewall (nếu có)."
echo -e "${green}═══════════════════════════════════════════${plain}"
