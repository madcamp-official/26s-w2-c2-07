import 'capture.dart';

class SharedCapture extends Capture {
  const SharedCapture({
    required super.id,
    required super.type,
    super.content,
    super.url,
    super.linkTitle,
    super.linkDescription,
    super.linkImageUrl,
    super.imageUrl,
    super.isShared,
    super.tags,
    required super.createdAt,
    required super.updatedAt,
    required this.creator,
    required this.savedCount,
    required this.reportCount,
    required this.visibility,
  });

  final SharedCaptureCreator creator;
  final int savedCount;
  final int reportCount;
  final String visibility;

  factory SharedCapture.fromJson(Map<String, dynamic> json) {
    final capture = Capture.fromJson(json);

    return SharedCapture(
      id: capture.id,
      type: capture.type,
      content: capture.content,
      url: capture.url,
      linkTitle: capture.linkTitle,
      linkDescription: capture.linkDescription,
      linkImageUrl: capture.linkImageUrl,
      imageUrl: capture.imageUrl,
      isShared: capture.isShared,
      tags: capture.tags,
      createdAt: capture.createdAt,
      updatedAt: capture.updatedAt,
      creator: SharedCaptureCreator.fromJson(
        json['creator'] as Map<String, dynamic>? ?? const {},
      ),
      savedCount: json['saved_count'] as int? ?? 0,
      reportCount: json['report_count'] as int? ?? 0,
      visibility: json['visibility'] as String? ?? 'visible',
    );
  }
}

class SharedCaptureCreator {
  const SharedCaptureCreator({
    required this.id,
    this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String? displayName;
  final String? avatarUrl;

  String get name => displayName?.trim().isNotEmpty == true ? displayName! : '익명';

  factory SharedCaptureCreator.fromJson(Map<String, dynamic> json) {
    return SharedCaptureCreator(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
