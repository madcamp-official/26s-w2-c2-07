String formatRelativeDate(DateTime dateTimeUtc) {
  final dateTime = dateTimeUtc.toLocal();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final diffDays = today.difference(target).inDays;

  if (diffDays == 0) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '오늘 $hour:$minute';
  }
  if (diffDays == 1) return '어제';
  return '${dateTime.month}월 ${dateTime.day}일';
}
