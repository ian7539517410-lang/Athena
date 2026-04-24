# FastAPI 後端 API 文檔

本文檔詳細說明所有可用的 REST API 端點及其使用方式。

## 基本資訊

* **基礎 URL**：`http://localhost:8000` (本地開發) 或 `https://your-domain.com` (生產環境)
* **API 版本**：1.0.0
* **內容類型**：`application/json`

## 認證

目前系統不需要認證。未來版本將支援 API Key 認證。

## 端點列表

### 1. 健康檢查

#### GET `/health`

檢查系統健康狀態。

**請求**：
```bash
curl http://localhost:8000/health
```

**回應**：
```json
{
  "status": "healthy",
  "database": "connected",
  "storage": "available"
}
```

**狀態碼**：
* `200 OK`：系統正常

---

### 2. 處理檔案

#### POST `/api/process`

上傳並處理 ZIP 檔案。

**請求參數**：
* `file` (必需)：ZIP 檔案
* `project_name` (可選)：專案名稱，預設為檔案名稱
* `use_llm_correction` (可選)：是否使用 LLM 糾錯，預設為 `true`
* `api_key` (可選)：Gemini API Key

**請求範例**：
```bash
curl -X POST http://localhost:8000/api/process \\
  -F "file=@checklist.zip" \\
  -F "project_name=Project_A" \\
  -F "use_llm_correction=true" \\
  -F "api_key=your_gemini_api_key"
```

**回應範例**：
```json
{
  "success": true,
  "record_id": 1,
  "message": "處理成功",
  "output_zip": "/app/data/outputs/Project_A_output.zip",
  "output_docx": "/app/data/outputs/Project_A_checklist.docx",
  "image_count": 5,
  "ocr_confidence": 0.87,
  "llm_confidence": 0.92,
  "total_time": 45.23
}
```

**狀態碼**：
* `200 OK`：處理成功
* `400 Bad Request`：檔案格式不正確
* `500 Internal Server Error`：處理失敗

---

### 3. 獲取所有記錄

#### GET `/api/records`

獲取所有處理記錄。

**查詢參數**：
* `limit` (可選)：返回記錄數量限制，預設為 100

**請求範例**：
```bash
curl http://localhost:8000/api/records?limit=20
```

**回應範例**：
```json
{
  "success": true,
  "count": 5,
  "records": [
    {
      "id": 1,
      "project_name": "Project_A",
      "input_file": "/app/data/uploads/checklist.zip",
      "overall_status": "success",
      "upload_time": "2026-04-22T10:30:45",
      "total_time": 45.23
    },
    {
      "id": 2,
      "project_name": "Project_B",
      "input_file": "/app/data/uploads/checklist2.zip",
      "overall_status": "success",
      "upload_time": "2026-04-22T11:15:30",
      "total_time": 38.50
    }
  ]
}
```

**狀態碼**：
* `200 OK`：成功
* `500 Internal Server Error`：查詢失敗

---

### 4. 獲取單個記錄

#### GET `/api/records/{record_id}`

獲取特定記錄的詳細資訊。

**路徑參數**：
* `record_id` (必需)：記錄 ID

**請求範例**：
```bash
curl http://localhost:8000/api/records/1
```

**回應範例**：
```json
{
  "success": true,
  "record": {
    "id": 1,
    "project_name": "Project_A",
    "input_file": "/app/data/uploads/checklist.zip",
    "input_file_size": 25.5,
    "upload_time": "2026-04-22T10:30:45",
    "ocr_status": "success",
    "ocr_confidence": 0.87,
    "llm_status": "success",
    "llm_confidence": 0.92,
    "docx_status": "success",
    "output_file": "/app/data/outputs/Project_A_checklist.docx",
    "overall_status": "success",
    "total_time": 45.23,
    "error_message": null
  }
}
```

**狀態碼**：
* `200 OK`：成功
* `404 Not Found`：記錄不存在
* `500 Internal Server Error`：查詢失敗

---

### 5. 下載檔案

#### GET `/api/download/{record_id}`

下載處理結果檔案。

**路徑參數**：
* `record_id` (必需)：記錄 ID

**查詢參數**：
* `file_type` (可選)：檔案類型，`zip` 或 `docx`，預設為 `zip`

**請求範例**：
```bash
# 下載 ZIP 檔案
curl -O http://localhost:8000/api/download/1?file_type=zip

# 下載 Word 檔案
curl -O http://localhost:8000/api/download/1?file_type=docx
```

