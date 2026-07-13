import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/main_shell.dart';

class CapturesScreen extends StatefulWidget {
  const CapturesScreen({super.key});

  @override
  State<CapturesScreen> createState() => _CapturesScreenState();
}

class _CapturesScreenState extends State<CapturesScreen> {
  bool isCardView = false;
  String query = '';
  final tags = <String>['초안', '읽을거리', '문장', '사진'];
  final captures = <_CaptureItem>[
    _CaptureItem(
        'c1', '조각글', '따뜻한 문장은 오래 머문다.', '문장', '오늘 13:04', '문장으로 시작된 글감입니다.'),
    _CaptureItem('c2', '사진', '창가에 놓인 노트와 커피', '사진', '어제', '차분한 분위기의 사진 글감입니다.'),
    _CaptureItem(
        'c3', '링크', '퇴근길에 읽은 에세이', '읽을거리', '7월 12일', '나중에 프로젝트에 연결할 링크 글감입니다.'),
  ];

  List<_CaptureItem> get filteredCaptures {
    final text = query.trim();
    if (text.isEmpty) return captures;
    return captures
        .where((capture) =>
            capture.title.contains(text) ||
            capture.type.contains(text) ||
            capture.tag.contains(text))
        .toList();
  }

  void addTag() {
    final controller = TextEditingController();
    showDialog<void>(
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
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty && !tags.contains(value)) {
                setState(() => tags.add(value));
              }
              Navigator.of(context).pop();
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteCapture(_CaptureItem capture) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '글감을 삭제할까요?',
      message: '${capture.title} 글감은 목록에서 사라집니다.',
    );
    if (!confirmed || !mounted) return;
    setState(() => captures.remove(capture));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${capture.title} 글감을 삭제했습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredCaptures;

    return Scaffold(
      appBar: AppBar(
        title: const Text('글감함'),
        actions: const [ProfileAction()],
      ),
      body: ListView(
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
                InputChip(
                  label: Text('#$tag'),
                  backgroundColor: AppTheme.mist,
                  onDeleted: () => setState(() => tags.remove(tag)),
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
            onPressed: () => context.push('/capture'),
            icon: const Icon(Icons.add),
            label: const Text('글감 추가'),
          ),
          const SizedBox(height: 18),
          if (items.isEmpty)
            const _EmptyCaptures()
          else if (isCardView)
            _CaptureCardGrid(items: items, onDelete: deleteCapture)
          else
            _CaptureList(items: items, onDelete: deleteCapture),
        ],
      ),
    );
  }
}

class _CaptureList extends StatelessWidget {
  const _CaptureList({required this.items, required this.onDelete});

  final List<_CaptureItem> items;
  final ValueChanged<_CaptureItem> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: ListTile(
                onTap: () => context.push('/captures/${item.id}'),
                leading: _CaptureBadge(type: item.type),
                title: Text(item.title),
                subtitle: Text('#${item.tag} · ${item.date}'),
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
  const _CaptureCardGrid({required this.items, required this.onDelete});

  final List<_CaptureItem> items;
  final ValueChanged<_CaptureItem> onDelete;

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
          onTap: () => context.push('/captures/${item.id}'),
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
                  _CaptureThumbnail(type: item.type),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '#${item.tag} · ${item.date}',
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
  const _CaptureThumbnail({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    if (type == '조각글') return const SizedBox.shrink();

    final icon = type == '사진' ? Icons.image_outlined : Icons.link;
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.mist,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppTheme.moss),
    );
  }
}

class _CaptureBadge extends StatelessWidget {
  const _CaptureBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      '사진' => Icons.photo_camera_outlined,
      '링크' => Icons.link,
      _ => Icons.short_text,
    };

    return CircleAvatar(
      backgroundColor: AppTheme.mist,
      foregroundColor: AppTheme.moss,
      child: Icon(icon),
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

class _CaptureItem {
  _CaptureItem(
    this.id,
    this.type,
    this.title,
    this.tag,
    this.date,
    this.description,
  );

  final String id;
  final String type;
  final String title;
  final String tag;
  final String date;
  final String description;
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
