import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../features/captures/captures_screen.dart';
import '../../shared/main_shell.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.projectId, super.key});

  final String projectId;

  bool get isCompleted => projectId == 'p2';

  @override
  Widget build(BuildContext context) {
    final title = isCompleted ? '여름 캠프 회고' : '작은 기록의 습관';
    final manuscripts = isCompleted
        ? [('m4', '첫날의 온도'), ('m5', '팀으로 일한다는 것')]
        : [('m1', '프롤로그'), ('m2', '퇴근길 메모'), ('m3', '정리되지 않은 문장들')];

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트 상세'),
        actions: [
          IconButton(
            tooltip: '수정',
            onPressed: () => context.push('/projects/$projectId/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
          const ProfileAction(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Chip(
            label: Text(isCompleted ? '완료' : '진행중'),
            backgroundColor: isCompleted ? AppTheme.mist : AppTheme.paper,
          ),
          const SizedBox(height: 18),
          if (isCompleted) _ExportPanel(projectTitle: title),
          if (isCompleted) const SizedBox(height: 18),
          Text('원고', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          for (final manuscript in manuscripts)
            Card(
              child: ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(manuscript.$2),
                onTap: () => context
                    .push('/projects/$projectId/manuscripts/${manuscript.$1}'),
                trailing: IconButton(
                  tooltip: '삭제',
                  onPressed: () =>
                      _confirmDeleteManuscript(context, manuscript.$2),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: isCompleted
                ? null
                : () => context.push('/projects/$projectId/manuscripts/new'),
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('원고 추가'),
          ),
          TextButton.icon(
            onPressed: () => _confirmDeleteProject(context, title),
            icon: const Icon(Icons.delete_outline),
            label: const Text('프로젝트 삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteProject(BuildContext context, String title) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '프로젝트를 삭제할까요?',
      message: '$title 프로젝트와 원고 연결이 삭제됩니다.',
    );
    if (confirmed && context.mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDeleteManuscript(
      BuildContext context, String title) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '원고를 삭제할까요?',
      message: '$title 원고가 프로젝트에서 삭제됩니다.',
    );
    if (!confirmed || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title 원고를 삭제했습니다.')),
    );
  }
}

class _ExportPanel extends StatelessWidget {
  const _ExportPanel({required this.projectTitle});

  final String projectTitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내보내기', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                for (final format in ['PDF', 'DOCS', 'TXT'])
                  ActionChip(
                    label: Text(format),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '$projectTitle $format 내보내기 API 연결이 필요합니다.')),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
