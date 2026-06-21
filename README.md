# Fuck-Proxy

## Cài đặt trên VPS Ubuntu (Bản tối ưu)
Chạy lệnh sau trên VPS của bạn dưới quyền root:
```bash
bash <(curl -Ls https://raw.githubusercontent.com/teetan003/Fuck-Proxy/main/install_ubuntu_optimized.sh)
```

## Tính năng tự động xoay IPv6 (IPv6 Rotation)
Dự án có đi kèm script `ipv6_rotate.sh` giúp tự động sinh và thay đổi IPv6 liên tục để tránh bị block.

**Cách cài đặt:**
1. Tải script về VPS:
```bash
wget https://raw.githubusercontent.com/teetan003/Fuck-Proxy/main/ipv6_rotate.sh
chmod +x ipv6_rotate.sh
```
2. Mở file `ipv6_rotate.sh` lên bằng lệnh `nano ipv6_rotate.sh` và sửa lại 2 thông số cho đúng với VPS của bạn:
   - `PREFIX`: Điền dải IPv6 prefix của bạn (ví dụ: `2001:0db8:1234:5678`)
   - `INTERFACE`: Điền tên cổng mạng của bạn (ví dụ: `eth0`)
3. Chạy thử thủ công bằng lệnh `./ipv6_rotate.sh` và kiểm tra xem VPS đã nhận IPv6 mới chưa (`ip -6 a`).
4. Nếu thành công, thiết lập Cronjob để script tự chạy mỗi 5 phút:
```bash
crontab -e
```
Thêm dòng sau vào cuối file:
```text
*/5 * * * * /root/ipv6_rotate.sh >> /var/log/ipv6_rotate.log 2>&1
```
