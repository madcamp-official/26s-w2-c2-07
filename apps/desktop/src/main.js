const fs = require("node:fs");
const { fork } = require("node:child_process");
const http = require("node:http");
const https = require("node:https");
const net = require("node:net");
const path = require("node:path");
const { app, BrowserWindow, ipcMain, shell } = require("electron");

const DEFAULT_WEB_APP_URL = "http://127.0.0.1:3000";
const desktopRoot = path.resolve(__dirname, "..");
const iconPath = path.join(
  desktopRoot,
  "assets",
  process.platform === "win32" ? "icon.ico" : "icon.png"
);
const env = readDesktopEnv();
const configuredWebAppUrl = process.env.NOOK_WEB_APP_URL || env.NOOK_WEB_APP_URL;
const backendUrl = process.env.NOOK_BACKEND_URL || env.NOOK_BACKEND_URL || "";

let mainWindow;
let bundledWebServer;
let resolvedWebAppUrl = configuredWebAppUrl || DEFAULT_WEB_APP_URL;

function readEnvFile(filePath) {
  if (!fs.existsSync(filePath)) return {};

  return fs
    .readFileSync(filePath, "utf8")
    .split(/\r?\n/)
    .reduce((values, line) => {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith("#")) return values;

      const separatorIndex = trimmed.indexOf("=");
      if (separatorIndex === -1) return values;

      const key = trimmed.slice(0, separatorIndex).trim();
      const rawValue = trimmed.slice(separatorIndex + 1).trim();
      values[key] = rawValue.replace(/^["']|["']$/g, "");
      return values;
    }, {});
}

function readDesktopEnv() {
  return {
    ...readEnvFile(path.join(desktopRoot, ".env")),
    ...readEnvFile(path.join(desktopRoot, ".env.local"))
  };
}

function offlineQueuePath() {
  return path.join(app.getPath("userData"), "offline-queue.json");
}

function readOfflineQueue() {
  const filePath = offlineQueuePath();
  if (!fs.existsSync(filePath)) return [];

  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return [];
  }
}

function writeOfflineQueue(items) {
  fs.mkdirSync(app.getPath("userData"), { recursive: true });
  fs.writeFileSync(offlineQueuePath(), JSON.stringify(items, null, 2), "utf8");
}

function registerIpcHandlers() {
  ipcMain.handle("nook:desktop-env", () => ({
    backendUrl,
    webAppUrl: resolvedWebAppUrl,
    offlineQueuePath: offlineQueuePath()
  }));

  ipcMain.handle("nook:offline-queue:read", () => readOfflineQueue());

  ipcMain.handle("nook:offline-queue:write", (_event, items) => {
    writeOfflineQueue(Array.isArray(items) ? items : []);
    return readOfflineQueue();
  });
}

function findAvailablePort(startPort = 32123) {
  return new Promise((resolve) => {
    const server = net.createServer();

    server.listen(startPort, "127.0.0.1", () => {
      const address = server.address();
      const port = typeof address === "object" && address ? address.port : startPort;
      server.close(() => resolve(port));
    });

    server.on("error", () => {
      resolve(findAvailablePort(startPort + 1));
    });
  });
}

function bundledWebServerPath() {
  const unpackedPath = path.join(
    process.resourcesPath,
    "app.asar.unpacked",
    "web-bundle",
    "apps",
    "web",
    "server.js"
  );
  const unpackedDirPath = path.join(
    process.resourcesPath,
    "app",
    "web-bundle",
    "apps",
    "web",
    "server.js"
  );
  const devPath = path.join(desktopRoot, "web-bundle", "apps", "web", "server.js");

  for (const candidate of [unpackedPath, unpackedDirPath, devPath]) {
    if (fs.existsSync(candidate)) return candidate;
  }

  return undefined;
}

async function startBundledWebServer() {
  if (configuredWebAppUrl) return resolvedWebAppUrl;

  const serverPath = bundledWebServerPath();
  if (!serverPath) return resolvedWebAppUrl;

  const port = await findAvailablePort();
  const serverRoot = path.dirname(serverPath);
  resolvedWebAppUrl = `http://127.0.0.1:${port}`;

  bundledWebServer = fork(serverPath, {
    cwd: serverRoot,
    env: {
      ...process.env,
      HOSTNAME: "127.0.0.1",
      PORT: String(port),
      NEXT_PUBLIC_API_URL: backendUrl || process.env.NEXT_PUBLIC_API_URL || ""
    },
    stdio: "ignore"
  });

  return resolvedWebAppUrl;
}

