Đề tài:
 Phát hiện và phân vùng tổn thương y tế Mô tả ảnh và trả lời câu hỏi dựa trên nội dung hình ảnh
## 📋 Project Task Assignment

Để đảm bảo dự án được triển khai đúng tiến độ và các thành phần có thể phát triển song song, nhóm được chia thành ba đội với sáu thành viên, mỗi thành viên đảm nhận một vai trò riêng biệt.

### 🧠 Team 1 – AI & Server

#### Member 1 – AI Core (Python / Google Colab)

Thành viên phụ trách AI chịu trách nhiệm nghiên cứu và triển khai mô hình BLIP của Hugging Face. Công việc bắt đầu bằng việc tìm hiểu **Salesforce/blip-vqa-base**, đọc Model Card và xác nhận kiến trúc mô hình sử dụng **Vision Transformer (ViT)** làm Visual Encoder và **Transformer** làm Text Encoder, phù hợp với kiến trúc được trình bày trong đề cương.

Sau đó, thành viên thiết lập môi trường trên Google Colab với GPU Tesla T4, tải hai mô hình:
- **Salesforce/blip-vqa-base** cho bài toán Visual Question Answering (VQA).
- **Salesforce/blip-image-captioning-base** cho bài toán Image Captioning.

Tiếp theo, cài đặt các thư viện cần thiết gồm:

```bash
pip install transformers torch Pillow fastapi uvicorn pyngrok python-multipart
```

Sau khi môi trường hoàn tất, xây dựng chương trình nạp hai mô hình và mô tả pipeline xử lý:

```
Image
   ↓
Vision Transformer (ViT)
   ↓
Visual Embedding
   ↓
Fusion Module
   ↑
Text Embedding
   ↑
Transformer
   ↑
Question
   ↓
Caption / Answer
```

Tiếp tục xây dựng hai hàm:

- `generate_caption(image)`
- `answer_vqa(image, question)`

và kiểm thử với ít nhất năm ảnh mẫu, ưu tiên các ảnh y tế như X-quang, CT hoặc nội soi.

Cuối cùng, đóng gói mô hình thành dịch vụ FastAPI với hai API:

- `POST /caption`
- `POST /vqa`

Sau khi triển khai, sử dụng **ngrok** để tạo địa chỉ Public API và gửi URL cùng tài liệu Postman hoặc cURL cho Member 2 và Member 5 trước cuối ngày thứ hai.

---

#### Member 2 – Backend Developer (Node.js)

Thành viên Backend chịu trách nhiệm xây dựng máy chủ trung gian kết nối giữa Frontend và AI.

Công việc bao gồm:

- Khởi tạo dự án Node.js.
- Cài đặt Express, Multer, Axios và CORS.
- Cấu hình Multer để lưu ảnh tạm trong thư mục `uploads`.
- Xây dựng hai API:
  - `POST /api/caption`
  - `POST /api/vqa`
- Gửi ảnh và câu hỏi đến AI API thông qua Axios.
- Chuẩn hóa dữ liệu JSON trả về cho Frontend.
- Xử lý lỗi timeout khi Google Colab hoặc ngrok bị ngắt kết nối.
- (Tùy chọn) Đóng gói Backend bằng Docker.

---

## 🎨 Team 2 – Web Frontend (Vue 3)

### Member 3 – UI/UX Frontend

Thành viên Frontend chịu trách nhiệm thiết kế giao diện người dùng bằng Vue 3 và TailwindCSS.

Các công việc bao gồm:

- Khởi tạo dự án bằng Vite.
- Thiết kế giao diện tải ảnh (`ImageUpload.vue`) hỗ trợ:
  - Chọn ảnh bằng nút Upload.
  - Kéo và thả ảnh (Drag & Drop).
- Hiển thị ảnh Preview ngay sau khi người dùng chọn.
- Thiết kế giao diện hội thoại (`ChatBox.vue`) bao gồm:
  - Ô nhập câu hỏi.
  - Nút **Ask AI**.
  - Khu vực hiển thị Caption tự động.