**狀態碼**：
* `200 OK`：檔案下載成功
* `404 Not Found`：檔案不存在
* `500 Internal Server Error`：下載失敗

---

### 6. 獲取統計資訊

#### GET `/api/stats`

獲取系統統計資訊。

**請求範例**：
```bash
curl http://localhost:8000/api/stats
```

**回應範例**：
```json
{
  "success": true,
  "total_records": 42,
  "successful": 40,
  "failed": 2,
  "success_rate": 0.9524,
  "average_time": 42.15
}
```

**狀態碼**：
* `200 OK`：成功
* `500 Internal Server Error`：查詢失敗

---

### 7. 獲取系統配置

#### GET `/api/config`

獲取系統配置資訊。

**請求範例**：
```bash
curl http://localhost:8000/api/config
```

**回應範例**：
```json
{
  "success": true,
  "config": {
    "max_upload_size_mb": 100,
    "allowed_extensions": [".zip", ".rar", ".7z"],
    "allowed_image_extensions": [".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff"],
    "ocr_language": ["ch_sim", "ch_tra", "en"],
    "llm_model": "gemini-2.5-flash",
    "upload_dir": "/app/data/uploads",
    "output_dir": "/app/data/outputs"
  }
}
```

**狀態碼**：
* `200 OK`：成功

---

## 錯誤處理

所有錯誤回應都遵循以下格式：

```json
{
  "detail": "錯誤訊息描述"
}
```

### 常見錯誤碼

| 狀態碼 | 說明 |
| --- | --- |
| 400 | 請求格式不正確或參數無效 |
| 404 | 資源不存在 |
| 500 | 伺服器內部錯誤 |

---

## 使用範例

### Python 範例

```python
import requests
import json

# 上傳檔案
url = "http://localhost:8000/api/process"
files = {"file": open("checklist.zip", "rb")}
data = {
    "project_name": "Project_A",
    "use_llm_correction": True,
    "api_key": "your_gemini_api_key"
}

response = requests.post(url, files=files, data=data)
result = response.json()

if result["success"]:
    print(f"處理成功，記錄 ID: {result['record_id']}")
    print(f"耗時: {result['total_time']} 秒")
else:
    print(f"處理失敗: {result['message']}")

# 查詢記錄
record_id = result["record_id"]
url = f"http://localhost:8000/api/records/{record_id}"
response = requests.get(url)
record = response.json()["record"]

print(f"狀態: {record['overall_status']}")
print(f"OCR 置信度: {record['ocr_confidence']:.2%}")
print(f"LLM 置信度: {record['llm_confidence']:.2%}")

# 下載結果
download_url = f"http://localhost:8000/api/download/{record_id}?file_type=docx"
response = requests.get(download_url)

with open("result.docx", "wb") as f:
    f.write(response.content)
```

### cURL 範例

```bash
# 上傳檔案
curl -X POST http://localhost:8000/api/process \\
  -F "file=@checklist.zip" \\
  -F "project_name=Project_A" \\
  -F "use_llm_correction=true" \\
  -F "api_key=your_gemini_api_key" \\
  -o response.json

# 查詢記錄
curl http://localhost:8000/api/records/1 | jq .

# 下載檔案
curl -O http://localhost:8000/api/download/1?file_type=docx
```

### JavaScript/Node.js 範例

```javascript
const FormData = require('form-data');
const fs = require('fs');
const axios = require('axios');

async function processFile() {
  const formData = new FormData();
  formData.append('file', fs.createReadStream('checklist.zip'));
  formData.append('project_name', 'Project_A');
  formData.append('use_llm_correction', 'true');
  formData.append('api_key', 'your_gemini_api_key');

  try {
    const response = await axios.post(
      'http://localhost:8000/api/process',
      formData,
      { headers: formData.getHeaders() }
    );
    
    console.log('處理成功:', response.data);
  } catch (error) {
    console.error('處理失敗:', error.response.data);
  }
}

processFile();
```

---

## 速率限制

目前系統不實施速率限制。未來版本將支援基於 IP 或 API Key 的速率限制。

## 版本控制

API 版本在 URL 中指定。目前版本為 `v1`（隱含）。

## 變更日誌

### v1.0.0 (2026-04-22)
* 初始版本發佈
* 支援檔案上傳與處理
* 支援記錄查詢與下載
* 支援統計資訊查詢

---
*Last Updated: 2026-04-22*
*Developed by Manus AI*
