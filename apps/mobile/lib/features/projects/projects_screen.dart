import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/document.dart';
import '../../data/models/project.dart';
import '../../data/repositories/documents_repository.dart';
import '../../data/repositories/projects_repository.dart';
import '../../shared/main_shell.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _projectsRepository = ProjectsRepository();
  final _documentsRepository = DocumentsRepository();

  bool _loading = true;
  Object? _error;
  List<Project> projects = [];
  Map<String, List<ManuscriptDocument>> documentsByProject = {};

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
      final projectList = await _projectsRepository.list();
      final documentsList = await Future.wait(
        projectList.map((project) => _documentsRepository.list(project.id)),
      );
      setState(() {
        projects = projectList;
        documentsByProject = {
          for (var i = 0; i < projectList.length; i++)
            projectList[i].id: documentsList[i],
        };
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> openNewProject() async {
    final changed = await context.push<bool>('/projects/new');
    if (changed == true) load();
  }

  Future<void> openManuscript(String projectId, String manuscriptId) async {
    final changed = await context
        .push<bool>('/projects/$projectId/manuscripts/$manuscriptId');
    if (changed == true) load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트'),
        actions: const [ProfileAction()],
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Text(
              '모아둔 글감을\n원고로 이어 쓰세요.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: openNewProject,
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('새 프로젝트'),
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
                    Text('프로젝트를 불러오지 못했습니다.\n$_error',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    OutlinedButton(onPressed: load, child: const Text('다시 시도')),
                  ],
                ),
              )
            else if (projects.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text('아직 만든 프로젝트가 없습니다.')),
              )
            else
              for (final project in projects)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ProjectCard(
                    project: project,
                    documents: documentsByProject[project.id] ?? const [],
                    onOpenManuscript: (manuscriptId) =>
                        openManuscript(project.id, manuscriptId),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.documents,
    required this.onOpenManuscript,
  });

  final Project project;
  final List<ManuscriptDocument> documents;
  final ValueChanged<String> onOpenManuscript;

  @override
  Widget build(BuildContext context) {
    final isDone = project.isDone;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
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
                    label: Text(isDone ? '완료' : '진행중'),
                    backgroundColor: isDone ? AppTheme.mist : AppTheme.paper,
                    side: BorderSide(
                        color: isDone ? AppTheme.sage : AppTheme.clay),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('원고 ${documents.length}개'),
              const SizedBox(height: 12),
              for (final manuscript in documents)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.article_outlined),
                  title: Text(manuscript.title),
                  trailing: IconButton(
                    tooltip: isDone ? '완료된 프로젝트는 수정할 수 없어요' : '원고 작성',
                    onPressed:
                        isDone ? null : () => onOpenManuscript(manuscript.id),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: isDone ? null : () => onOpenManuscript('new'),
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