Toàn bộ component giao diện phải được bàn giao cho Member 4 trước sáng ngày thứ ba.

---

### Member 4 – Frontend API Integration

Sau khi nhận giao diện từ Member 3, thành viên này chịu trách nhiệm tích hợp API.

Công việc bao gồm:

- Cài đặt Axios.
- Xây dựng hàm gửi ảnh và câu hỏi bằng `FormData`.
- Gọi API `/api/vqa`.
- Tự động gọi `/api/caption` ngay sau khi người dùng tải ảnh lên.
- Hiển thị Caption và câu trả lời AI.
- Xây dựng Loading Spinner trong quá trình chờ phản hồi.
- Hiển thị thông báo lỗi khi API timeout.

Việc tích hợp phải hoàn thành trước ngày thứ sáu để nhóm kiểm thử có thể bắt đầu đánh giá trên giao diện thực tế.

---

## 🧪 Team 3 – Dataset, Testing & Documentation

### Member 5 – Tester & Evaluation

Thành viên kiểm thử chịu trách nhiệm chuẩn bị dữ liệu và đánh giá hệ thống.

Nguồn dữ liệu chính bao gồm:

- MS COCO Captions
- VQA v2

Ngoài ra, chuẩn bị thêm khoảng 5–10 ảnh y tế từ các bộ dữ liệu mở nhằm minh họa khả năng ứng dụng trong hỗ trợ chẩn đoán.

Tiếp theo, xây dựng bảng đánh giá gồm các cột:

- Image Name
- Question
- VQA Answer
- VQA Correct
- Generated Caption
- Caption Correct

Sau khi nhận được AI API, tiến hành kiểm thử bằng Postman hoặc Python Script mà không cần chờ Frontend hoàn thành.

Sau khi Website hoàn thiện, tiếp tục kiểm thử toàn bộ hệ thống, chụp các trường hợp hoạt động tốt và các trường hợp mô hình dự đoán sai.

Cuối cùng, thống kê độ chính xác của Image Captioning và Visual Question Answering, phân tích ưu điểm, hạn chế và khả năng ứng dụng trong lĩnh vực y tế.

---

### Member 6 – Documentation & Report

Thành viên cuối cùng chịu trách nhiệm xây dựng tài liệu báo cáo.

Các công việc gồm:

- Thiết lập định dạng Word theo quy định của trường.
- Viết Chương 1 (Giới thiệu).
- Viết Chương 2 (Cơ sở lý thuyết), bao gồm:
  - Computer Vision
  - CNN
  - Vision Transformer (ViT)
  - Transformer
  - Fusion Module
  - Image Captioning
  - Visual Question Answering
  - MS COCO
  - VQA v2
- Thiết kế sơ đồ hệ thống bằng draw.io:
  - User → Frontend → Backend → AI Model
- Thiết kế sơ đồ kiến trúc BLIP:
  - Image → CNN/ViT → Visual Embedding → Fusion Module ← Text Embedding ← Transformer → Output.
- Tổng hợp kết quả kiểm thử từ Member 5.
- Hoàn thiện Chương 4 (Kết quả thực nghiệm).
- Xuất báo cáo Word và PDF để nộp.

---

## 📅 Project Timeline

| Day | Main Activities |
|------|-----------------|
| Day 1 | Research models, initialize Backend & Frontend, prepare report template |
| Day 2 | Complete AI APIs and deliver to Backend & Tester |
| Day 3 | Integrate APIs and begin testing |
| Day 4–5 | Complete Frontend and continue testing |
| Day 6 | Finish system integration and evaluate results |
| Day 7 | Complete report and final submission |

---

## 🎯 Project Deliverables

Đến cuối dự án, nhóm cần hoàn thành các sản phẩm sau:

- Image Captioning API
- Visual Question Answering (VQA) API
- Node.js Backend
- Vue 3 Web Application
- Testing Report
- Experimental Results
- Final Documentation
- Source Code
- Final PDF Report