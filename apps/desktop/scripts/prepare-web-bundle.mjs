import { cp, mkdir, rm } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const desktopRoot = path.resolve(__dirname, "..");
const repoRoot = path.resolve(desktopRoot, "..", "..");
const webRoot = path.join(repoRoot, "apps", "web");
const bundleRoot = path.join(desktopRoot, "web-bundle");
const standaloneRoot = path.join(webRoot, ".next", "standalone");
const standaloneWebRoot = path.join(standaloneRoot, "apps", "web");

await rm(bundleRoot, { recursive: true, force: true });
await mkdir(bundleRoot, { recursive: true });

await cp(standaloneRoot, bundleRoot, { recursive: true });
await mkdir(path.join(bundleRoot, "apps", "web", ".next"), {
  recursive: true
});
await cp(path.join(webRoot, ".next", "static"), path.join(standaloneWebRoot, ".next", "static"), {
  recursive: true
});

try {
  await cp(path.join(webRoot, "public"), path.join(standaloneWebRoot, "public"), {
    recursive: true
  });
} catch {
  // The web app currently does not require a public directory.
}

console.log(`Prepared desktop web bundle at ${bundleRoot}`);
