import * as profilesRepository from "../repositories/profiles.repository.js";
import type { UpdateSettingsInput } from "../schemas/settings.schema.js";

function toDto(row: { notify_enabled: boolean; dark_editor: boolean }) {
  return {
    captureAlertsEnabled: row.notify_enabled,
    darkEditorEnabled: row.dark_editor,
  };
}

export async function getSettings(userId: string) {
  return toDto(await profilesRepository.getSettings(userId));
}

export async function updateSettings(userId: string, input: UpdateSettingsInput) {
  const row = await profilesRepository.updateSettings(userId, {
    notifyEnabled: input.captureAlertsEnabled,
    darkEditor: input.darkEditorEnabled,
  });
  return toDto(row);
}
