# 使用 Python 3.11 作為基礎映像
FROM python:3.11-slim

# 設置工作目錄
WORKDIR /app

# 設置環境變數
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Taipei \
    DEBIAN_FRONTEND=noninteractive

# 安裝系統依賴（用於 OpenCV 和 PaddleOCR）
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 複製依賴檔案
COPY requirements.txt .

# 安裝 Python 依賴
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 複製專案代碼
COPY . .

# 建立必要的目錄
RUN mkdir -p data/uploads data/outputs templates

# 暴露端口 (Streamlit: 8501, FastAPI: 8000)
EXPOSE 8501 8000

# 啟動腳本
COPY start.sh .
RUN chmod +x start.sh

# 預設啟動命令
CMD ["./start.sh"]
