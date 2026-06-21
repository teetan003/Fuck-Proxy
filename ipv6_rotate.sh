#!/bin/bash

# ==========================================
# CẤU HÌNH THÔNG SỐ (VUI LÒNG SỬA TRƯỚC KHI CHẠY)
# ==========================================

# 1. Dải mạng IPv6 của bạn (Chỉ lấy phần đầu, KHÔNG chứa dấu :: ở cuối hay /64)
# Ví dụ nếu VPS cấp cho bạn IP là 2001:0db8:1234:5678::1/64
# Thì prefix là: 2001:0db8:1234:5678
PREFIX="2400:6180:0:d2"

# 2. Tên cổng mạng (Gõ lệnh 'ip a' để xem, thường là eth0, ens3, hoặc venet0)
INTERFACE="eth0"

# 3. Subnet mask (Thường là 64 hoặc 48)
SUBNET="64"

# ==========================================
# KHÔNG CHỈNH SỬA BÊN DƯỚI NẾU BẠN KHÔNG RÕ
# ==========================================

LOG_FILE="/var/tmp/last_ipv6_rotated"

# Hàm sinh ngẫu nhiên 1 block 16-bit dạng Hex (4 ký tự)
gen_block() {
    printf "%04x" "$((RANDOM % 65536))"
}

# Sinh 4 block để tạo thành 64 bit ngẫu nhiên (dành cho /64)
generate_random_ipv6() {
    echo "${PREFIX}:$(gen_block):$(gen_block):$(gen_block):$(gen_block)"
}

# 1. Đọc IP cũ đã gán từ lần trước và xoá nó đi
if [ -f "$LOG_FILE" ]; then
    old_ip=$(cat "$LOG_FILE" 2>/dev/null | tr -d '[:space:]')
    if [ -n "$old_ip" ]; then
        echo "Đang xoá IPv6 cũ: $old_ip/$SUBNET khỏi cổng $INTERFACE..."
        ip -6 addr del "$old_ip/$SUBNET" dev "$INTERFACE" 2>/dev/null || true
    fi
fi

# 2. Sinh IPv6 mới
new_ip=$(generate_random_ipv6)
echo "Đã tạo IPv6 mới: $new_ip"

# 3. Gán IPv6 mới vào cổng mạng
echo "Đang gán IPv6 mới vào cổng $INTERFACE..."
if ip -6 addr add "$new_ip/$SUBNET" dev "$INTERFACE"; then
    echo "Thành công!"
    # 4. Lưu lại IP mới vào file log để lần sau xoá
    echo "$new_ip" > "$LOG_FILE"
    
    # (Tuỳ chọn) Bạn có thể thêm lệnh restart proxy ở đây nếu cần, ví dụ:
    # systemctl restart x-ui
else
    echo "Lỗi: Không thể gán IPv6 $new_ip vào cổng mạng $INTERFACE. Vui lòng kiểm tra lại cấu hình PREFIX và INTERFACE."
    exit 1
fi
