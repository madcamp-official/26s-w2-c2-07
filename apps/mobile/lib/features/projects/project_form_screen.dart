import 'package:flutter/material.dart';

import '../../data/models/project.dart';
import '../../data/repositories/projects_repository.dart';
import '../../shared/main_shell.dart';

class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({this.projectId, super.key});

  final String? projectId;

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _projectsRepository = ProjectsRepository();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isCompleted = false;
  bool isLoading = false;
  bool isSaving = false;
  Object? loadError;

  bool get isEditing => widget.projectId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) _load();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final project = await _projectsRepository.get(widget.projectId!);
      titleController.text = project.title;
      descriptionController.text = project.description ?? '';
      isCompleted = project.isDone;
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        loadError = e;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> saveProject() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('프로젝트 이름을 입력해주세요.')));
      return;
    }

    setState(() => isSaving = true);
    try {
      if (isEditing) {
        await _projectsRepository.update(
          widget.projectId!,
          title: title,
          description: descriptionController.text.trim(),
        );
        await _projectsRepository.updateStatus(
          widget.projectId!,
          isCompleted ? ProjectStatus.done : ProjectStatus.active,
        );
      } else {
        await _projectsRepository.create(
          title: title,
          description: descriptionController.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('저장하지 못했습니다: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '프로젝트 수정' : '새 프로젝트'),
        actions: const [ProfileAction()],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('프로젝트를 불러오지 못했습니다.\n$loadError', textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      OutlinedButton(onPressed: _load, child: const Text('다시 시도')),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: '프로젝트 이름'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(labelText: '설명'),
                    ),
                    if (isEditing) ...[
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('완료 상태'),
                        value: isCompleted,
                        onChanged: (value) => setState(() => isCompleted = value),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: isSaving ? null : saveProject,
                      icon: isSaving
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: const Text('저장'),
                    ),
                  ],
                ),
    );
  }
}
