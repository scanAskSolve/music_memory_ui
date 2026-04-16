# 音樂記憶 Music Memory — Frontend

音樂記憶前端應用，使用 Flutter 構建跨平台 UI（iOS / Android / Web）。

## 專案簡介

音樂記憶是一款結合 YouTube 音樂解析、AI 智慧推薦與社交探索的音樂應用程式。用戶可透過分享 YouTube 音樂網址，自動解析並記錄音樂資訊，並透過類似交友軟體的滑動互動方式探索新音樂。

## 技術棧

| 技術 | 用途 |
|------|------|
| Flutter 3.x | 跨平台 UI 框架 |
| firebase_auth | 用戶認證（OAuth） |
| google_sign_in | Google 登入 |
| sign_in_with_apple | Apple 登入 |
| flutter_facebook_auth | Facebook 登入 |
| Riverpod | 狀態管理 |
| go_router | 路由管理 |
| Dio | HTTP 客戶端 |
| flutter_swiper | 卡片滑動互動 |
| just_audio | 音訊播放 |
| Hive / Isar | 本地資料庫 |

## 核心功能

- **OAuth 登入**：Google / Apple / Facebook 一鍵登入
- **YouTube 解析**：貼上網址自動解析音樂資訊
- **AI 探索**：滑動卡片式音樂推薦（右滑喜歡 / 左滑跳過 / 愛心收藏）
- **清單管理**：多維度分類、排序、搜尋
- **播放器**：背景播放、鎖屏控制、LRC 同步歌詞
- **歌詞漂浮**：懸浮視窗跨 App 顯示歌詞
- **下載備份**：離線播放與雲端備份

## 文件目錄

```
doc/
├── design/
│   ├── 2026-04-16-product-requirements.md   # 前端需求規格
│   ├── 2026-04-16-technical-architecture.md  # 前端技術架構設計
│   └── 2026-04-16-user-stories.md           # 使用者故事與流程
└── deploy/
    └── 2026-04-16-deployment-guide.md       # 部署指南
```

## 關聯專案

- **後端**：[music_memory](../music_memory/) — Java (Spring Boot)
- **產品設計文件**：[Notion](https://www.notion.so/34495a2a16f7811391b7dca59db3429e)
