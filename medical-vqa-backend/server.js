require('dotenv').config();
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const axios = require('axios');
const path = require('path');
const fs = require('fs');
const FormData = require('form-data');

const app = express();
const PORT = process.env.PORT || 5000;
const AI_BASE_URL = process.env.AI_BASE_URL;

// Middleware
app.use(cors()); // Cho phép Vue gọi
app.use(express.json());

// ---------- CẤU HÌNH UPLOAD FILE ----------
// Tạo thư mục uploads nếu chưa có
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir);
}

// Cấu hình multer
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '-' + file.originalname;
        cb(null, uniqueName);
    }
});

const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Chỉ chấp nhận file ảnh'), false);
    }
};

const upload = multer({
    storage: storage,
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
    fileFilter: fileFilter
});

// ---------- HÀM GỌI AI (dùng chung) ----------
const callAI = async (imagePath, endpoint, question = null) => {
    const form = new FormData();
    form.append('file', fs.createReadStream(imagePath));
    if (question) {
        form.append('question', question);
    }

    const response = await axios({
        method: 'post',
        url: `${AI_BASE_URL}${endpoint}`,
        data: form,
        headers: {
            ...form.getHeaders(),
            'ngrok-skip-browser-warning': 'true' // Thêm header để vượt qua ngrok
        },
        timeout: 30000 // 30 giây
    });

    return response.data;
};

// ---------- ROUTE 1: Caption ----------
app.post('/api/caption', upload.single('image'), async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ status: 'error', message: 'Không có file ảnh' });
    }

    const filePath = req.file.path;
    console.log(`[Caption] Đang xử lý: ${filePath}`);

    try {
        const result = await callAI(filePath, '/caption');
        // Xóa file tạm
        fs.unlinkSync(filePath);

        res.json({
            status: 'success',
            type: 'caption',
            result: result.caption || result.result || result.text || 'Không có kết quả'
        });
    } catch (error) {
        console.error('[Caption] Lỗi:', error.message);
        if (fs.existsSync(filePath)) fs.unlinkSync(filePath);

        let errorMsg = 'Lỗi AI server.';
        if (error.code === 'ECONNABORTED' || error.message.includes('timeout')) {
            errorMsg = 'AI server (Colab) bị ngắt hoặc quá tải. Vui lòng báo TV1 restart.';
        } else if (error.response) {
            errorMsg = `AI trả về lỗi: ${error.response.status}`;
        }

        res.status(500).json({ status: 'error', message: errorMsg });
    }
});

// ---------- ROUTE 2: VQA ----------
app.post('/api/vqa', upload.single('image'), async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ status: 'error', message: 'Không có file ảnh' });
    }

    const question = req.body.question;
    if (!question) {
        return res.status(400).json({ status: 'error', message: 'Thiếu câu hỏi' });
    }

    const filePath = req.file.path;
    console.log(`[VQA] Đang xử lý: ${filePath}, câu hỏi: "${question}"`);

    try {
        const result = await callAI(filePath, '/vqa', question);
        fs.unlinkSync(filePath);

        res.json({
            status: 'success',
            type: 'vqa',
            question: question,
            result: result.answer || result.result || result.text || 'Không có câu trả lời'
        });
    } catch (error) {
        console.error('[VQA] Lỗi:', error.message);
        if (fs.existsSync(filePath)) fs.unlinkSync(filePath);

        let errorMsg = 'Lỗi AI server.';
        if (error.code === 'ECONNABORTED' || error.message.includes('timeout')) {
            errorMsg = 'AI server (Colab) bị ngắt hoặc quá tải.';
        } else if (error.response) {
            errorMsg = `AI trả về lỗi: ${error.response.status}`;
        }

        res.status(500).json({ status: 'error', message: errorMsg });
    }
});

// ---------- ROUTE 3: Health check ----------
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Backend Node.js đang chạy', ai_url: AI_BASE_URL });
});

// ---------- KHỞI ĐỘNG SERVER ----------
app.listen(PORT, () => {
    console.log(`✅ Server chạy tại http://localhost:${PORT}`);
    console.log(`📡 AI URL: ${AI_BASE_URL}`);
    console.log(`📁 Upload folder: ${uploadDir}`);
});