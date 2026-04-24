# 工程施工檢查表智能生成系統 - 部署指南

本文檔詳細說明如何在不同環境中部署本系統，包括本地開發、Docker 容器化部署、以及雲端部署選項。

## 📋 前置需求

### 系統要求

* **作業系統**：Linux (推薦 Ubuntu 20.04+)、macOS 或 Windows (需要 WSL2)
* **Python 版本**：3.11 或更高版本
* **記憶體**：最少 4GB (建議 8GB 以上)
* **磁碟空間**：最少 2GB (用於 PaddleOCR 模型)

### 必要的 API Key

* **Google Gemini API Key**：用於 LLM 智能糾錯功能
  * 申請地址：https://ai.google.dev/
  * 免費配額：每分鐘 60 個請求，每天 1,500 個請求

## 🐳 方法一：Docker 容器化部署 (推薦用於生產環境)

Docker 部署提供了最佳的環境隔離與可重複性，強烈推薦用於生產環境。

### 1. 安裝 Docker 與 Docker Compose

**Ubuntu/Debian**：
```bash
# 安裝 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安裝 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 驗證安裝
docker --version
docker-compose --version
```

**macOS** (使用 Homebrew)：
```bash
brew install docker docker-compose
```

### 2. 配置環境變數

```bash
# 複製環境變數範本
cp .env.example .env

# 編輯 .env 檔案，填入您的 API Key
nano .env
```

在 `.env` 檔案中填入：
```
GEMINI_API_KEY=your_actual_api_key_here
```

### 3. 啟動服務

```bash
# 建立並啟動容器
docker-compose up -d --build

# 查看日誌
docker-compose logs -f

# 停止服務
docker-compose down
```

### 4. 驗證部署

* **前端介面**：http://localhost:8501
* **後端 API**：http://localhost:8000
* **API 文件**：http://localhost:8000/docs

## 🖥️ 方法二：本地開發環境安裝

適合進行開發、測試與除錯。

### 1. 克隆或下載專案

```bash
# 如果使用 Git
git clone <repository_url>
cd construction_checklist_system

# 或直接下載 ZIP 檔案並解壓縮
```

### 2. 建立虛擬環境

```bash
# 建立虛擬環境
python3.11 -m venv venv

# 啟動虛擬環境
source venv/bin/activate  # Linux/macOS
# 或
venv\\Scripts\\activate  # Windows
```

### 3. 安裝依賴套件

```bash
# 升級 pip
pip install --upgrade pip

# 安裝所有依賴
pip install -r requirements.txt

# 如果遇到 OpenCV 問題，可以使用 headless 版本
pip install opencv-python-headless
```

### 4. 配置環境變數

```bash
# 建立 .env 檔案
cp .env.example .env

# 編輯 .env 檔案
nano .env
```

### 5. 啟動系統

**方式 A：同時啟動前端與後端**

```bash
# 在專案根目錄執行
chmod +x start.sh
./start.sh
```

**方式 B：分別啟動 (用於開發)**

終端機視窗 1 - 啟動後端 API：
```bash
source venv/bin/activate
uvicorn backend.api:app --reload --host 0.0.0.0 --port 8000
```

終端機視窗 2 - 啟動前端介面：
```bash
source venv/bin/activate
streamlit run app/main.py --server.port 8501 --server.address 0.0.0.0
```

### 6. 存取系統

* **前端介面**：http://localhost:8501
* **後端 API**：http://localhost:8000
* **API 文件**：http://localhost:8000/docs

## ☁️ 方法三：雲端部署

### AWS EC2 部署

1. **啟動 EC2 實例**
   * 選擇 Ubuntu 20.04 LTS AMI
   * 實例類型建議：t3.medium 或更高
   * 配置安全群組，開放 8501 和 8000 埠

