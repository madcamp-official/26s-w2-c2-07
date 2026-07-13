# Nook Mobile (Flutter)

Flutter 기반의 모바일 글감 수집 앱입니다.

## 최초 설정

현재 저장소에는 Flutter SDK 없이 작성 가능한 Dart 소스와 설정이 포함되어 있습니다. Flutter SDK 설치 후 다음 명령으로 Android/iOS 플랫폼 파일을 생성합니다.

```bash
cd apps/mobile
flutter create --platforms=android,ios --project-name nook_mobile .
flutter pub get
flutter run
```

Windows PowerShell에서는 환경 파일을 다음과 같이 복사합니다.

```powershell
Copy-Item .env.example .env
```

`flutter create`가 기존 `lib/main.dart` 교체 여부를 묻는다면 현재 파일을 유지합니다.

## Android 로컬 API

Android 에뮬레이터에서 호스트의 백엔드에 접근할 때 `.env`의 `API_URL`은 `http://10.0.2.2:4000/api/v1`을 사용합니다. 실제 기기에서는 개발 PC의 같은 네트워크 IP와 `/api/v1` 경로를 사용해야 합니다.

## 남은 네이티브 설정

- Supabase Google OAuth용 Android deep link 및 iOS URL scheme
- Android `INTERNET`, 카메라·사진 권한
- iOS `Info.plist` 카메라·사진 라이브러리 설명
- 앱 아이콘, bundle/application ID, 서명 설정
