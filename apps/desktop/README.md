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

## 데스크탑 환경 변수

`apps/desktop/.env.example`을 복사해 `apps/desktop/.env`를 만들 수 있습니다.

```bash
cp .env.example .env
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

사용 가능한 값:

```env
NOOK_WEB_APP_URL=http://127.0.0.1:3000
NOOK_BACKEND_URL=http://127.0.0.1:4000/api
```

- `NOOK_WEB_APP_URL`: 외부/개발 웹 프론트 주소를 직접 지정합니다.
- `NOOK_BACKEND_URL`: 데스크탑 앱에서 우선 사용할 백엔드 API 주소입니다.

`NOOK_WEB_APP_URL`을 비워두고 패키징하면 데스크탑 앱에 포함된 Next.js standalone 서버를 자동 실행합니다.

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

현재 `npm run dist`는 `apps/web`을 Next.js standalone으로 빌드한 뒤 Electron 패키지에 포함합니다. 그래서 별도의 웹 개발 서버 없이도 배포 파일만으로 UI가 실행됩니다.

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

## 오프라인 저장과 동기화

데스크탑 앱은 백엔드 요청이 실패할 때 변경 요청을 로컬 JSON 파일에 저장합니다.

- 저장 위치: Electron `userData` 디렉터리의 `offline-queue.json`
- 저장 대상: `POST`, `PATCH`, `PUT`, `DELETE`
- 동기화 시점: 이후 백엔드 요청이 성공하면 큐에 쌓인 요청을 순서대로 재전송

이 기능은 백엔드가 잠시 꺼져 있어도 사용자가 만든 변경을 잃지 않기 위한 1차 로컬 우선 장치입니다. 충돌 해결이나 필드 단위 merge 정책은 아직 포함하지 않았습니다.

## 로그인 유지

Electron 세션 partition을 `persist:nook`로 고정해 Supabase 로그인 세션과 브라우저 저장소가 프로그램 재시작 후에도 유지됩니다. 사용자가 직접 로그아웃하지 않으면 다음 실행 때 다시 로그인하지 않아도 됩니다.

## 시작 랜딩 화면

앱 실행 직후 `Nook` 로고와 캐치프레이즈가 페이드 인된 뒤 웹 UI로 전환됩니다. 파일은 `src/splash.html`입니다.

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
- 패키징 시 `web-bundle`이 포함되며, 이 폴더는 `npm run build:web`으로 생성됩니다.
