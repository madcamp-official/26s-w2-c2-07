import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/main_shell.dart';

class SurfScreen extends StatefulWidget {
  const SurfScreen({super.key});

  @override
  State<SurfScreen> createState() => _SurfScreenState();
}

class _SurfScreenState extends State<SurfScreen> {
  String query = '';

  final captures = <_SurfCapture>[
    _SurfCapture('사진', '창가에 놓인 노트와 빛이 좋은 오후', '문장 수집가', 18),
    _SurfCapture('링크', '작게 쓰고 오래 남기는 법', '느린 작가', 42),
    _SurfCapture('동영상', '비 오는 거리의 짧은 움직임', '장면 기록자', 7),
  ];

  List<_SurfCapture> get visibleCaptures {
    if (query.trim().isEmpty) return captures;
    return captures
        .where((capture) =>
            capture.title.contains(query) ||
            capture.creator.contains(query) ||
            capture.type.contains(query))
        .toList();
  }

  void openDetail(_SurfCapture capture) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SurfThumbnail(type: capture.type, height: 180),
            const SizedBox(height: 16),
            Text(capture.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${capture.creator} · 저장 ${capture.savedCount}'),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공유 글감 저장 API 연결이 필요합니다.')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('내 글감함에 추가'),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('신고 API 연결이 필요합니다.')),
                );
              },
              icon: const Icon(Icons.flag_outlined),
              label: const Text('신고'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글감 서핑'),
        actions: const [ProfileAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text(
            '다른 작가의 글감을\n천천히 둘러보세요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: '공유 글감 검색',
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleCaptures.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final capture = visibleCaptures[index];
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => openDetail(capture),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SurfThumbnail(type: capture.type, height: 78),
                        const SizedBox(height: 10),
                        Text(
                          capture.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${capture.creator} · 저장 ${capture.savedCount}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SurfThumbnail extends StatelessWidget {
  const _SurfThumbnail({required this.type, required this.height});

  final String type;
  final double height;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      '사진' => Icons.image_outlined,
      '동영상' => Icons.play_circle_outline,
      '링크' => Icons.link,
      _ => Icons.short_text,
    };

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.mist,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppTheme.moss),
    );
  }
}

class _SurfCapture {
  _SurfCapture(this.type, this.title, this.creator, this.savedCount);

  final String type;
  final String title;
  final String creator;
  final int savedCount;
}