function waitForWebApp(url, timeoutMs = 30000) {
  const startedAt = Date.now();
  const client = new URL(url).protocol === "https:" ? https : http;

  return new Promise((resolve, reject) => {
    const check = () => {
      const request = client.get(url, (response) => {
        response.resume();
        resolve();
      });

      request.on("error", () => {
        if (Date.now() - startedAt > timeoutMs) {
          reject(new Error(`Timed out waiting for ${url}`));
          return;
        }

        setTimeout(check, 250);
      });

      request.setTimeout(1000, () => {
        request.destroy();
      });
    };

    check();
  });
}

function isNavigationAbort(error) {
  return error?.code === "ERR_ABORTED" || /\(-3\)|ERR_ABORTED/.test(error?.message || "");
}

async function loadSplashScreen() {
  if (!mainWindow || mainWindow.isDestroyed()) return;

  try {
    await mainWindow.loadFile(path.join(__dirname, "splash.html"));
  } catch (error) {
    if (!isNavigationAbort(error)) throw error;
  }
}

async function loadWebAppWithRetry(url, attempts = 3) {
  let lastError;

  for (let attempt = 1; attempt <= attempts; attempt += 1) {
    if (!mainWindow || mainWindow.isDestroyed()) return;

    try {
      await mainWindow.loadURL(url);
      return;
    } catch (error) {
      lastError = error;

      if (!isNavigationAbort(error) || attempt === attempts) break;
      await new Promise((resolve) => setTimeout(resolve, 350 * attempt));
    }
  }

  throw lastError;
}

function desktopLoadErrorHtml(targetUrl, message) {
  return `
    <!doctype html>
    <html lang="ko">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Nook</title>
        <style>
          :root {
            color: #38291f;
            background: #f8f3ea;
            font-family: "Pretendard", "Apple SD Gothic Neo", "Malgun Gothic", sans-serif;
          }

          body {
            align-items: center;
            display: flex;
            min-height: 100vh;
            margin: 0;
            justify-content: center;
          }

          main {
            background: rgba(255, 254, 250, 0.82);
            border: 1px solid rgba(128, 94, 66, 0.18);
            border-radius: 28px;
            box-shadow: 0 24px 80px rgba(74, 52, 34, 0.14);
            max-width: 560px;
            padding: 40px;
          }

          h1 {
            font-size: 28px;
            margin: 0 0 14px;
          }

          p {
            line-height: 1.7;
            margin: 0 0 12px;
          }

          code {
            background: #efe4d7;
            border-radius: 10px;
            display: inline-block;
            margin-top: 8px;
            padding: 6px 9px;
          }
        </style>
      </head>
      <body>
        <main>
          <h1>Nook을 불러오지 못했어요.</h1>
          <p>스플래시 화면은 정상적으로 열렸지만, 웹 화면이 아직 준비되지 않았습니다.</p>
          <p>개발 모드라면 웹 앱 서버가 실행 중인지 확인해 주세요.</p>
          <code>${targetUrl}</code>
          <p>${message}</p>
        </main>
      </body>
    </html>
  `;
}

async function createMainWindow() {
  mainWindow = new BrowserWindow({
    width: 1440,
    height: 960,
    minWidth: 1180,
    minHeight: 760,
    title: "Nook",
    icon: iconPath,
    backgroundColor: "#f8f3ea",
    autoHideMenuBar: true,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false,
      partition: "persist:nook",
      preload: path.join(__dirname, "preload.js")
    }
  });

  await loadSplashScreen();

  try {
    await Promise.all([
      waitForWebApp(resolvedWebAppUrl),
      new Promise((resolve) => setTimeout(resolve, 650))
    ]);

    if (mainWindow && !mainWindow.isDestroyed()) {
      await loadWebAppWithRetry(resolvedWebAppUrl);
    }
  } catch (error) {
    if (mainWindow && !mainWindow.isDestroyed()) {
      await mainWindow.loadURL(
        `data:text/html;charset=utf-8,${encodeURIComponent(
          desktopLoadErrorHtml(resolvedWebAppUrl, error.message)
        )}`
      );
    }
  }

  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    const targetOrigin = new URL(url).origin;
    const appOrigin = new URL(resolvedWebAppUrl).origin;

    if (targetOrigin === appOrigin) {
      return { action: "allow" };
    }

    shell.openExternal(url);
    return { action: "deny" };
  });

  mainWindow.on("closed", () => {
    mainWindow = null;
  });
}

app.whenReady().then(async () => {
  registerIpcHandlers();
  await startBundledWebServer();
  await createMainWindow();

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      void createMainWindow();
    }
  });
});

app.on("window-all-closed", () => {
  if (process.platform !== "darwin") {
    app.quit();
  }
});

app.on("before-quit", () => {
  if (bundledWebServer) {
    bundledWebServer.kill();
    bundledWebServer = undefined;
  }
});
