import 'tag.dart';

enum CaptureType { text, photo, link, video }

CaptureType captureTypeFromString(String value) {
  return CaptureType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => CaptureType.text,
  );
}

class Capture {
  const Capture({
    required this.id,
    required this.type,
    this.content,
    this.url,
    this.linkTitle,
    this.linkDescription,
    this.linkImageUrl,
    this.imageUrl,
    this.isShared = false,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final CaptureType type;
  final String? content;
  final String? url;
  final String? linkTitle;
  final String? linkDescription;
  final String? linkImageUrl;
  final String? imageUrl;
  final bool isShared;
  final List<Tag> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayTitle {
    switch (type) {
      case CaptureType.link:
        if (linkTitle != null && linkTitle!.isNotEmpty) return linkTitle!;
        return url ?? '링크';
      case CaptureType.photo:
      case CaptureType.video:
        if (content != null && content!.trim().isNotEmpty) {
          return content!.trim();
        }
        return type == CaptureType.photo ? '사진' : '동영상';
      case CaptureType.text:
        final text = content?.trim() ?? '';
        if (text.isEmpty) return '(내용 없음)';
        final firstLine = text.split('\n').first;
        return firstLine.length > 40 ? '${firstLine.substring(0, 40)}…' : firstLine;
    }
  }

  factory Capture.fromJson(Map<String, dynamic> json) {
    final firstAsset = (json['assets'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .firstOrNull;
    final resolvedImageUrl = json['image_url'] as String? ??
        json['thumbnail_url'] as String? ??
        json['asset_url'] as String? ??
        firstAsset?['signed_url'] as String? ??
        firstAsset?['url'] as String?;

    return Capture(
      id: json['id'] as String,
      type: captureTypeFromString(json['type'] as String),
      content: json['content'] as String?,
      url: json['url'] as String?,
      linkTitle: json['link_title'] as String?,
      linkDescription: json['link_description'] as String?,
      linkImageUrl: json['link_image_url'] as String?,
      imageUrl: resolvedImageUrl,
      isShared: json['is_shared'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((tag) => Tag.fromJson(tag as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
