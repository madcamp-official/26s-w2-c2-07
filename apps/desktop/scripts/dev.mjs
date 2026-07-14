import { spawn } from "node:child_process";
import http from "node:http";
import net from "node:net";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const desktopRoot = path.resolve(__dirname, "..");
const repoRoot = path.resolve(desktopRoot, "..", "..");
const webRoot = path.join(repoRoot, "apps", "web");
const preferredWebPort = Number.parseInt(process.env.NOOK_WEB_PORT || "3000", 10);
const configuredWebUrl = process.env.NOOK_WEB_APP_URL;
const npmCommand = process.platform === "win32" ? "npm.cmd" : "npm";
const electronBin = path.join(
  desktopRoot,
  "node_modules",
  ".bin",
  process.platform === "win32" ? "electron.cmd" : "electron"
);

const children = new Set();

function findAvailablePort(startPort = 3000) {
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

function run(command, args, options = {}) {
  const child = spawn(command, args, {
    stdio: "inherit",
    shell: process.platform === "win32",
    ...options
  });

  children.add(child);
  child.on("exit", () => children.delete(child));
  return child;
}

function waitForWebApp(url, timeoutMs = 60_000) {
  const startedAt = Date.now();

  return new Promise((resolve, reject) => {
    const tick = () => {
      const request = http.get(url, (response) => {
        response.resume();
        resolve();
      });

      request.on("error", () => {
        if (Date.now() - startedAt > timeoutMs) {
          reject(new Error(`Timed out waiting for ${url}`));
          return;
        }

        setTimeout(tick, 500);
      });

      request.setTimeout(1_000, () => {
        request.destroy();
      });
    };

    tick();
  });
}

function shutdown() {
  for (const child of children) {
    child.kill();
  }
}

process.on("SIGINT", () => {
  shutdown();
  process.exit(130);
});

process.on("SIGTERM", () => {
  shutdown();
  process.exit(143);
});

const webPort = configuredWebUrl
  ? undefined
  : await findAvailablePort(Number.isFinite(preferredWebPort) ? preferredWebPort : 3000);
const webUrl = configuredWebUrl || `http://127.0.0.1:${webPort}`;

if (!configuredWebUrl) {
  const web = run(
    npmCommand,
    ["run", "dev", "--", "--hostname", "127.0.0.1", "--port", String(webPort)],
    { cwd: webRoot }
  );

  web.on("exit", (code) => {
    if (code !== 0) process.exit(code ?? 1);
  });
}

await waitForWebApp(webUrl);

const electron = run(electronBin, ["."], {
  cwd: desktopRoot,
  env: {
    ...process.env,
    NOOK_WEB_APP_URL: webUrl
  }
});

electron.on("exit", (code) => {
  shutdown();
  process.exit(code ?? 0);
});
