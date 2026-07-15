import { access, readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const desktopRoot = path.resolve(__dirname, "..");
const requiredFiles = [
  "package.json",
  "src/main.js",
  "src/preload.js",
  "src/splash.html",
  "scripts/dev.mjs",
  "scripts/prepare-web-bundle.mjs",
  "../web/package.json",
  "../web/app/layout.tsx"
];

for (const file of requiredFiles) {
  await access(path.join(desktopRoot, file));
}

const mainSource = await readFile(path.join(desktopRoot, "src/main.js"), "utf8");

if (!mainSource.includes("loadWebAppWithRetry(resolvedWebAppUrl)")) {
  throw new Error("Desktop app must load the web app URL to keep UI identical.");
}

console.log("Desktop shell check passed.");
