import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/document.dart';
import '../../data/models/project.dart';
import '../../data/repositories/documents_repository.dart';
import '../../data/repositories/projects_repository.dart';
import '../../features/captures/captures_screen.dart';
import '../../shared/main_shell.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({required this.projectId, super.key});

  final String projectId;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final _projectsRepository = ProjectsRepository();
  final _documentsRepository = DocumentsRepository();

  bool _loading = true;
  Object? _error;
  Project? project;
  List<ManuscriptDocument> documents = [];

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
        _projectsRepository.get(widget.projectId),
        _documentsRepository.list(widget.projectId),
      ]);
      setState(() {
        project = results[0] as Project;
        documents = results[1] as List<ManuscriptDocument>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> openEdit() async {
    final changed =
        await context.push<bool>('/projects/${widget.projectId}/edit');
    if (changed == true) load();
  }

  Future<void> openManuscript(String manuscriptId) async {
    final changed = await context
        .push<bool>('/projects/${widget.projectId}/manuscripts/$manuscriptId');
    if (changed == true) load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로젝트 상세'),
        actions: [
          IconButton(
            tooltip: '수정',
            onPressed: project?.isDone == true ? null : openEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          const ProfileAction(),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('프로젝트를 불러오지 못했습니다.\n$_error', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: load, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    final currentProject = project!;
    final isDone = currentProject.isDone;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                currentProject.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 12),
            Chip(
              label: Text(isDone ? '완료' : '진행중'),
              backgroundColor: isDone ? AppTheme.mist : AppTheme.paper,
            ),
          ],
        ),
        if (currentProject.description != null &&
            currentProject.description!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(currentProject.description!),
        ],
        const SizedBox(height: 18),
        if (isDone)
          _ExportPanel(
            projectId: currentProject.id,
            projectTitle: currentProject.title,
          ),
        if (isDone) const SizedBox(height: 18),
        Text('원고', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        for (final manuscript in documents)
          Card(
            child: ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(manuscript.title),
              subtitle: isDone ? const Text('완료된 프로젝트는 원고 수정이 잠겨 있어요.') : null,
              onTap: isDone ? null : () => openManuscript(manuscript.id),
              trailing: IconButton(
                tooltip: isDone ? '완료된 프로젝트는 삭제할 수 없어요' : '삭제',
                onPressed:
                    isDone ? null : () => _confirmDeleteManuscript(manuscript),
                icon: const Icon(Icons.delete_outline),
              ),
            ),
          ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: isDone ? null : () => openManuscript('new'),
          icon: const Icon(Icons.note_add_outlined),
          label: const Text('원고 추가'),
        ),
        TextButton.icon(
          onPressed: () => _confirmDeleteProject(currentProject),
          icon: const Icon(Icons.delete_outline),
          label: const Text('프로젝트 삭제'),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteProject(Project currentProject) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '프로젝트를 삭제할까요?',
      message: '${currentProject.title} 프로젝트와 원고 연결이 삭제됩니다.',
    );
    if (!confirmed || !mounted) return;
    try {
      await _projectsRepository.delete(currentProject.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('삭제하지 못했습니다: $e')));
    }
  }

  Future<void> _confirmDeleteManuscript(ManuscriptDocument manuscript) async {
    final confirmed = await showConfirmDialog(
      context,
      title: '원고를 삭제할까요?',
      message: '${manuscript.title} 원고가 프로젝트에서 삭제됩니다.',
    );
    if (!confirmed || !mounted) return;
    try {
      await _documentsRepository.delete(widget.projectId, manuscript.id);
      if (!mounted) return;
      setState(() =>
          documents = documents.where((d) => d.id != manuscript.id).toList());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${manuscript.title} 원고를 삭제했습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('삭제하지 못했습니다: $e')));
    }
  }
}

class _ExportPanel extends StatefulWidget {
  const _ExportPanel({required this.projectId, required this.projectTitle});

  final String projectId;
  final String projectTitle;

  @override
  State<_ExportPanel> createState() => _ExportPanelState();
}

class _ExportPanelState extends State<_ExportPanel> {
  final _projectsRepository = ProjectsRepository();
  bool isExporting = false;

  Future<void> export(String format) async {
    setState(() => isExporting = true);
    try {
      final result = await _projectsRepository.export(widget.projectId, format);
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(result.bytes),
            name: result.filename,
            mimeType: result.contentType,
          ),
        ],
        subject: result.filename,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('내보내기에 실패했습니다: $e')),
      );
    } finally {
      if (mounted) setState(() => isExporting = false);
    }
  }

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
                for (final format in const {
                  'PDF': 'pdf',
                  'DOCX': 'docx',
                  'TXT': 'txt'
                }.entries)
                  ActionChip(
                    label: Text(format.key),
                    onPressed: isExporting ? null : () => export(format.value),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
