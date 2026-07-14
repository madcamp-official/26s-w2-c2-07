import 'package:flutter/material.dart';

import '../../data/models/capture.dart';

String captureTypeLabel(CaptureType type) {
  return switch (type) {
    CaptureType.text => '조각글',
    CaptureType.photo => '사진',
    CaptureType.video => '동영상',
    CaptureType.link => '링크',
  };
}

IconData captureTypeIcon(CaptureType type) {
  return switch (type) {
    CaptureType.text => Icons.short_text,
    CaptureType.photo => Icons.photo_camera_outlined,
    CaptureType.video => Icons.videocam_outlined,
    CaptureType.link => Icons.link,
  };
}
