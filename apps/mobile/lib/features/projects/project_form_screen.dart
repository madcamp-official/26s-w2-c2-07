import 'package:flutter/material.dart';

import '../../shared/main_shell.dart';

class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({this.projectId, super.key});

  final String? projectId;

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  bool isCompleted = false;

  bool get isEditing => widget.projectId != null;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(
      text: isEditing ? '작은 기록의 습관' : '',
    );
    descriptionController = TextEditingController(
      text: isEditing ? '매일 남긴 글감을 한 편의 글로 묶는 프로젝트' : '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              isEditing ? '프로젝트 수정 API 연결이 필요합니다.' : '프로젝트 생성 API 연결이 필요합니다.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '프로젝트 수정' : '새 프로젝트'),
        actions: const [ProfileAction()],
      ),
      body: ListView(
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
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('완료 상태'),
            value: isCompleted,
            onChanged: (value) => setState(() => isCompleted = value),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: saveProject,
            icon: const Icon(Icons.check),
            label: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
