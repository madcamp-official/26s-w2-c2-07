import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
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
  final linkedCaptures = <_ManuscriptCapture>[
    _ManuscriptCapture('c1', '조각글', '따뜻한 문장은 오래 머문다.', '문장'),
    _ManuscriptCapture('c2', '사진', '창가에 놓인 노트와 커피', '사진'),
  ];

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

  void openCaptureConnector() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CaptureConnectorSheet(
        linkedCaptures: linkedCaptures,
        onAdd: (capture) {
          if (linkedCaptures.any((item) => item.id == capture.id)) return;
          setState(() => linkedCaptures.add(capture));
        },
      ),
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
          OutlinedButton.icon(
            onPressed: openCaptureConnector,
            icon: const Icon(Icons.collections_bookmark_outlined),
            label: const Text('글감 연결'),
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

class _CaptureConnectorSheet extends StatefulWidget {
  const _CaptureConnectorSheet({
    required this.linkedCaptures,
    required this.onAdd,
  });

  final List<_ManuscriptCapture> linkedCaptures;
  final ValueChanged<_ManuscriptCapture> onAdd;

  @override
  State<_CaptureConnectorSheet> createState() => _CaptureConnectorSheetState();
}

class _CaptureConnectorSheetState extends State<_CaptureConnectorSheet> {
  bool isLinkedExpanded = true;
  String query = '';

  final allCaptures = <_ManuscriptCapture>[
    _ManuscriptCapture('c1', '조각글', '따뜻한 문장은 오래 머문다.', '문장'),
    _ManuscriptCapture('c2', '사진', '창가에 놓인 노트와 커피', '사진'),
    _ManuscriptCapture('c3', '링크', '퇴근길에 읽은 에세이', '읽을거리'),
    _ManuscriptCapture('c4', '사진', '책상 위 오래된 메모', '사진'),
  ];

  List<_ManuscriptCapture> get filteredCaptures {
    final text = query.trim();
    if (text.isEmpty) return allCaptures;
    return allCaptures
        .where((capture) =>
            capture.title.contains(text) ||
            capture.type.contains(text) ||
            capture.tag.contains(text))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 24),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('글감 연결', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '제목, 태그, 형태 검색',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => setState(() => isLinkedExpanded = !isLinkedExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    AnimatedRotation(
                      turns: isLinkedExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.chevron_right),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '프로젝트에 연결된 글감',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text('${widget.linkedCaptures.length}개'),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  for (final capture in widget.linkedCaptures)
                    _ConnectorCaptureTile(
                      capture: capture,
                      isLinked: true,
                      onAdd: null,
                    ),
                ],
              ),
              crossFadeState: isLinkedExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 180),
            ),
            const SizedBox(height: 8),
            Text('모든 글감', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  for (final capture in filteredCaptures)
                    _ConnectorCaptureTile(
                      capture: capture,
                      isLinked: widget.linkedCaptures
                          .any((item) => item.id == capture.id),
                      onAdd: () {
                        widget.onAdd(capture);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${capture.title} 글감을 연결했습니다.')),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectorCaptureTile extends StatelessWidget {
  const _ConnectorCaptureTile({
    required this.capture,
    required this.isLinked,
    required this.onAdd,
  });

  final _ManuscriptCapture capture;
  final bool isLinked;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.mist,
          foregroundColor: AppTheme.moss,
          child: Icon(capture.icon),
        ),
        title: Text(capture.title),
        subtitle: Text('#${capture.tag} · ${capture.type}'),
        trailing: isLinked
            ? const Icon(Icons.check_circle, color: AppTheme.moss)
            : IconButton(
                tooltip: '원고에 연결',
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline),
              ),
      ),
    );
  }
}

class _ManuscriptCapture {
  _ManuscriptCapture(this.id, this.type, this.title, this.tag);

  final String id;
  final String type;
  final String title;
  final String tag;

  IconData get icon {
    return switch (type) {
      '사진' => Icons.photo_camera_outlined,
      '링크' => Icons.link,
      _ => Icons.short_text,
    };
  }
}
