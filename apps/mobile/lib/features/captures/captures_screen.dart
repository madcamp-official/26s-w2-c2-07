import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/capture_type_ui.dart';
import '../../core/utils/date_format.dart';
import '../../data/models/capture.dart';
import '../../data/models/tag.dart';
import '../../data/repositories/captures_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../shared/main_shell.dart';

class CapturesScreen extends StatefulWidget {
  const CapturesScreen({super.key});

  @override
  State<CapturesScreen> createState() => _CapturesScreenState();
}

class _CapturesScreenState extends State<CapturesScreen> {
  final _capturesRepository = CapturesRepository();
  final _tagsRepository = TagsRepository();

  bool isCardView = false;
  String query = '';
  String? selectedTag;

  bool _loading = true;
  Object? _error;
  List<Capture> captures = [];
  List<Tag> tags = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _capturesRepository.list(),
        _tagsRepository.list(),
      ]);
      setState(() {
        captures = results[0] as List<Capture>;
        tags = results[1] as List<Tag>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  List<Capture> get filteredCaptures {
    final text = query.trim();
    return captures.where((capture) {
      final matchesQuery = text.isEmpty ||
          capture.displayTitle.contains(text) ||
          captureTypeLabel(capture.type).contains(text) ||
          capture.tags.any((tag) => tag.name.contains(text));
      final matchesTag =
          selectedTag == null || capture.tags.any((tag) => tag.name == selectedTag);
      return matchesQuery && matchesTag;
    }).toList();
  }

  Future<void> addTag() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('태그 추가'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '새 태그 이름'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('추가'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    if (tags.any((tag) => tag.name == name)) return;
    try {
      final tag = await _tagsRepository.create(name);
      if (!mounted) return;
      setState(() => tags = [...tags, tag]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('태그를 추가하지 못했습니다: $e')));
    }
  }

  Future<void> deleteCapture(Capture capture) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '글감을 삭제할까요?',
      message: '${capture.displayTitle} 글감은 목록에서 사라집니다.',
    );
    if (!confirmed || !mounted) return;
    try {
      await _capturesRepository.delete(capture.id);
      if (!mounted) return;
      setState(() => captures = captures.where((c) => c.id != capture.id).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${capture.displayTitle} 글감을 삭제했습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('삭제하지 못했습니다: $e')));
    }
  }

  Future<void> openCreate() async {
    final changed = await context.push<bool>('/capture');
    if (changed == true) load();
  }

  Future<void> openDetail(Capture capture) async {
    final changed = await context.push<bool>('/captures/${capture.id}');
    if (changed == true) load();
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredCaptures;

    return Scaffold(
      appBar: AppBar(
        title: const Text('글감함'),
        actions: const [ProfileAction()],
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: '제목, 태그, 형태 검색',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _ViewModeSwitch(
                  isCardView: isCardView,
                  onChanged: (value) => setState(() => isCardView = value),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in tags)
                  FilterChip(
                    label: Text('#${tag.name}'),
                    selected: selectedTag == tag.name,
                    backgroundColor: AppTheme.mist,
                    onSelected: (selected) =>
                        setState(() => selectedTag = selected ? tag.name : null),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('태그'),
                  onPressed: addTag,
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: openCreate,
              icon: const Icon(Icons.add),
              label: const Text('글감 추가'),
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Text('글감을 불러오지 못했습니다.\n$_error', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: load, child: const Text('다시 시도')),
                  ],
                ),
              )
            else if (items.isEmpty)
              const _EmptyCaptures()
            else if (isCardView)
              _CaptureCardGrid(items: items, onDelete: deleteCapture, onOpen: openDetail)
            else
              _CaptureList(items: items, onDelete: deleteCapture, onOpen: openDetail),
          ],
        ),
      ),
    );
  }
}

class _CaptureList extends StatelessWidget {
  const _CaptureList({required this.items, required this.onDelete, required this.onOpen});

  final List<Capture> items;
  final ValueChanged<Capture> onDelete;
  final ValueChanged<Capture> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                onTap: () => onOpen(item),
                leading: _CaptureBadge(type: item.type),
                title: Text(item.displayTitle),
                subtitle: Text(
                  '${item.tags.isNotEmpty ? '#${item.tags.first.name} · ' : ''}${formatRelativeDate(item.createdAt)}',
                ),
                trailing: IconButton(
                  tooltip: '삭제',
                  onPressed: () => onDelete(item),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CaptureCardGrid extends StatelessWidget {
  const _CaptureCardGrid({required this.items, required this.onDelete, required this.onOpen});

  final List<Capture> items;
  final ValueChanged<Capture> onDelete;
  final ValueChanged<Capture> onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onOpen(item),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CaptureBadge(type: item.type),
                      const Spacer(),
                      IconButton(
                        tooltip: '삭제',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onDelete(item),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _CaptureThumbnail(item: item),
                  const SizedBox(height: 8),
                  Text(
                    item.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.content ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.tags.isNotEmpty ? '#${item.tags.first.name} · ' : ''}${formatRelativeDate(item.createdAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ViewModeSwitch extends StatelessWidget {
  const _ViewModeSwitch({required this.isCardView, required this.onChanged});

  final bool isCardView;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment:
                isCardView ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.mist,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: IconButton(
                  tooltip: '리스트 보기',
                  onPressed: () => onChanged(false),
                  icon: const Icon(Icons.view_list),
                ),
              ),
              Expanded(
                child: IconButton(
                  tooltip: '카드 보기',
                  onPressed: () => onChanged(true),
                  icon: const Icon(Icons.grid_view),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CaptureThumbnail extends StatelessWidget {
  const _CaptureThumbnail({required this.item});

  final Capture item;

  @override
  Widget build(BuildContext context) {
    if (item.type == CaptureType.text) return const SizedBox.shrink();

    final imageUrl = item.imageUrl ?? item.linkImageUrl;
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          height: 52,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(item.type),
        ),
      );
    }
    return _placeholder(item.type);
  }

  Widget _placeholder(CaptureType type) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.mist,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(captureTypeIcon(type), color: AppTheme.moss),
    );
  }
}

class _CaptureBadge extends StatelessWidget {
  const _CaptureBadge({required this.type});

  final CaptureType type;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppTheme.mist,
      foregroundColor: AppTheme.moss,
      child: Icon(captureTypeIcon(type)),
    );
  }
}

class _EmptyCaptures extends StatelessWidget {
  const _EmptyCaptures();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Text('검색 결과가 없습니다.')),
    );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('확인'),
                ),
              ],
            ),
          ],
        ),
      ) ??
      false;
}
