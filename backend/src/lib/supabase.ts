import { createClient } from "@supabase/supabase-js";
import { env } from "../config/env.js";

/**
 * Service-role client: bypasses RLS. Only used inside repositories, which
 * must always scope queries by the authenticated user's id themselves.
 */
export const supabaseAdmin = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

/**
 * Anon-key client: used only to verify a client-supplied access token
 * (supabase.auth.getUser) inside the auth middleware.
 */
export const supabaseAuth = createClient(env.SUPABASE_URL, env.SUPABASE_ANON_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});
