import type { NextFunction, Request, Response } from "express";
import { ZodError } from "zod";
import { env } from "../config/env.js";
import { HttpError } from "../utils/http-error.js";

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction) {
  if (err instanceof ZodError) {
    return res.status(400).json({
      error: { message: "Validation failed", details: err.flatten() },
    });
  }

  if (err instanceof HttpError) {
    return res.status(err.status).json({
      error: { message: err.message, details: err.details },
    });
  }

  console.error(err);
  return res.status(500).json({
    error: {
      message: "Internal Server Error",
      ...(env.NODE_ENV === "development" && err instanceof Error ? { details: err.stack } : {}),
    },
  });
}
