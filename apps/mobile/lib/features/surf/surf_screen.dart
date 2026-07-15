import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/capture_type_ui.dart';
import '../../data/models/capture.dart';
import '../../data/models/shared_capture.dart';
import '../../data/repositories/shared_captures_repository.dart';
import '../../shared/async_state.dart';
import '../../shared/main_shell.dart';

class SurfScreen extends StatefulWidget {
  const SurfScreen({super.key});

  @override
  State<SurfScreen> createState() => _SurfScreenState();
}

class _SurfScreenState extends State<SurfScreen> {
  final _repository = SharedCapturesRepository();
  final _searchController = TextEditingController();

  Timer? _debounce;
  bool _loading = true;
  Object? _error;
  List<SharedCapture> _captures = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final captures = await _repository.list(query: _searchController.text);
      if (!mounted) return;
      setState(() {
        _captures = captures;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _captures = [];
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  Future<void> _saveCapture(SharedCapture capture) async {
    try {
      await _repository.save(capture.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내 글감함에 추가했어요.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('글감 저장에 실패했어요. $error')),
      );
    }
  }

  Future<void> _reportCapture(SharedCapture capture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이 글감을 신고할까요?'),
        content: Text(
          '"${capture.displayTitle}" 글감이 부적절하다고 판단되면 신고할 수 있어요. '
          '여러 신고가 누적되면 노출이 제한됩니다.',
        ),
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

    if (confirmed != true) return;

    try {
      await _repository.report(capture.id, reason: 'inappropriate');
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고를 접수했어요.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('신고에 실패했어요. $error')),
      );
    }
  }

  void _openDetail(SharedCapture capture) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppTheme.paper,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.52,
        maxChildSize: 0.94,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            Text('공유 글감', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            _CapturePreview(capture: capture, height: 220),
            const SizedBox(height: 16),
            Text(
              capture.displayTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '공유한 사람: ${capture.creator.name} · 저장 ${capture.savedCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (capture.content?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                capture.content!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (capture.url?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 12),
              SelectableText(
                capture.url!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.moss,
                    ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _saveCapture(capture),
              icon: const Icon(Icons.add),
              label: const Text('내 글감함에 추가'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _reportCapture(capture),
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
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Text(
              '다른 작가의 조각을\n천천히 서핑해보세요.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '공유된 문장과 장면을 검색하고, 마음에 드는 글감을 내 글감함에 담을 수 있어요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.muted,
                  ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '공유 글감 검색',
              ),
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              BackendErrorState(
                title: '공유 글감을 불러오지 못했어요',
                message: '백엔드의 /shared-captures API와 모바일 .env의 API 주소를 확인해 주세요.',
                error: _error,
                onRetry: _load,
              )
            else if (_captures.isEmpty)
              const EmptyState(
                icon: Icons.explore_outlined,
                title: '검색 결과가 없어요',
                message: '다른 검색어를 입력하거나 공유된 글감이 생긴 뒤 다시 확인해 주세요.',
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _captures.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final capture = _captures[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => _openDetail(capture),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CapturePreview(capture: capture, height: 84),
                            const SizedBox(height: 10),
                            Text(
                              capture.displayTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              '${capture.creator.name} · 저장 ${capture.savedCount}',
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
      ),
    );
  }
}

class _CapturePreview extends StatelessWidget {
  const _CapturePreview({required this.capture, required this.height});

  final Capture capture;
  final double height;

  @override
  Widget build(BuildContext context) {
    final imageUrl = capture.type == CaptureType.link
        ? capture.linkImageUrl
        : capture.imageUrl ?? capture.linkImageUrl;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          imageUrl,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _PlaceholderPreview(
            type: capture.type,
            height: height,
          ),
        ),
      );
    }

    return _PlaceholderPreview(type: capture.type, height: height);
  }
}

class _PlaceholderPreview extends StatelessWidget {
  const _PlaceholderPreview({required this.type, required this.height});

  final CaptureType type;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.mist,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.line),
      ),
      child: Icon(captureTypeIcon(type), color: AppTheme.coffee),
    );
  }
}
