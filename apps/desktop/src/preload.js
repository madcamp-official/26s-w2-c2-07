const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("nookDesktop", {
  getEnv: () => ipcRenderer.invoke("nook:desktop-env"),
  readOfflineQueue: () => ipcRenderer.invoke("nook:offline-queue:read"),
  writeOfflineQueue: (items) =>
    ipcRenderer.invoke("nook:offline-queue:write", items)
});
