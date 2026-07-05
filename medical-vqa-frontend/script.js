const BACKEND_URL = "http://localhost:5000";

let selectedFile = null;
let selectedFileURL = null;
let currentCaption = "";

// DOM
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

// Helper functions
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
    btn.dataset.original = btn.textContent;
    btn.textContent = "Đang xử lý...";
  } else if (btn.dataset.original) {
    btn.textContent = btn.dataset.original;
  }
}

function showResult(el, text) {
  el.classList.remove("placeholder");
  el.style.color = "";
  el.textContent = text;
}

function showError(el, msg) {
  el.classList.remove("placeholder");
  el.style.color = "#a43d3d";
  el.textContent = msg;
}

// API
async function callAPI(endpoint, formData, outputEl) {
  try {
    const res = await axios.post(`${BACKEND_URL}${endpoint}`, formData, { timeout: 25000 });
    if (res.data?.result) {
      showResult(outputEl, res.data.result);
      return res.data.result;
    }
  } catch (err) {
    showError(outputEl, err.code === "ECONNABORTED" ? "Timeout" : "Lỗi kết nối");
  }
  return null;
}

function createFormData(question = null) {
  const fd = new FormData();
  fd.append("image", selectedFile);
  if (question) fd.append("question", question);
  return fd;
}

// Functions
async function autoRunCaption() {
  if (!selectedFile) return;
  captionOutput.textContent = "Đang tạo mô tả...";
  currentCaption = await callAPI("/api/caption", createFormData(), captionOutput);
}

async function runCaption() {
  if (!selectedFile) return showError(captionOutput, "Chưa có ảnh");
  setLoading(captionBtn, true);
  currentCaption = await callAPI("/api/caption", createFormData(), captionOutput);
  setLoading(captionBtn, false);
}

async function runLesionAnalysis() {
  if (!selectedFile) return showError(lesionOutput, "Chưa có ảnh");
  setLoading(lesionBtn, true);
  if (!currentCaption) await autoRunCaption();
  showResult(lesionOutput, currentCaption || "Không có dữ liệu");
  setLoading(lesionBtn, false);
}

async function askQuestion() {
  if (!selectedFile) return showError(questionOutput, "Chưa có ảnh");
  const q = questionInput.value.trim();
  if (!q) return showError(questionOutput, "Nhập câu hỏi");
  setLoading(askBtn, true);
  await callAPI("/api/vqa", createFormData(q), questionOutput);
  setLoading(askBtn, false);
}

// Events
imageInput.addEventListener("change", e => {
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

suggestionChips.forEach(chip => chip.addEventListener("click", () => {
  questionInput.value = chip.dataset.question || "";
}));

// Drag Drop
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

// Init
async function init() {
  try {
    await axios.get(`${BACKEND_URL}/api/health`);
    setStatus("Backend online", true);
  } catch {
    setStatus("Backend offline", false);
  }
}

init();