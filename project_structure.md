# 工程施工自主檢查表智能生成系統 - 系統架構設計

## 系統概述

本系統是一個完整的工程施工檢查表自動化生成平台，通過集成 OCR、LLM 和文檔處理技術，幫助工程師快速生成規範的檢查表文檔。

### 核心功能流程

```
用戶上傳 ZIP 檔案
    ↓
Streamlit 前端接收並驗證
    ↓
FastAPI 後端解壓縮並讀取資料夾結構
    ↓
PaddleOCR 辨識白板照片文字
    ↓
Gemini LLM 進行智能糾錯與術語標準化
    ↓
python-docx 填入 Word 範本
    ↓
SQLite 記錄處理歷程
    ↓
生成 ZIP 檔案供用戶下載
```

## 技術棧選型

| 層級 | 技術選擇 | 原因 |
|------|--------|------|
| **前端** | Streamlit | 快速原型開發，無需 HTML/CSS/JS 知識 |
| **後端** | FastAPI | 高性能非同步 API，原生支援文件上傳 |
| **數據庫** | SQLite | 輕量級，無需額外伺服器配置 |
| **圖像處理** | Pillow (PIL) | 輕量級圖像操作，適合裁切與壓縮 |
| **OCR** | PaddleOCR | 開源免費，繁體中文支援優秀 |
| **LLM** | Google Gemini API | 免費配額充足，工程術語理解能力強 |
| **文檔生成** | python-docx | 原生 Word 支援，無需 MS Office |
| **部署** | Docker | 環境隔離，跨平台相容性 |

## 專案目錄結構

```
construction_checklist_system/
├── venv/                           # Python 虛擬環境
├── app/
│   ├── __init__.py
│   ├── main.py                     # Streamlit 前端入口
│   ├── config.py                   # 配置檔案（API Key、路徑等）
│   └── utils/
│       ├── __init__.py
│       ├── image_processor.py      # 圖像處理模組
│       ├── ocr_processor.py        # OCR 模組
│       ├── llm_corrector.py        # LLM 糾錯模組
│       ├── docx_generator.py       # Word 文檔生成模組
│       ├── file_handler.py         # ZIP 解壓縮與檔案管理
│       └── database.py             # SQLite 資料庫操作
├── backend/
│   ├── __init__.py
│   ├── api.py                      # FastAPI 應用
│   ├── models.py                   # SQLAlchemy 資料模型
│   └── schemas.py                  # Pydantic 數據驗證模型
├── templates/
│   └── checklist_template.docx     # Word 檢查表範本
├── data/
│   ├── uploads/                    # 用戶上傳的臨時檔案
│   ├── outputs/                    # 生成的輸出檔案
│   └── database.db                 # SQLite 數據庫檔案
├── requirements.txt                # 依賴清單
├── Dockerfile                      # Docker 配置
├── docker-compose.yml              # Docker Compose 配置
├── README.md                       # 使用文檔
└── .env.example                    # 環境變數範本
```

## 各模組職責

### 1. 圖像處理模組 (image_processor.py)
- 讀取上傳的照片
- 自動裁切和壓縮圖像
- 統一長寬比（例如 A4 尺寸的表格單元格）
- 輸出適合嵌入 Word 的圖像格式

### 2. OCR 模組 (ocr_processor.py)
- 初始化 PaddleOCR 模型
- 對圖像進行文字辨識
- 返回辨識結果與置信度
- 處理繁體中文手寫文字

### 3. LLM 糾錯模組 (llm_corrector.py)
- 構建工程術語 Prompt
- 調用 Gemini API 進行智能糾錯
- 解析 JSON 格式的糾正結果
- 提取標準化的工程資訊（日期、地點、項目、規格）

### 4. Word 文檔生成模組 (docx_generator.py)
- 讀取 Word 範本
- 替換佔位符（{{image_1}}、{{date}} 等）
- 嵌入處理後的圖像
- 填入 OCR + LLM 的結果
- 輸出最終的 Word 文檔

