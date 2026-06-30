# XLA-and-TGMT
# Phân công công việc dự án

Dự án được chia thành 3 đội với 6 thành viên, mỗi thành viên phụ trách một phần công việc cụ thể như sau.

---

# Đội 1: AI & Hệ thống máy chủ

## Thành viên 1 – Lõi AI (AI Core – Python/Colab)

### Nhiệm vụ

1. Truy cập Hugging Face, tìm mô hình **Salesforce/blip-vqa-base** và đọc Model Card để nắm cách sử dụng.
2. Mở Google Colab, tạo Notebook mới và bật GPU T4.
3. Cài đặt các thư viện cần thiết gồm:
   - transformers
   - torch
   - Pillow
4. Viết chương trình Python tải mô hình và khởi tạo model.
5. Xây dựng hai hàm:
   - `generate_caption(image_path)`
   - `answer_vqa(image_path, question_text)`
6. Đóng gói hai hàm thành API bằng FastAPI hoặc Flask. Đồng thời xây dựng thêm phiên bản chạy Local kết hợp Colab + ngrok nhằm hạn chế việc mất kết nối.
7. Sau khi API hoạt động ổn định, gửi đường dẫn API nội bộ cho Thành viên 5 để tiến hành kiểm thử sớm.

---

## Thành viên 2 – Backend Developer (Node.js)

### Nhiệm vụ

1. Khởi tạo dự án Node.js bằng `npm init`.
2. Cài đặt các thư viện:
   - express
   - cors
   - multer
   - axios
3. Cấu hình Multer để lưu ảnh tải lên trong thư mục `/uploads`.
4. Xây dựng các API:
   - `/api/vqa`: gửi ảnh và câu hỏi đến API AI.
   - `/api/caption`: gửi ảnh để sinh mô tả tự động.
5. Nhận dữ liệu JSON từ AI, xử lý và trả về dữ liệu chuẩn cho Frontend. Có thể đóng gói bằng Docker nếu cần.

---

# Đội 2: Giao diện Web (Vue 3)

## Thành viên 3 – UI/UX Frontend

### Nhiệm vụ

1. Khởi tạo dự án Vue 3 bằng Vite và cài đặt TailwindCSS.
2. Xây dựng component `ImageUpload.vue` gồm:
   - Khung upload dạng nét đứt.
   - Hỗ trợ click chọn ảnh.
   - Hỗ trợ kéo thả ảnh.
3. Hiển thị ảnh xem trước (`preview`) sau khi người dùng chọn ảnh.
4. Xây dựng component `ChatBox.vue` gồm:
   - Ô nhập câu hỏi.
   - Nút **Hỏi AI** có hiệu ứng hover.

---

## Thành viên 4 – Tích hợp API Frontend

### Nhiệm vụ

1. Nhận các component từ Thành viên 3 và hoàn thiện phần `<script setup>`.
2. Cài đặt Axios cho dự án Vue.
3. Viết chức năng gửi ảnh và câu hỏi bằng `FormData` tới API `/api/vqa`.
4. Thêm nút **Mô tả ảnh** để gọi API `/api/caption` và hiển thị caption tự động.
5. Xây dựng trạng thái Loading (`isLoading`) bằng Spinner trong quá trình gọi API và hiển thị kết quả sau khi hoàn thành.

---

# Đội 3: Dữ liệu, Kiểm thử & Tài liệu

## Thành viên 5 – Tester & Viết chương Kết quả

### Nhiệm vụ

1. Chuẩn bị 30 ảnh thuộc 3 nhóm:
   - Phong cảnh đô thị.
   - Hoạt động con người.
   - Bữa ăn / Đồ vật.
2. Tạo bảng Excel gồm 6 cột:
   - Tên ảnh.
   - Câu hỏi tiếng Anh.
   - Kết quả VQA của AI.
   - Đúng/Sai VQA.
   - Caption do AI sinh.
   - Đúng/Sai Caption.
3. Tiến hành kiểm thử sớm thông qua API nội bộ bằng Postman hoặc Script, sau đó kiểm thử lại trên giao diện Web và đánh dấu các trường hợp sai.
4. Chụp màn hình:
   - 5 trường hợp hoạt động tốt.
   - 2 trường hợp AI trả lời sai.
   Tách riêng cho Image Captioning và VQA.
5. Viết bản nháp Chương 4 gồm:
   - Đánh giá độ chính xác VQA.
   - Đánh giá độ chính xác Captioning.
   - So sánh ưu điểm và hạn chế của hệ thống.
   Sau đó chuyển nội dung cho Thành viên 6.

---

## Thành viên 6 – Word Master

### Nhiệm vụ

1. Thiết lập định dạng báo cáo:
   - Font Times New Roman.
   - Cỡ chữ 13.
   - Giãn dòng 1.5.
   - Căn đều hai lề.
   - Heading 1, Heading 2, Heading 3.
   - Mục lục tự động.
   - Trang bìa đúng quy định của trường.
2. Viết Chương 1:
   - Lý do chọn đề tài.
   - Mục tiêu đồ án.
3. Viết Chương 2:
   - Giới thiệu Thị giác máy tính.
   - Transformer.
   - Image Captioning.
   - Visual Question Answering (VQA).
4. Thiết kế sơ đồ hệ thống bằng draw.io:

   ```
   User
      ↓
   Frontend
      ↓
   Backend
      ↓
   AI Model
      ↑
   Kết quả phản hồi
   ```

5. Tiếp nhận dữ liệu từ Thành viên 5, hoàn thiện Chương 4, kiểm tra toàn bộ báo cáo và xuất file PDF cuối cùng để in và nộp.

---

# Tổng kết phân công

| Thành viên | Vai trò | Phụ trách |
|------------|----------|-----------|
| TV1 | AI Core | Xây dựng mô hình AI và API |
| TV2 | Backend | Xây dựng API trung gian Node.js |
| TV3 | Frontend UI | Thiết kế giao diện Vue |
| TV4 | Frontend API | Kết nối Frontend với Backend |
| TV5 | Tester | Kiểm thử hệ thống và đánh giá kết quả |
| TV6 | Word Master | Viết báo cáo và hoàn thiện tài liệu |