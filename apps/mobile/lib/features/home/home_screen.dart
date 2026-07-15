import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/capture_type_ui.dart';
import '../../core/utils/date_format.dart';
import '../../data/models/capture.dart';
import '../../data/repositories/captures_repository.dart';
import '../../shared/async_state.dart';
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

  Future<void> _openCapture() async {
    final changed = await context.push<bool>('/capture');
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
              '오늘의 문장과 장면을 모아 글이 시작될 자리를 마련해요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            _QuickCapturePanel(onStart: _openCapture),
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
            const Text('문장, 사진, 영상, 링크를 한 화면에서 골라 기록할 수 있어요.'),
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
              return BackendErrorState(
                title: '백엔드와 연결하지 못했어요',
                message: '최근 글감을 불러오려면 모바일 .env의 API 주소와 서버 실행 상태를 확인해 주세요.',
                error: snapshot.error,
                onRetry: onRetry,
              );
            }

            final captures = snapshot.data ?? const [];
            if (captures.isEmpty) {
              return EmptyState(
                icon: Icons.bookmark_add_outlined,
                title: '아직 남긴 글감이 없어요',
                message: '첫 문장이나 장면을 남기면 여기에 최근 글감이 표시됩니다.',
                action: FilledButton.icon(
                  onPressed: () => context.push('/capture'),
                  icon: const Icon(Icons.add),
                  label: const Text('글감 추가'),
                ),
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
                        title: Text(
                          capture.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          formatRelativeDate(capture.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
