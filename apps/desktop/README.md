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
