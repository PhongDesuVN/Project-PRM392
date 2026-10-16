# MySQL Database

Các migration được tách theo phân hệ và cần chạy theo thứ tự số:

1. `migrations/001_core_dictionary.sql`
2. `migrations/002_users_learning.sql`
3. `migrations/003_jlpt_tests.sql`
4. `migrations/004_system_logs.sql`

## Khởi tạo

Tạo database một lần:

```sql
CREATE DATABASE nihon_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

Chọn `nihon_db`, sau đó chạy lần lượt bốn file migration ở trên bằng MySQL Workbench hoặc MySQL CLI.

## Kết nối từ ứng dụng

Ứng dụng Flutter không kết nối trực tiếp tới MySQL. Hãy đặt thông tin database ở backend (ví dụ REST API), rồi để Flutter gọi API qua HTTPS. Không nhúng mật khẩu MySQL hoặc credentials của server vào ứng dụng mobile.

`notebook_items` và `user_srs_progress` dùng cặp `item_type`/`item_id` để trỏ đến một trong ba bảng `words`, `kanjis`, `grammars`. MySQL không thể tạo một foreign key cho kiểu tham chiếu đa hình này; backend cần xác thực bảng đích và ID trước khi ghi.

## Phần cần xác nhận

Mô tả ban đầu ghi phân hệ System & Logs có 3 bảng, nhưng chỉ định nghĩa `search_histories` và `user_settings`. Các migration hiện tạo đúng 15 bảng đã được mô tả; cần bổ sung đặc tả bảng thứ ba (có thể là báo lỗi) trước khi tạo migration tương ứng.