# 音樂記憶 Flutter 前端 — 部署指南

| 屬性 | 值 |
|------|-----|
| 作者 | Music Memory Team |
| 日期 | 2026-04-16 |
| 狀態 | 草稿 |
| 版本 | v1.0 |

---

## 目錄

1. [環境需求](#1-環境需求)
2. [開發環境設定](#2-開發環境設定)
3. [Firebase 設定](#3-firebase-設定)
4. [各平台建置與部署](#4-各平台建置與部署)
   - 4.1 [Android 部署](#41-android-部署)
   - 4.2 [iOS 部署](#42-ios-部署)
   - 4.3 [Web 部署](#43-web-部署)
5. [CI/CD 設定](#5-cicd-設定)
6. [環境變數管理](#6-環境變數管理)
7. [常見問題排除](#7-常見問題排除)

---

## 1. 環境需求

| 工具 | 最低版本 | 說明 |
|------|---------|------|
| Flutter SDK | 3.24.0+ | 跨平台 UI 框架 |
| Dart SDK | 3.5.0+ | 隨 Flutter 安裝 |
| Android Studio | 2024.1+ | Android 開發 IDE & 模擬器 |
| Xcode | 15.0+ | iOS/macOS 開發（僅 macOS） |
| CocoaPods | 1.15+ | iOS 依賴管理 |
| Node.js | 18+ | Firebase CLI 依賴 |
| Firebase CLI | 13+ | Firebase 專案管理 |
| Git | 2.40+ | 版本控制 |
| Java JDK | 17+ | Android Gradle 建置 |

### 系統需求

- **macOS**：開發 iOS + Android + Web（推薦）
- **Windows**：開發 Android + Web
- **Linux**：開發 Android + Web

---

## 2. 開發環境設定

### 2.1 安裝 Flutter SDK

```bash
# macOS / Linux（使用 FVM 管理版本 - 推薦）
dart pub global activate fvm
fvm install 3.24.0
fvm use 3.24.0

# 或直接安裝
# 參見 https://docs.flutter.dev/get-started/install
```

### 2.2 驗證安裝

```bash
flutter doctor -v
```

確認以下項目均為 ✓：
- Flutter
- Android toolchain
- Xcode (macOS only)
- Chrome (for web)

### 2.3 Clone 專案並安裝依賴

```bash
git clone https://github.com/your-org/music_memory_ui.git
cd music_memory_ui

# 複製環境設定檔
cp .env.example .env
# 編輯 .env 填入正確的後端 API 位址

# 安裝依賴
flutter pub get

# 產生程式碼（freezed / json_serializable / riverpod_generator）
dart run build_runner build --delete-conflicting-outputs
```

### 2.4 本地開發

```bash
# 啟動開發（自動選擇已連線裝置）
flutter run

# 指定裝置
flutter run -d chrome      # Web
flutter run -d emulator     # Android 模擬器
flutter run -d <device_id>  # 指定裝置

# 熱重載已內建，存檔即觸發
```

---

## 3. Firebase 設定

### 3.1 建立 Firebase 專案

1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 建立新專案或選擇現有專案
3. 啟用 **Authentication** 服務

### 3.2 啟用 OAuth 供應商

在 Firebase Console → Authentication → Sign-in method 中啟用：

| 供應商 | 設定事項 |
|--------|---------|
| Google | 啟用即可，自動配置 OAuth Client ID |
| Apple | 需註冊 Apple Developer → Services ID → 配置 Sign-in with Apple |
| Facebook | 需建立 Facebook App → 取得 App ID & App Secret → 填入 Firebase |

### 3.3 取得各平台 Firebase 配置

```bash
# 安裝 Firebase CLI
npm install -g firebase-tools

# 安裝 FlutterFire CLI
dart pub global activate flutterfire_cli

# 登入 Firebase
firebase login

# 自動產生配置（推薦）
flutterfire configure --project=your-firebase-project-id
```

此指令會自動產生 `lib/firebase_options.dart`，取代 `lib/config/firebase_config.dart` 中的佔位值。

### 3.4 手動配置（替代方案）

編輯 `lib/config/firebase_config.dart`，將各平台的 Firebase 配置值填入：

```dart
static const web = FirebaseOptions(
  apiKey: 'AIza...',
  appId: '1:123456789:web:abc...',
  messagingSenderId: '123456789',
  projectId: 'your-project-id',
  authDomain: 'your-project-id.firebaseapp.com',
);
```

### 3.5 Android 配置

1. 下載 `google-services.json` → 放置於 `android/app/`
2. 在 `android/build.gradle` 添加 Google Services 插件
3. 設定 SHA-1 fingerprint（Google Sign-In 必需）

```bash
# 取得 debug SHA-1
cd android
./gradlew signingReport
```

### 3.6 iOS 配置

1. 下載 `GoogleService-Info.plist` → 放置於 `ios/Runner/`
2. 在 Xcode 中設定 URL Schemes（Google Sign-In 必需）
3. 設定 Apple Sign-In Capability

---

## 4. 各平台建置與部署

### 4.1 Android 部署

#### 4.1.1 簽名配置

```bash
# 產生正式 keystore
keytool -genkey -v \
  -keystore android/app/release-key.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias music_memory
```

建立 `android/key.properties`（不要提交至 Git）：

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=music_memory
storeFile=release-key.jks
```

#### 4.1.2 建置 APK / AAB

```bash
# Release APK
flutter build apk --release

# Release AAB（Google Play 上架用）
flutter build appbundle --release

# 產出位置
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

#### 4.1.3 Google Play Console 上架

1. 前往 [Google Play Console](https://play.google.com/console)
2. 建立應用程式
3. 填寫商店資訊（名稱、描述、截圖、圖示）
4. 上傳 AAB 至「正式版」軌道
5. 設定定價（免費/付費）
6. 提交審核

### 4.2 iOS 部署

#### 4.2.1 前置需求

- Apple Developer 帳號（$99/年）
- macOS + Xcode 15+
- 有效的 Provisioning Profile & Certificate

#### 4.2.2 Xcode 設定

```bash
cd ios
pod install
open Runner.xcworkspace
```

在 Xcode 中設定：
- **Bundle Identifier**: `com.musicmemory.app`
- **Team**: 選擇你的開發團隊
- **Signing & Capabilities**: 自動管理簽名 or 手動配置
- 添加 **Sign in with Apple** Capability
- 添加 **Background Modes** → Audio

#### 4.2.3 建置 IPA

```bash
# Release 建置
flutter build ipa --release

# 或指定 export options
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

# 產出位置: build/ios/ipa/music_memory_ui.ipa
```

#### 4.2.4 App Store Connect 上架

1. 前往 [App Store Connect](https://appstoreconnect.apple.com/)
2. 建立新 App
3. 使用 Transporter 或 `xcrun altool` 上傳 IPA：

```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/music_memory_ui.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

4. 填寫 App 資訊（描述、關鍵字、截圖、隱私權政策 URL）
5. 提交審核

### 4.3 Web 部署

#### 4.3.1 建置

```bash
# 使用 CanvasKit renderer（較佳視覺效果）
flutter build web --release --web-renderer canvaskit

# 使用 HTML renderer（較小檔案）
flutter build web --release --web-renderer html

# 自動選擇（推薦）
flutter build web --release --web-renderer auto

# 產出位置: build/web/
```

#### 4.3.2 Firebase Hosting 部署（推薦）

```bash
# 初始化 Firebase Hosting
firebase init hosting

# 設定 public directory: build/web
# 設定 SPA: Yes

# 部署
firebase deploy --only hosting

# 部署至預覽頻道
firebase hosting:channel:deploy preview-v1
```

#### 4.3.3 Nginx 部署（自建伺服器）

Nginx 配置範例：

```nginx
server {
    listen 80;
    server_name app.musicmemory.app;

    root /var/www/music_memory_ui/build/web;
    index index.html;

    # SPA fallback
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 靜態資源快取
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2?)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # gzip 壓縮
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml;
}
```

#### 4.3.4 Docker 部署

建立 `Dockerfile`：

```dockerfile
# 建置階段
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release --web-renderer auto

# 部署階段
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

建置與執行：

```bash
docker build -t music-memory-ui .
docker run -p 80:80 music-memory-ui
```

---

## 5. CI/CD 設定

### 5.1 GitHub Actions

建立 `.github/workflows/ci.yml`：

```yaml
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test

  build-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter build web --release --web-renderer auto
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: build/app/outputs/bundle/release/app-release.aab

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter build ipa --release --no-codesign
      - uses: actions/upload-artifact@v4
        with:
          name: ios-release
          path: build/ios/ipa/
```

### 5.2 GitHub Secrets 設定

在 GitHub → Settings → Secrets and variables → Actions 中新增：

| Secret 名稱 | 說明 |
|-------------|------|
| `FIREBASE_SERVICE_ACCOUNT` | Firebase Hosting 服務帳號金鑰（JSON） |
| `ANDROID_KEYSTORE_BASE64` | Android release keystore (base64 encoded) |
| `ANDROID_KEY_PROPERTIES` | key.properties 內容 |
| `IOS_P12_BASE64` | iOS 發佈憑證 (base64 encoded) |
| `IOS_PROVISION_PROFILE_BASE64` | iOS Provisioning Profile (base64 encoded) |

---

## 6. 環境變數管理

### 6.1 環境檔案

| 環境 | 檔案 | 用途 |
|------|------|------|
| 開發 | `.env` | 本地開發 |
| 測試 | `.env.staging` | 測試環境 |
| 正式 | `.env.production` | 正式環境 |

### 6.2 建置時指定環境

```bash
# 開發環境（預設）
flutter run

# 測試環境
flutter run --dart-define=ENV=staging

# 正式環境
flutter build apk --release --dart-define=ENV=production
```

### 6.3 環境變數清單

| 變數名 | 說明 | 範例 |
|--------|------|------|
| `BASE_URL` | 後端 API 基礎路徑 | `https://api.musicmemory.app/api/v1` |
| `ENV` | 目前環境 | `development` / `staging` / `production` |

---

## 7. 常見問題排除

### 7.1 Flutter 依賴問題

```bash
# 清除並重新安裝依賴
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 7.2 iOS Pod 安裝失敗

```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
```

### 7.3 Android Gradle 建置失敗

```bash
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### 7.4 Firebase 配置錯誤

- 確認 `google-services.json`（Android）或 `GoogleService-Info.plist`（iOS）已正確放置
- 確認 Firebase 專案的 SHA-1 / SHA-256 指紋已添加
- 確認各 OAuth 供應商已在 Firebase Console 中啟用

### 7.5 Web CORS 問題

如果 Web 版開發時遇到跨域問題：

```bash
# 使用 Flutter 開發伺服器時指定 web-port
flutter run -d chrome --web-port=5000

# 確認後端 API 已設定 CORS 允許此 origin
```

### 7.6 Hot Reload 不生效

```bash
# 完整重啟
flutter clean
flutter pub get
flutter run
```

---

## 附錄：專案結構概覽

```
music_memory_ui/
├── lib/
│   ├── main.dart                          # 應用進入點
│   ├── app/
│   │   ├── app.dart                       # MaterialApp 根元件
│   │   ├── router.dart                    # GoRouter 路由 + Auth Guard
│   │   ├── shell.dart                     # 底部導航列殼層
│   │   └── theme.dart                     # 主題定義（亮色/暗色）
│   ├── config/
│   │   └── firebase_config.dart           # Firebase 初始化配置
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart            # Dio HTTP 客戶端 + Token 攔截器
│   │   │   └── api_endpoints.dart         # API 端點常量
│   │   ├── models/
│   │   │   ├── music.dart                 # 音樂資料模型
│   │   │   ├── user_profile.dart          # 用戶資料模型
│   │   │   └── parse_result.dart          # 解析結果模型
│   │   ├── utils/
│   │   │   ├── duration_formatter.dart    # 時長格式化
│   │   │   └── validators.dart            # 網址驗證
│   │   └── widgets/
│   │       ├── loading_overlay.dart       # 載入遮罩
│   │       ├── error_view.dart            # 錯誤顯示元件
│   │       └── music_card.dart            # 音樂卡片元件
│   └── features/
│       ├── auth/                          # OAuth 認證模組
│       ├── home/                          # 首頁模組
│       ├── parse/                         # YouTube 解析模組
│       ├── explore/                       # AI 探索（滑動卡片）模組
│       ├── playlist/                      # 清單管理模組
│       ├── player/                        # 播放器模組（含歌詞、Mini Player）
│       └── settings/                      # 設定頁模組
├── doc/
│   ├── design/                            # 設計文件
│   └── deploy/                            # 部署文件
├── assets/                                # 靜態資源
├── pubspec.yaml                           # 依賴配置
├── analysis_options.yaml                  # 程式碼分析規則
├── .env.example                           # 環境變數範本
└── .gitignore
```

---

## 參考連結

- [Flutter 官方文檔](https://docs.flutter.dev/)
- [Firebase Authentication 文檔](https://firebase.google.com/docs/auth/flutter/start)
- [Flutter Web 部署](https://docs.flutter.dev/deployment/web)
- [Flutter Android 部署](https://docs.flutter.dev/deployment/android)
- [Flutter iOS 部署](https://docs.flutter.dev/deployment/ios)
- [GitHub Actions for Flutter](https://github.com/subosito/flutter-action)
