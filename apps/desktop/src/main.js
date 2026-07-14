const fs = require("node:fs");
const { fork } = require("node:child_process");
const net = require("node:net");
const path = require("node:path");
const { app, BrowserWindow, ipcMain, shell } = require("electron");

const DEFAULT_WEB_APP_URL = "http://127.0.0.1:3000";
const desktopRoot = path.resolve(__dirname, "..");
const iconPath = path.join(desktopRoot, "assets", "icon.png");
const env = readEnvFile(path.join(desktopRoot, ".env"));
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
  if (configuredWebAppUrl || !app.isPackaged) return resolvedWebAppUrl;

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

function createMainWindow() {
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

  mainWindow.loadFile(path.join(__dirname, "splash.html"));

  setTimeout(() => {
    if (mainWindow && !mainWindow.isDestroyed()) {
      mainWindow.loadURL(resolvedWebAppUrl);
    }
  }, 650);

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
  createMainWindow();

  app.on("activate", () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createMainWindow();
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
