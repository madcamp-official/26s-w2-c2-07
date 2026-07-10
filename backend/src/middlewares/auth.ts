import type { NextFunction, Request, Response } from "express";
import { supabaseAuth } from "../lib/supabase.js";
import { HttpError } from "../utils/http-error.js";

/**
 * Verifies the Supabase access token from the Authorization header and
 * attaches the resolved user to req.user. Every downstream handler must
 * derive ownership from req.user.id — never from the request body.
 */
export async function requireAuth(req: Request, _res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  const token = header?.startsWith("Bearer ") ? header.slice("Bearer ".length) : undefined;

  if (!token) {
    return next(HttpError.unauthorized("Missing access token"));
  }

  const { data, error } = await supabaseAuth.auth.getUser(token);

  if (error || !data.user) {
    return next(HttpError.unauthorized("Invalid or expired access token"));
  }

  req.user = { id: data.user.id, email: data.user.email };
  next();
}