### 5. 檔案管理模組 (file_handler.py)
- 解壓縮用戶上傳的 ZIP 檔案
- 讀取資料夾結構（例如 600樁號_3T4上）
- 識別白板照片與其他檔案
- 組織文件處理流程
- 壓縮輸出檔案為 ZIP

### 6. 資料庫模組 (database.py)
- SQLite 連接管理
- 記錄處理歷程（輸入檔案、OCR 結果、LLM 糾正、輸出檔案）
- 提供查詢介面

### 7. FastAPI 後端 (api.py)
- 提供 REST API 端點
- 處理文件上傳
- 協調各模組工作流
- 返回處理結果

### 8. Streamlit 前端 (main.py)
- 使用者友善的上傳介面
- 實時處理進度顯示
- 結果預覽
- 檔案下載功能

## 數據流

```
用戶上傳 ZIP
    ↓
[Streamlit] 驗證檔案格式
    ↓
[FastAPI] 接收上傳
    ↓
[file_handler] 解壓縮 → 讀取資料夾結構
    ↓
[image_processor] 裁切、壓縮圖像
    ↓
[ocr_processor] 辨識文字 → 原始亂碼文字
    ↓
[llm_corrector] 糾正 → 標準化結果 (JSON)
    ↓
[docx_generator] 填入 Word 範本
    ↓
[database] 記錄處理歷程
    ↓
[file_handler] 壓縮輸出為 ZIP
    ↓
[Streamlit] 提供下載連結
```

## 部署架構

```
┌─────────────────────────────────┐
│   Streamlit 前端 (Port 8501)    │
└────────────┬────────────────────┘
             │ HTTP 請求
             ↓
┌─────────────────────────────────┐
│   FastAPI 後端 (Port 8000)      │
├─────────────────────────────────┤
│ ├─ 檔案上傳與解壓縮            │
│ ├─ OCR 處理協調                │
│ ├─ LLM API 調用                │
│ └─ Word 文檔生成               │
└────────────┬────────────────────┘
             │
     ┌───────┴───────┐
     ↓               ↓
┌──────────┐   ┌──────────────┐
│ SQLite   │   │ 本地檔案系統  │
│ 資料庫   │   │ (uploads/)   │
└──────────┘   └──────────────┘
```

## 環境配置

### 必要的 API Key
- `GEMINI_API_KEY`: Google Gemini API 金鑰（用於 LLM 糾錯）
- `OPENAI_API_KEY`: OpenAI API 金鑰（備用選項）

### 環境變數
- `UPLOAD_DIR`: 上傳檔案存儲目錄
- `OUTPUT_DIR`: 輸出檔案存儲目錄
- `DATABASE_URL`: SQLite 資料庫路徑
- `TEMPLATE_PATH`: Word 範本路徑
- `MAX_UPLOAD_SIZE`: 最大上傳檔案大小（MB）

## 開發時程表

| 階段 | 任務 | 預計時間 |
|------|------|--------|
| 1 | 系統架構設計 | 已完成 |
| 2 | 圖像與文檔處理模組 | 進行中 |
| 3 | OCR 模組整合 | 進行中 |
| 4 | LLM 糾錯模組 | 進行中 |
| 5 | 邏輯整合主程式 | 進行中 |
| 6 | Streamlit 前端 | 進行中 |
| 7 | FastAPI 後端 | 進行中 |
| 8 | Docker 部署 | 進行中 |
| 9 | 文檔與交付 | 進行中 |

## 下一步行動

1. 建立專案目錄結構
2. 開發文檔與圖像處理模組
3. 集成 PaddleOCR
4. 集成 Gemini LLM
5. 構建 Streamlit 前端
6. 構建 FastAPI 後端
7. 編寫 Docker 配置
8. 完整測試與文檔
