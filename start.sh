#!/bin/bash

# 啟動 FastAPI 後端 (在背景執行)
uvicorn backend.api:app --host 0.0.0.0 --port 8000 &
FASTAPI_PID=$!

# 啟動 Streamlit 前端 (在前景執行)
streamlit run app/main.py --server.port 8501 --server.address 0.0.0.0

# 捕捉中斷信號並結束所有進程
trap "kill $FASTAPI_PID; exit" SIGINT SIGTERM
wait
