// ==================== CẤU HÌNH ====================
const BACKEND_URL = "http://localhost:5000";   // ← Sửa port nếu backend khác

let selectedFile = null;
let selectedFileURL = null;
let currentCaption = "";

// ==================== DOM ELEMENTS ====================
const imageInput = document.getElementById("imageInput");
const chooseFileBtn = document.getElementById("chooseFileBtn");
const dropzone = document.getElementById("dropzone");
const previewImage = document.getElementById("previewImage");
const previewBadge = document.getElementById("previewBadge");
const emptyState = document.getElementById("emptyState");

const captionBtn = document.getElementById("captionBtn");
const lesionBtn = document.getElementById("lesionBtn");
const askBtn = document.getElementById("askBtn");
const questionInput = document.getElementById("questionInput");

const captionOutput = document.getElementById("captionOutput");
const lesionOutput = document.getElementById("lesionOutput");
const questionOutput = document.getElementById("questionOutput");
const backendStatus = document.getElementById("backendStatus");

const suggestionChips = document.querySelectorAll(".suggestion-chip");

// ==================== UTILITIES ====================
function setStatus(text, isOnline) {
  backendStatus.textContent = text;
  backendStatus.className = `api-status ${isOnline ? "online" : "offline"}`;
}

function updatePreview(file) {
  if (selectedFileURL) URL.revokeObjectURL(selectedFileURL);
  selectedFileURL = URL.createObjectURL(file);
  previewImage.src = selectedFileURL;
  previewImage.hidden = false;
  previewBadge.hidden = false;
  emptyState.hidden = true;
}

function setLoading(btn, isLoading) {
  btn.disabled = isLoading;
  if (isLoading) {
    btn.dataset.originalText = btn.textContent;
    btn.textContent = "Đang xử lý...";
  } else if (btn.dataset.originalText) {
    btn.textContent = btn.dataset.originalText;
  }
}

function showResult(element, text) {
  element.classList.remove("placeholder");
  element.style.color = "";
  element.textContent = text;
}

function showError(element, message) {
  element.classList.remove("placeholder");
  element.style.color = "#a43d3d";
  element.textContent = message;
}

// ==================== API CALL ====================
async function callAPI(endpoint, formData, outputElement) {
  try {
    const response = await axios.post(`${BACKEND_URL}${endpoint}`, formData, {
      timeout: 30000
    });

    if (response.data?.result) {
      showResult(outputElement, response.data.result);
      return response.data.result;
    }
    throw new Error("Không nhận được kết quả");
  } catch (error) {
    const msg = error.code === "ECONNABORTED"
    ? "Quá thời gian chờ. Vui lòng kiểm tra backend và AI service."
    : "Lỗi kết nối server";
    showError(outputElement, msg);
    console.error(error);
    return null;
  }
}

function createFormData(question = null) {
  const formData = new FormData();
  formData.append("image", selectedFile);
  if (question) formData.append("question", question);
  return formData;
}

// ==================== MAIN FUNCTIONS ====================
async function autoRunCaption() {
  if (!selectedFile) return;
  captionOutput.textContent = "Đang tạo mô tả ảnh...";
  currentCaption = await callAPI("/api/caption", createFormData(), captionOutput);
}

async function runCaption() {
  if (!selectedFile) return showError(captionOutput, "Vui lòng tải ảnh trước");
  setLoading(captionBtn, true);
  currentCaption = await callAPI("/api/caption", createFormData(), captionOutput);
  setLoading(captionBtn, false);
}

async function runLesionAnalysis() {
  if (!selectedFile) return showError(lesionOutput, "Vui lòng tải ảnh trước");
  
  setLoading(lesionBtn, true);
  lesionOutput.textContent = "Đang phân tích vùng tổn thương...";

  try {
    if (!currentCaption) {
      currentCaption = await autoRunCaption();
    }

    const lesionText = currentCaption 
      ? `Phân tích tổn thương:\n\n${currentCaption}\n\n→ Vùng tổn thương chính: Khu vực da bị tổn thương rõ ràng (dựa trên mô tả AI).`
      : "Không thể phân tích do thiếu mô tả ảnh.";

    showResult(lesionOutput, lesionText);
  } catch (error) {
    showError(lesionOutput, "Lỗi khi phân tích vùng tổn thương.");
  } finally {
    setLoading(lesionBtn, false);
  }
}

async function askQuestion() {
  if (!selectedFile) return showError(questionOutput, "Vui lòng tải ảnh trước");
  
  const question = questionInput.value.trim();
  if (!question) return showError(questionOutput, "Vui lòng nhập câu hỏi");

  setLoading(askBtn, true);
  await callAPI("/api/vqa", createFormData(question), questionOutput);
  setLoading(askBtn, false);
}

// ==================== EVENT LISTENERS ====================
imageInput.addEventListener("change", (e) => {
  const file = e.target.files[0];
  if (file) {
    selectedFile = file;
    updatePreview(file);
    autoRunCaption();
  }
});

chooseFileBtn.addEventListener("click", () => imageInput.click());
captionBtn.addEventListener("click", runCaption);
lesionBtn.addEventListener("click", runLesionAnalysis);
askBtn.addEventListener("click", askQuestion);

suggestionChips.forEach(chip => {
  chip.addEventListener("click", () => {
    questionInput.value = chip.dataset.question || "";
  });
});

// Drag & Drop
dropzone.addEventListener("dragover", e => { e.preventDefault(); dropzone.classList.add("dragover"); });
dropzone.addEventListener("dragleave", () => dropzone.classList.remove("dragover"));
dropzone.addEventListener("drop", e => {
  e.preventDefault();
  dropzone.classList.remove("dragover");
  const file = e.dataTransfer.files[0];
  if (file) {
    selectedFile = file;
    updatePreview(file);
    autoRunCaption();
  }
});

// Khởi tạo
async function init() {
  try {
    await axios.get(`${BACKEND_URL}/api/health`);
    setStatus("Backend online", true);
  } catch {
    setStatus("Backend offline", false);
  }
}

init();