import "express";

declare global {
  namespace Express {
    interface Request {
      /** Set by the auth middleware after verifying the Supabase access token. */
      user?: {
        id: string;
        email: string | undefined;
      };
    }
  }
}
