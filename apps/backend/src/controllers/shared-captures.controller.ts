import type { Request, Response } from "express";
import { HttpError } from "../utils/http-error.js";

const notImplemented = () =>
  new HttpError(
    501,
    "Shared capture surf API is not implemented yet. Frontend falls back to dummy data.",
  );

export async function listSharedCaptures(_req: Request, _res: Response) {
  throw notImplemented();
}

export async function saveSharedCapture(_req: Request, _res: Response) {
  throw notImplemented();
}

export async function reportSharedCapture(_req: Request, _res: Response) {
  throw notImplemented();
}
