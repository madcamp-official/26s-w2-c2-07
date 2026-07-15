import * as notificationsRepository from "../repositories/notifications.repository.js";
import * as profilesRepository from "../repositories/profiles.repository.js";
import type { NotificationSource } from "../schemas/notification.schema.js";

export function listNotifications(userId: string) {
  return notificationsRepository.listNotifications(userId);
}

export function markNotificationRead(userId: string, notificationId: string) {
  return notificationsRepository.markNotificationRead(userId, notificationId);
}

export function markAllNotificationsRead(userId: string) {
  return notificationsRepository.markAllNotificationsRead(userId);
}

// 글감 생성처럼 알림을 유발하는 이벤트에서 호출한다.
// 설정에서 알림을 꺼둔 사용자에게는 조용히 아무 일도 하지 않는다.
export async function notifyIfEnabled(
  userId: string,
  source: NotificationSource,
  title: string,
  detail: string | null,
) {
  const settings = await profilesRepository.getSettings(userId);
  if (!settings.notify_enabled) return;

  await notificationsRepository.createNotification(userId, source, title, detail);
}
