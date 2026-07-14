const { app, BrowserWindow, shell } = require("electron");

const DEFAULT_WEB_APP_URL = "http://127.0.0.1:3000";
const webAppUrl = process.env.NOOK_WEB_APP_URL || DEFAULT_WEB_APP_URL;

let mainWindow;

function createMainWindow() {
  mainWindow = new BrowserWindow({
    width: 1440,
    height: 960,
    minWidth: 1180,
    minHeight: 760,
    title: "Nook",
    backgroundColor: "#f8f3ea",
    autoHideMenuBar: true,
    webPreferences: {
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: true
    }
  });

  mainWindow.loadURL(webAppUrl);

  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    const targetOrigin = new URL(url).origin;
    const appOrigin = new URL(webAppUrl).origin;

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

app.whenReady().then(() => {
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
