import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/capture_type_ui.dart';
import '../../core/utils/date_format.dart';
import '../../data/models/capture.dart';
import '../../data/repositories/captures_repository.dart';
import '../../shared/main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _capturesRepository = CapturesRepository();
  late Future<List<Capture>> _recentCaptures;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _recentCaptures = _capturesRepository.list();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _recentCaptures;
  }

  Future<void> _openCapture(String type) async {
    final changed = await context.push<bool>('/capture?type=$type');
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nook'),
        actions: const [ProfileAction()],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Text(
              '스치는 생각을\n가장 빠르게 붙잡아두세요.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              '당신의 글감을 모아보세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _QuickCapturePanel(onStart: () => _openCapture('text')),
            const SizedBox(height: 24),
            _CaptureShortcuts(onSelect: _openCapture),
            const SizedBox(height: 28),
            _RecentCaptures(future: _recentCaptures, onRetry: _refresh),
          ],
        ),
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
            const Text('문장, 사진, 영상, 링크를 열어둔 채로 잊기 전에 기록하세요.'),
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
  const _CaptureShortcuts({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.short_text, '조각글', '떠오른 문장부터', 'text'),
      (Icons.photo_camera_outlined, '사진', '장면을 함께', 'photo'),
      (Icons.videocam_outlined, '동영상', '순간을 생생히', 'video'),
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
                onTap: () => onSelect(item.$4),
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
  const _RecentCaptures({required this.future, required this.onRetry});

  final Future<List<Capture>> future;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('최근 글감', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        FutureBuilder<List<Capture>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text('글감을 불러오지 못했습니다.\n${snapshot.error}',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
                  ],
                ),
              );
            }
            final captures = snapshot.data ?? const [];
            if (captures.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('아직 남긴 글감이 없습니다.')),
              );
            }
            final recent = captures.take(3).toList();
            return Column(
              children: [
                for (final capture in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        onTap: () async {
                          final changed =
                              await context.push<bool>('/captures/${capture.id}');
                          if (changed == true) onRetry();
                        },
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.mist,
                          foregroundColor: AppTheme.moss,
                          child: Icon(captureTypeIcon(capture.type)),
                        ),
                        title: Text(capture.displayTitle),
                        subtitle: Text(formatRelativeDate(capture.createdAt)),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
