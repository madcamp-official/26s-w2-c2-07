import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/capture_type_ui.dart';
import '../../data/models/capture.dart';
import '../../data/models/tag.dart';
import '../../data/repositories/captures_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../shared/main_shell.dart';
import 'captures_screen.dart';

class CaptureDetailScreen extends StatefulWidget {
  const CaptureDetailScreen({required this.captureId, super.key});

  final String captureId;

  @override
  State<CaptureDetailScreen> createState() => _CaptureDetailScreenState();
}

class _CaptureDetailScreenState extends State<CaptureDetailScreen> {
  final _capturesRepository = CapturesRepository();
  final _tagsRepository = TagsRepository();

  late Future<Capture> _future;
  final contentController = TextEditingController();
  final linkController = TextEditingController();
  final tagController = TextEditingController();
  List<String> tagNames = [];
  List<Tag> existingTags = [];
  bool isSaving = false;
  bool isDeleting = false;
  bool isShared = false;
  Capture? capture;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _tagsRepository.list().then((value) {
      if (mounted) setState(() => existingTags = value);
    }).catchError((_) {});
  }

  Future<Capture> _load() async {
    final result = await _capturesRepository.get(widget.captureId);
    contentController.text = result.content ?? '';
    linkController.text = result.url ?? '';
    tagNames = result.tags.map((tag) => tag.name).toList();
    isShared = result.isShared;
    capture = result;
    return result;
  }

  @override
  void dispose() {
    contentController.dispose();
    linkController.dispose();
    tagController.dispose();
    super.dispose();
  }

  void addTag() {
    final value = tagController.text.trim();
    if (value.isEmpty || tagNames.contains(value)) return;
    setState(() {
      tagNames.add(value);
      tagController.clear();
    });
  }

  Future<List<String>> _resolveTagIds() async {
    final ids = <String>[];
    for (final name in tagNames) {
      Tag? existing;
      for (final tag in existingTags) {
        if (tag.name == name) {
          existing = tag;
          break;
        }
      }
      if (existing != null) {
        ids.add(existing.id);
        continue;
      }
      final created = await _tagsRepository.create(name);
      existingTags = [...existingTags, created];
      ids.add(created.id);
    }
    return ids;
  }

  Future<void> deleteCapture() async {
    final confirmed = await showConfirmDialog(
      context,
      title: '글감을 삭제할까요?',
      message: '삭제한 글감은 프로젝트와 원고 연결에서도 제거됩니다.',
    );
    if (!confirmed || !mounted) return;
    setState(() => isDeleting = true);
    try {
      await _capturesRepository.delete(widget.captureId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제하지 못했습니다. $e')),
      );
      setState(() => isDeleting = false);
    }
  }

  Future<void> saveCapture() async {
    setState(() => isSaving = true);
    try {
      final tagIds = await _resolveTagIds();
      final current = capture;
      await _capturesRepository.update(
        widget.captureId,
        content: contentController.text.trim(),
        url: current?.type == CaptureType.link
            ? linkController.text.trim()
            : null,
        tagIds: tagIds,
        isShared: isShared,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('글감을 수정했습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정하지 못했습니다. $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('글감 상세'),
        actions: const [ProfileAction()],
      ),
      body: FutureBuilder<Capture>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('글감을 불러오지 못했습니다.\n${snapshot.error}'),
            );
          }
          final item = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                '잠깐 붙잡아 둔 생각을\n다시 읽기 좋게 다듬어요.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Chip(
                avatar: Icon(captureTypeIcon(item.type), size: 18),
                label: Text(captureTypeLabel(item.type)),
              ),
              const SizedBox(height: 16),
              if (item.type == CaptureType.photo ||
                  item.type == CaptureType.video)
                _MediaPreview(item: item),
              if (item.type == CaptureType.link) _LinkPreview(item: item),
              if (item.type == CaptureType.link)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: linkController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(labelText: '링크'),
                  ),
                ),
              TextField(
                controller: contentController,
                minLines: 8,
                maxLines: 16,
                decoration: InputDecoration(
                  labelText: item.type == CaptureType.link ? '메모' : '내용',
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  title: const Text('글감 서핑에 공유'),
                  subtitle: const Text('켜두면 다른 사람이 서핑 탭에서 이 글감을 발견할 수 있어요.'),
                  value: isShared,
                  activeThumbColor: AppTheme.clay,
                  onChanged: (value) => setState(() => isShared = value),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in tagNames)
                    InputChip(
                      label: Text('#$name'),
                      backgroundColor: AppTheme.mist,
                      onDeleted: () => setState(() => tagNames.remove(name)),
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
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: isSaving ? null : saveCapture,
                icon: isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('수정 저장'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: isDeleting ? null : deleteCapture,
                icon: const Icon(Icons.delete_outline),
                label: const Text('글감 삭제'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MediaPreview extends StatefulWidget {
  const _MediaPreview({required this.item});

  final Capture item;

  @override
  State<_MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<_MediaPreview> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final url = widget.item.imageUrl;
    if (widget.item.type == CaptureType.video && url != null) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 172,
        decoration: BoxDecoration(
          color: AppTheme.mist,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final item = widget.item;
    if (item.type == CaptureType.video) {
      final controller = _controller;
      if (controller == null || !controller.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return GestureDetector(
        onTap: _togglePlayback,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            if (!controller.value.isPlaying)
              const Icon(
                Icons.play_circle_fill,
                size: 56,
                color: Colors.white70,
              ),
          ],
        ),
      );
    }
    return item.imageUrl != null
        ? Image.network(item.imageUrl!, fit: BoxFit.contain)
        : Icon(captureTypeIcon(item.type), size: 48, color: AppTheme.coffee);
  }
}

class _LinkPreview extends StatelessWidget {
  const _LinkPreview({required this.item});

  final Capture item;

  @override
  Widget build(BuildContext context) {
    if (item.linkTitle == null &&
        item.linkDescription == null &&
        item.linkImageUrl == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.linkImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.linkImageUrl!,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              if (item.linkTitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  item.linkTitle!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              if (item.linkDescription != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.linkDescription!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
