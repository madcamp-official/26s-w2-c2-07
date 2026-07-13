import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/main_shell.dart';
import 'captures_screen.dart';

class CaptureDetailScreen extends StatefulWidget {
  const CaptureDetailScreen({required this.captureId, super.key});

  final String captureId;

  @override
  State<CaptureDetailScreen> createState() => _CaptureDetailScreenState();
}

class _CaptureDetailScreenState extends State<CaptureDetailScreen> {
  late final TextEditingController titleController;
  late final TextEditingController memoController;
  late String type;

  @override
  void initState() {
    super.initState();
    final capture = _captureById(widget.captureId);
    type = capture.type;
    titleController = TextEditingController(text: capture.title);
    memoController = TextEditingController(text: capture.memo);
  }

  @override
  void dispose() {
    titleController.dispose();
    memoController.dispose();
    super.dispose();
  }

  Future<void> deleteCapture() async {
    final confirmed = await showConfirmDialog(
      context,
      title: '글감을 삭제할까요?',
      message: '삭제한 글감은 프로젝트와 원고 연결에서도 제거됩니다.',
    );
    if (!confirmed || !mounted) return;
    Navigator.of(context).pop();
  }

  void saveCapture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('글감 수정 API 연결이 필요합니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글감 상세'),
        actions: const [ProfileAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '조각글', label: Text('글')),
              ButtonSegment(value: '사진', label: Text('사진')),
              ButtonSegment(value: '링크', label: Text('링크')),
            ],
            selected: {type},
            onSelectionChanged: (value) => setState(() => type = value.first),
          ),
          const SizedBox(height: 16),
          if (type != '조각글') _MediaPreview(type: type),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: '제목'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: memoController,
            minLines: 8,
            maxLines: 16,
            decoration: const InputDecoration(labelText: '설명'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: const [
              Chip(label: Text('#문장')),
              Chip(label: Text('#초안')),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: saveCapture,
            icon: const Icon(Icons.check),
            label: const Text('수정 저장'),
          ),
          TextButton.icon(
            onPressed: deleteCapture,
            icon: const Icon(Icons.delete_outline),
            label: const Text('글감 삭제'),
          ),
        ],
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final icon = type == '사진' ? Icons.image_outlined : Icons.link;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: AppTheme.mist,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 48, color: AppTheme.moss),
      ),
    );
  }
}

_CaptureDetailData _captureById(String id) {
  return switch (id) {
    'c2' => _CaptureDetailData('사진', '창가에 놓인 노트와 커피', '차분한 분위기의 사진 글감입니다.'),
    'c3' => _CaptureDetailData('링크', '퇴근길에 읽은 에세이', '나중에 프로젝트에 연결할 링크 글감입니다.'),
    _ => _CaptureDetailData('조각글', '따뜻한 문장은 오래 머문다.', '문장으로 시작된 글감입니다.'),
  };
}

class _CaptureDetailData {
  _CaptureDetailData(this.type, this.title, this.memo);

  final String type;
  final String title;
  final String memo;
}
