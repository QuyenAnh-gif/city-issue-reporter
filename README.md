# City Issue Reporter (CIR) - Hệ thống phản ứng sự cố đô thị thông minh

> Đồ án môn học: Lập trình thiết bị di động  
> Giảng viên hướng dẫn: **TS. Nguyễn Thị Bích Ngân**  
> Sinh viên thực hiện (Đồ án cá nhân): **Võ Quyền Anh**  
> Phát triển bằng: **Flutter** & **Firebase**

## Giới thiệu

**City Issue Reporter** là ứng dụng di động đóng vai trò là cầu nối kỹ thuật số giữa người dân và ban quản lý đô thị. Ứng dụng cho phép công dân báo cáo nhanh chóng các sự cố hạ tầng (ổ gà, rác thải, ngập nước...) kèm theo định vị GPS và hình ảnh thực tế.

## Tính năng nổi bật

- **Báo cáo sự cố định vị:** Tự động lấy tọa độ GPS hiện tại hoặc chọn vị trí trên Google Maps.
- **Đa phương tiện:** Hỗ trợ chụp ảnh trực tiếp hoặc chọn nhiều ảnh từ thư viện hiện trường.
- **Cứu hộ khẩn cấp (SOS):** Gọi nhanh cho các đường dây nóng (Cứu hỏa, Cảnh sát, Y tế, Điện lực).
- **Gamification (Hệ thống điểm Karma):** Tích lũy điểm thưởng và vinh danh "Hiệp sĩ đô thị" trên bảng xếp hạng khi tích cực báo cáo.
- **Bảng điều khiển Admin:** Phân quyền quản trị viên, duyệt trạng thái sự cố và lọc bài đăng rác (Spam).

## Công nghệ sử dụng

- **Frontend:** Flutter / Dart
- **Backend:** Firebase Authentication, Cloud Firestore, Firebase Storage
- **Bản đồ & Định vị:** Google Maps Flutter, Geolocator, LatLong2
- **Quản lý trạng thái:** Provider / Store pattern

## Hướng dẫn cài đặt và chạy thử

1. Clone dự án về máy:
   ```bash
   git clone [https://github.com/QuyenAnh-gif/city-issue-reporter.git](https://github.com/QuyenAnh-gif/city-issue-reporter.git)
   ```
