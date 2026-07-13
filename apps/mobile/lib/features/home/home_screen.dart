import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nook'),
        actions: const [ProfileAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text(
            '스치는 생각을\n가장 빠르게 붙잡아두세요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            '모바일 Nook의 첫 화면은 글감 수집에 집중합니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          _QuickCapturePanel(onStart: () => context.push('/capture')),
          const SizedBox(height: 24),
          const _CaptureShortcuts(),
          const SizedBox(height: 28),
          const _RecentCaptures(),
        ],
      ),
    );
  }
}

class _QuickCapturePanel extends StatelessWidget {
  const _QuickCapturePanel({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.edit_note, color: AppTheme.moss, size: 34),
            const SizedBox(height: 14),
            Text('바로 남기기', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('문장, 사진, 링크를 열어둔 채로 잊기 전에 기록하세요.'),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.add),
              label: const Text('새 글감 수집'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaptureShortcuts extends StatelessWidget {
  const _CaptureShortcuts();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.short_text, '조각글', '떠오른 문장부터', 'text'),
      (Icons.photo_camera_outlined, '사진', '장면을 함께', 'photo'),
      (Icons.link, '링크', '읽을 거리 저장', 'link'),
    ];

    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: item == items.last ? 0 : 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => context.push('/capture?type=${item.$4}'),
                child: Ink(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.paper,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.$1, color: AppTheme.clay),
                      const SizedBox(height: 12),
                      Text(item.$2,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(item.$3,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentCaptures extends StatelessWidget {
  const _RecentCaptures();

  @override
  Widget build(BuildContext context) {
    final captures = [
      ('c3', '링크', '퇴근길에 읽은 에세이', '오늘 18:20'),
      ('c1', '조각글', '따뜻한 문장은 오래 머문다.', '오늘 13:04'),
      ('c2', '사진', '창가에 놓인 노트와 커피', '어제'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('최근 글감', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        for (final capture in captures)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                onTap: () => context.push('/captures/${capture.$1}'),
                leading: CircleAvatar(
                  backgroundColor: AppTheme.mist,
                  foregroundColor: AppTheme.moss,
                  child: Text(capture.$2.characters.first),
                ),
                title: Text(capture.$3),
                subtitle: Text(capture.$4),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
      ],
    );
  }
}
