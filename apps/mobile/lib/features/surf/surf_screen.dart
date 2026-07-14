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
    _SurfCapture('링크', '짧게 읽고 오래 남기는 법', '느린 기록자', 42),
    _SurfCapture('동영상', '비 오는 거리의 지나가는 움직임', '이면 기록실', 7),
  ];

  List<_SurfCapture> get visibleCaptures {
    if (query.trim().isEmpty) return captures;
    return captures
        .where(
          (capture) =>
              capture.title.contains(query) ||
              capture.creator.contains(query) ||
              capture.type.contains(query),
        )
        .toList();
  }

  Future<void> reportCapture(
    BuildContext sheetContext,
    _SurfCapture capture,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 글감을 신고할까요?'),
        content: Text(
          '"${capture.title}" 글감이 부적절하다고 판단되면 신고할 수 있어요. '
          '여러 신고가 누적되면 노출이 제한됩니다.',
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('신고'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted || !sheetContext.mounted) return;
    Navigator.of(sheetContext).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('신고 API 연결이 필요합니다.')),
    );
  }

  void openDetail(_SurfCapture capture) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppTheme.paper,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.76,
        minChildSize: 0.42,
        maxChildSize: 0.92,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            Text('공유 글감', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            _SurfThumbnail(type: capture.type, height: 220),
            const SizedBox(height: 16),
            Text(capture.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${capture.creator} · 저장 ${capture.savedCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Text(
              '마음에 오래 남는 장면과 문장을 발견했다면 내 글감함에 저장해두세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('공유 글감 저장 API 연결이 필요합니다.')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('내 글감함에 추가'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => reportCapture(sheetContext, capture),
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
            '다른 작가의 조각을\n천천히 넘겨보세요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '좋은 문장과 장면을 발견하면 내 글감함에 살짝 꽂아둘 수 있어요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.muted,
                ),
          ),
          const SizedBox(height: 18),
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
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final capture = visibleCaptures[index];
              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => openDetail(capture),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SurfThumbnail(type: capture.type, height: 80),
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
                          style: Theme.of(context).textTheme.bodySmall,
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Icon(icon, color: AppTheme.coffee),
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
