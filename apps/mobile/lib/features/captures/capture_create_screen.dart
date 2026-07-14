import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/main_shell.dart';

class CaptureCreateScreen extends StatefulWidget {
  const CaptureCreateScreen({this.initialType = 'text', super.key});

  final String initialType;

  @override
  State<CaptureCreateScreen> createState() => _CaptureCreateScreenState();
}

class _CaptureCreateScreenState extends State<CaptureCreateScreen> {
  late String type;
  final titleController = TextEditingController();
  final memoController = TextEditingController();
  final linkController = TextEditingController();
  final tagController = TextEditingController();
  final tags = <String>['초안', '읽을거리'];
  bool isShared = false;

  @override
  void initState() {
    super.initState();
    type = switch (widget.initialType) {
      'photo' => 'photo',
      'video' => 'video',
      'link' => 'link',
      _ => 'text',
    };
  }

  @override
  void dispose() {
    titleController.dispose();
    memoController.dispose();
    linkController.dispose();
    tagController.dispose();
    super.dispose();
  }

  void addTag() {
    final value = tagController.text.trim();
    if (value.isEmpty || tags.contains(value)) return;
    setState(() {
      tags.add(value);
      tagController.clear();
    });
  }

  void saveCapture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('글감이 임시로 저장되었습니다. API 연결 후 서버에 저장됩니다.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글감 수집'),
        actions: const [ProfileAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            '지금 붙잡은 것을\n짧게 남겨두세요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'text',
                  icon: Icon(Icons.short_text),
                  label: Text('글')),
              ButtonSegment(
                  value: 'photo',
                  icon: Icon(Icons.photo_camera_outlined),
                  label: Text('사진')),
              ButtonSegment(
                  value: 'video',
                  icon: Icon(Icons.videocam_outlined),
                  label: Text('동영상')),
              ButtonSegment(
                  value: 'link', icon: Icon(Icons.link), label: Text('링크')),
            ],
            selected: {type},
            onSelectionChanged: (value) => setState(() => type = value.first),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '제목',
              hintText: '나중에 다시 찾기 쉬운 이름',
            ),
          ),
          const SizedBox(height: 12),
          if (type == 'link')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: linkController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: '링크',
                  hintText: 'https://',
                ),
              ),
            ),
          if (type == 'photo')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('사진 선택은 권한 연결 후 활성화됩니다.')),
                  );
                },
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('사진 선택'),
              ),
            ),
          if (type == 'video')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('동영상 선택은 권한 연결 후 활성화됩니다.')),
                  );
                },
                icon: const Icon(Icons.video_library_outlined),
                label: const Text('동영상 선택'),
              ),
            ),
          TextField(
            controller: memoController,
            minLines: 7,
            maxLines: 14,
            decoration: const InputDecoration(
              labelText: '메모',
              hintText: '떠오른 문장, 장면, 감정을 그대로 적어보세요.',
            ),
          ),
          const SizedBox(height: 16),
          Text('태그', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                InputChip(
                  label: Text('#$tag'),
                  backgroundColor: AppTheme.mist,
                  onDeleted: () => setState(() => tags.remove(tag)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tagController,
                  decoration: const InputDecoration(hintText: '새 태그'),
                  onSubmitted: (_) => addTag(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: '태그 추가',
                onPressed: addTag,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.explore_outlined),
              title: const Text('글감 서핑에 공유'),
              subtitle: const Text('다른 사용자가 검색하고 자신의 글감함에 담을 수 있어요.'),
              value: isShared,
              activeThumbColor: AppTheme.moss,
              onChanged: (value) => setState(() => isShared = value),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: saveCapture,
            icon: const Icon(Icons.check),
            label: const Text('글감 저장'),
          ),
        ],
      ),
    );
  }
}