2. **連接到實例並安裝依賴**
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y python3.11 python3.11-venv git
   
   # 克隆專案
   git clone <repository_url>
   cd construction_checklist_system
   ```

3. **使用 Docker 部署**
   ```bash
   # 安裝 Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   
   # 啟動服務
   docker-compose up -d
   ```

4. **配置反向代理 (可選)**
   使用 Nginx 作為反向代理，提高安全性與效能：
   ```nginx
   upstream streamlit {
       server localhost:8501;
   }
   
   upstream fastapi {
       server localhost:8000;
   }
   
   server {
       listen 80;
       server_name your_domain.com;
       
       location / {
           proxy_pass http://streamlit;
       }
       
       location /api {
           proxy_pass http://fastapi;
       }
   }
   ```

### Google Cloud Run 部署

1. **準備 Dockerfile** (已包含在專案中)

2. **建立 Cloud Run 服務**
   ```bash
   gcloud run deploy construction-checklist \\
     --source . \\
     --platform managed \\
     --region asia-east1 \\
     --allow-unauthenticated \\
     --set-env-vars GEMINI_API_KEY=your_key
   ```

### Azure 容器實例部署

1. **建立 ACR (Azure Container Registry)**
   ```bash
   az acr create --resource-group myResourceGroup --name myRegistry --sku Basic
   ```

2. **推送映像**
   ```bash
   docker build -t construction-checklist .
   docker tag construction-checklist myRegistry.azurecr.io/construction-checklist:latest
   docker push myRegistry.azurecr.io/construction-checklist:latest
   ```

3. **部署容器實例**
   ```bash
   az container create \\
     --resource-group myResourceGroup \\
     --name construction-checklist \\
     --image myRegistry.azurecr.io/construction-checklist:latest \\
     --ports 8501 8000 \\
     --environment-variables GEMINI_API_KEY=your_key
   ```

## 🔧 常見部署問題與解決方案

### 問題 1：PaddleOCR 模型下載緩慢

**原因**：模型檔案較大 (~200MB)，首次執行需要下載。

**解決方案**：
```bash
# 預先下載模型
python -c "from paddleocr import PaddleOCR; ocr = PaddleOCR()"
```

### 問題 2：GPU 記憶體不足

**原因**：PaddleOCR 預設嘗試使用 GPU。

**解決方案**：在 `app/config.py` 中設置 `OCR_USE_GPU = False`。

### 問題 3：API Key 無效

**原因**：Gemini API Key 過期或配額已用盡。

**解決方案**：
1. 檢查 API Key 是否正確
2. 在 Google Cloud Console 檢查配額使用情況
3. 考慮升級為付費方案

### 問題 4：檔案上傳失敗

**原因**：可能是上傳檔案大小超過限制。

**解決方案**：
* 檢查 `app/config.py` 中的 `MAX_UPLOAD_SIZE_MB` 設置
* 確保伺服器有足夠的磁碟空間

## 📊 效能優化建議

### 1. 資料庫優化

對於高併發場景，建議將 SQLite 遷移至 PostgreSQL：

```bash
# 安裝 PostgreSQL 驅動
pip install psycopg2-binary

# 修改 app/config.py
DATABASE_URL = "postgresql://user:password@localhost/checklist_db"
```

### 2. 快取優化

使用 Redis 快取 OCR 結果，避免重複處理相同圖像：

```python
import redis
cache = redis.Redis(host='localhost', port=6379, db=0)
```

### 3. 非同步處理

使用 Celery 進行後台任務隊列，提高系統吞吐量：

```bash
pip install celery redis
```

### 4. 負載均衡

使用 Nginx 或 HAProxy 進行負載均衡，分散請求至多個應用實例。

## 🔐 安全性建議

1. **API Key 管理**
   * 使用環境變數或密鑰管理服務 (如 AWS Secrets Manager)
   * 定期輪換 API Key
   * 限制 API Key 的使用範圍

2. **檔案上傳安全**
   * 驗證上傳檔案的 MIME 類型
   * 掃描上傳檔案是否包含惡意代碼
   * 限制上傳檔案大小

3. **網路安全**
   * 使用 HTTPS/TLS 加密傳輸
   * 配置防火牆規則
   * 啟用 CORS 限制

4. **資料保護**
   * 定期備份資料庫
   * 加密敏感資訊
   * 實施日誌審計

## 📈 監控與維護

### 日誌監控

```bash
# 查看 Docker 日誌
docker-compose logs -f app

# 查看特定服務日誌
docker-compose logs -f app | grep "ERROR"
```

### 效能監控

使用 Prometheus 與 Grafana 進行效能監控：

```bash
# 安裝 prometheus-client
pip install prometheus-client
```

### 定期維護

* 每週檢查磁碟空間使用情況
* 每月清理舊的臨時檔案
* 定期更新依賴套件

## 📞 技術支援

如遇到部署問題，請檢查以下資源：

* **官方文檔**：
  * Streamlit: https://docs.streamlit.io/
  * FastAPI: https://fastapi.tiangolo.com/
  * PaddleOCR: https://github.com/PaddlePaddle/PaddleOCR
  * Docker: https://docs.docker.com/

* **常見問題**：參考本文檔的「常見部署問題與解決方案」部分

---
*Last Updated: 2026-04-22*
*Developed by Manus AI*
