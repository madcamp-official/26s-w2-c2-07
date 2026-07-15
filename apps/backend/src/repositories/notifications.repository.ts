import { supabaseAdmin } from "../lib/supabase.js";
import { HttpError } from "../utils/http-error.js";
import type { NotificationSource } from "../schemas/notification.schema.js";

const LIST_LIMIT = 30;

export async function listNotifications(userId: string) {
  const { data, error } = await supabaseAdmin
    .from("notifications")
    .select("*")
    .eq("user_id", userId)
    .order("created_at", { ascending: false })
    .limit(LIST_LIMIT);

  if (error) throw HttpError.badRequest(error.message);
  return data;
}

export async function markNotificationRead(userId: string, notificationId: string) {
  const { data, error } = await supabaseAdmin
    .from("notifications")
    .update({ read: true })
    .eq("user_id", userId)
    .eq("id", notificationId)
    .select("*")
    .single();

  if (error) throw HttpError.notFound("Notification not found");
  return data;
}

export async function markAllNotificationsRead(userId: string) {
  const { error } = await supabaseAdmin
    .from("notifications")
    .update({ read: true })
    .eq("user_id", userId)
    .eq("read", false);

  if (error) throw HttpError.badRequest(error.message);
}

export async function createNotification(
  userId: string,
  source: NotificationSource,
  title: string,
  detail: string | null,
) {
  const { error } = await supabaseAdmin
    .from("notifications")
    .insert({ user_id: userId, source, title, detail });

  if (error) throw HttpError.badRequest(error.message);
}
