import 'package:flutter/material.dart';

import '../../features/captures/captures_screen.dart';
import '../../shared/main_shell.dart';

class ManuscriptEditScreen extends StatefulWidget {
  const ManuscriptEditScreen({
    required this.projectId,
    required this.manuscriptId,
    super.key,
  });

  final String projectId;
  final String manuscriptId;

  @override
  State<ManuscriptEditScreen> createState() => _ManuscriptEditScreenState();
}

class _ManuscriptEditScreenState extends State<ManuscriptEditScreen> {
  late final TextEditingController titleController;
  late final TextEditingController bodyController;

  @override
  void initState() {
    super.initState();
    final isNew = widget.manuscriptId == 'new';
    titleController = TextEditingController(text: isNew ? '' : '프롤로그');
    bodyController = TextEditingController(
      text: isNew ? '' : '모바일에서 원고를 이어 쓰는 화면입니다.',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<void> deleteManuscript() async {
    final confirmed = await showConfirmDialog(
      context,
      title: '원고를 삭제할까요?',
      message: '삭제한 원고는 복구할 수 없습니다.',
    );
    if (confirmed && mounted) Navigator.of(context).pop();
  }

  void saveManuscript() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('원고 저장 API 연결이 필요합니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.manuscriptId == 'new';

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? '새 원고' : '원고 수정'),
        actions: const [ProfileAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: '원고 제목'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bodyController,
            minLines: 14,
            maxLines: 24,
            decoration: const InputDecoration(labelText: '본문'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: saveManuscript,
            icon: const Icon(Icons.check),
            label: const Text('저장'),
          ),
          if (!isNew)
            TextButton.icon(
              onPressed: deleteManuscript,
              icon: const Icon(Icons.delete_outline),
              label: const Text('원고 삭제'),
            ),
        ],
      ),
    );
  }
}
