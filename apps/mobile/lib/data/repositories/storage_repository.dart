import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'captures_repository.dart';

const String captureAssetsBucket = 'capture-assets';

/// Uploads a capture's photo/video asset: asks the backend for a signed
/// upload URL, pushes the bytes straight to Supabase Storage, then tells
/// the backend the upload finished so it can record the asset.
class StorageRepository {
  StorageRepository({CapturesRepository? capturesRepository})
      : _capturesRepository = capturesRepository ?? CapturesRepository();

  final CapturesRepository _capturesRepository;

  Future<void> uploadCaptureAsset({
    required String captureId,
    required String fileName,
    required String contentType,
    required Uint8List bytes,
  }) async {
    final upload = await _capturesRepository.createUploadUrl(
      captureId,
      fileName: fileName,
      contentType: contentType,
    );
    final storagePath = upload['storagePath'] as String;
    final token = upload['token'] as String;

    await Supabase.instance.client.storage.from(captureAssetsBucket).uploadBinaryToSignedUrl(
          storagePath,
          token,
          bytes,
          FileOptions(contentType: contentType),
        );

    await _capturesRepository.completeUpload(captureId, storagePath);
  }
}
