# Nook Desktop

웹 프론트엔드와 동일한 UI를 보여주는 Nook 데스크탑 앱입니다.

기존 `apps/mobile` 안의 Flutter 데스크탑 설정은 그대로 두고, 이 앱은 별도의 Electron shell로 동작합니다. 화면은 새로 구현하지 않고 `apps/web`의 Next.js 앱을 그대로 로드하므로 웹과 데스크탑 UI가 항상 같은 기준을 공유합니다.

## 실행

처음 한 번:

```bash
cd apps/desktop
npm install
```

개발 실행:

```bash
npm run dev
```

`npm run dev`는 내부적으로 다음을 함께 실행합니다.

- `apps/web`의 Next.js 개발 서버
- Electron 데스크탑 창

Windows에서 `spawn EINVAL`이 발생하지 않도록 개발 스크립트는 `npm.cmd`와 `electron.cmd`를 shell 경유로 실행합니다.

## 외부 웹 서버를 직접 연결하기

이미 웹 앱이 실행 중이라면 아래처럼 URL을 지정할 수 있습니다.

```bash
NOOK_WEB_APP_URL=http://127.0.0.1:3000 npm start
```

Windows PowerShell:

```powershell
$env:NOOK_WEB_APP_URL="http://127.0.0.1:3000"
npm start
```

## 실행 파일 만들기

처음 한 번:

```bash
cd apps/desktop
npm install
```

Windows 설치 파일과 portable 실행 파일 생성:

```bash
npm run dist
```

빠르게 패키징 결과 폴더만 확인:

```bash
npm run dist:dir
```

빌드 결과는 `apps/desktop/release` 아래에 생성됩니다.

중요: 현재 데스크탑 앱은 웹 UI와 완전히 동일하게 유지하기 위해 `apps/web` 화면을 URL로 로드하는 shell입니다. 따라서 배포 실행 파일을 사용자에게 전달하려면 다음 중 하나가 필요합니다.

1. 운영용 웹 프론트 URL을 배포해두고 실행 시 `NOOK_WEB_APP_URL`로 지정
2. 앱 내부에 Next.js production server를 함께 포함하도록 추가 패키징 작업 진행

현재 구조에서 운영 웹 URL을 지정해 패키징/실행하는 예:

```powershell
$env:NOOK_WEB_APP_URL="https://your-nook-web.example.com"
npm run dist
```

로컬에서 패키징된 앱을 테스트할 때는 먼저 웹 서버를 켠 뒤 실행하세요.

```bash
cd apps/web
npm run dev
```

다른 터미널:

```bash
cd apps/desktop
npm start
```

## 구조

```text
apps/desktop
├─ package.json
├─ scripts
│  ├─ check.mjs
│  └─ dev.mjs
└─ src
   └─ main.js
```

## 설계 메모

- 웹과 동일한 UI가 목표이므로 별도 Flutter/React 화면을 만들지 않습니다.
- 데스크탑 앱은 `BrowserWindow`로 웹 앱 URL을 로드합니다.
- 외부 링크는 기본 브라우저로 열어 데스크탑 앱 내부 라우팅과 분리합니다.
- 배포 패키징은 아직 추가하지 않았습니다. 배포가 필요해지면 `electron-builder` 또는 `electron-forge` 설정을 별도 커밋으로 추가합니다.
- `electron-builder`로 Windows `nsis`, `portable` 패키징을 지원합니다.
