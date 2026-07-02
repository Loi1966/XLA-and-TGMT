const BACKEND_URL = "http://localhost:5000";

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
const suggestionChips = Array.from(
  document.querySelectorAll(".suggestion-chip"),
);

let selectedFile = null;
let currentCaption = "";

function setStatus(text, online) {
  backendStatus.textContent = text;
  backendStatus.className = `api-status ${online ? "online" : "offline"}`;
}

function updatePreview(file) {
  const reader = new FileReader();
  reader.onload = () => {
    previewImage.src = reader.result;
    previewImage.hidden = false;
    previewBadge.hidden = false;
    emptyState.hidden = true;
  };
  reader.readAsDataURL(file);
}

function setLoading(button, isLoading) {
  button.disabled = isLoading;
  button.textContent = isLoading
    ? "Đang xử lý..."
    : button.dataset.originalLabel || button.textContent;
}

function showResult(element, text, type = "info") {
  element.classList.remove("placeholder");
  element.textContent = text;
  element.dataset.type = type;
}

function showError(element, message) {
  element.classList.remove("placeholder");
  element.textContent = message;
  element.style.color = "#a43d3d";
}

function resetResultStyles(element) {
  element.style.color = "";
}

async function checkBackend() {
  try {
    const response = await fetch(`${BACKEND_URL}/api/health`, {
      cache: "no-store",
    });
    const data = await response.json();
    if (response.ok) {
      setStatus(`Backend online · ${data.ai_url || "AI connected"}`, true);
    } else {
      setStatus("Backend không phản hồi", false);
    }
  } catch (error) {
    setStatus("Backend offline", false);
  }
}

function chooseFile(file) {
  if (!file) return;
  selectedFile = file;
  updatePreview(file);
}

async function runCaption() {
  if (!selectedFile) {
    showError(captionOutput, "Vui lòng tải ảnh trước khi mô tả.");
    return;
  }

  resetResultStyles(captionOutput);
  const originalLabel = captionBtn.textContent;
  captionBtn.dataset.originalLabel = originalLabel;
  setLoading(captionBtn, true);

  const formData = new FormData();
  formData.append("image", selectedFile);

  try {
    const response = await fetch(`${BACKEND_URL}/api/caption`, {
      method: "POST",
      body: formData,
    });

    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.message || "Không thể tạo mô tả ảnh.");
    }

    currentCaption = data.result || "Không có mô tả được trả về.";
    showResult(captionOutput, currentCaption);
  } catch (error) {
    showError(captionOutput, error.message || "Lỗi khi gọi mô tả ảnh.");
  } finally {
    setLoading(captionBtn, false);
  }
}

async function runLesionAnalysis() {
  if (!selectedFile) {
    showError(lesionOutput, "Vui lòng tải ảnh trước khi phân vùng tổn thương.");
    return;
  }

  resetResultStyles(lesionOutput);
  const originalLabel = lesionBtn.textContent;
  lesionBtn.dataset.originalLabel = originalLabel;
  setLoading(lesionBtn, true);

  try {
    if (!currentCaption) {
      await runCaption();
    }

    const summary = currentCaption
      ? `Tổn thương được phát hiện dựa trên mô tả AI: ${currentCaption}`
      : "Không có mô tả tổn thương được tạo.";

    showResult(lesionOutput, summary);
  } catch (error) {
    showError(lesionOutput, "Không thể phân vùng tổn thương lúc này.");
  } finally {
    setLoading(lesionBtn, false);
  }
}

async function askQuestion() {
  if (!selectedFile) {
    showError(questionOutput, "Vui lòng tải ảnh trước khi hỏi.");
    return;
  }

  const question = questionInput.value.trim();
  if (!question) {
    showError(questionOutput, "Vui lòng nhập câu hỏi liên quan đến ảnh.");
    return;
  }

  resetResultStyles(questionOutput);
  const originalLabel = askBtn.textContent;
  askBtn.dataset.originalLabel = originalLabel;
  setLoading(askBtn, true);

  const formData = new FormData();
  formData.append("image", selectedFile);
  formData.append("question", question);

  try {
    const response = await fetch(`${BACKEND_URL}/api/vqa`, {
      method: "POST",
      body: formData,
    });

    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.message || "Không thể trả lời câu hỏi.");
    }

    showResult(questionOutput, data.result || "Không có câu trả lời.");
  } catch (error) {
    showError(questionOutput, error.message || "Lỗi khi gửi câu hỏi.");
  } finally {
    setLoading(askBtn, false);
  }
}

imageInput.addEventListener("change", (event) => {
  const file = event.target.files?.[0];
  if (file) {
    chooseFile(file);
  }
});
chooseFileBtn.addEventListener("click", () => {
  imageInput.click();
});
captionBtn.addEventListener("click", runCaption);
lesionBtn.addEventListener("click", runLesionAnalysis);
askBtn.addEventListener("click", askQuestion);

suggestionChips.forEach((chip) => {
  chip.addEventListener("click", () => {
    questionInput.value = chip.dataset.question || "";
    questionInput.focus();
  });
});

dropzone.addEventListener("click", () => imageInput.click());

dropzone.addEventListener("keydown", (event) => {
  if (event.key === "Enter" || event.key === " ") {
    event.preventDefault();
    imageInput.click();
  }
});

dropzone.addEventListener("dragover", (event) => {
  event.preventDefault();
  dropzone.classList.add("dragover");
});

dropzone.addEventListener("dragleave", () => {
  dropzone.classList.remove("dragover");
});

dropzone.addEventListener("drop", (event) => {
  event.preventDefault();
  dropzone.classList.remove("dragover");
  const file = event.dataTransfer?.files?.[0];
  if (file) {
    chooseFile(file);
    imageInput.files = event.dataTransfer.files;
  }
});

checkBackend();
