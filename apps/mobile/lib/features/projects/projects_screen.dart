import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/main_shell.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = [
      _ProjectItem(
        'p1',
        '작은 기록의 습관',
        '진행중',
        ['m1:프롤로그', 'm2:퇴근길 메모', 'm3:정리되지 않은 문장들'],
      ),
      _ProjectItem(
        'p2',
        '여름 캠프 회고',
        '완료',
        ['m4:첫날의 온도', 'm5:팀으로 일한다는 것'],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트'),
        actions: const [ProfileAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text(
            '모아둔 글감을\n원고로 이어 쓰세요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => context.push('/projects/new'),
            icon: const Icon(Icons.create_new_folder_outlined),
            label: const Text('새 프로젝트'),
          ),
          const SizedBox(height: 18),
          for (final project in projects)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ProjectCard(project: project),
            ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final _ProjectItem project;

  @override
  Widget build(BuildContext context) {
    final isDone = project.status == '완료';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push('/projects/${project.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Chip(
                    label: Text(project.status),
                    backgroundColor: isDone ? AppTheme.mist : AppTheme.paper,
                    side: BorderSide(
                        color: isDone ? AppTheme.sage : AppTheme.clay),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('원고 ${project.manuscripts.length}개'),
              const SizedBox(height: 12),
              for (final manuscript in project.manuscripts)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.article_outlined),
                  title: Text(manuscript.split(':').last),
                  trailing: IconButton(
                    tooltip: '원고 작성',
                    onPressed: () => context.push(
                      '/projects/${project.id}/manuscripts/${manuscript.split(':').first}',
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: isDone
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('원고 생성 API 연결이 필요합니다.')),
                        );
                      },
                icon: const Icon(Icons.note_add_outlined),
                label: const Text('원고 추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectItem {
  _ProjectItem(this.id, this.title, this.status, this.manuscripts);

  final String id;
  final String title;
  final String status;
  final List<String> manuscripts;
}
