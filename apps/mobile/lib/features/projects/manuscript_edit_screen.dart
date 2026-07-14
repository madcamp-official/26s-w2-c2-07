import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/capture_type_ui.dart';
import '../../data/models/capture.dart';
import '../../data/repositories/captures_repository.dart';
import '../../data/repositories/documents_repository.dart';
import '../../data/repositories/projects_repository.dart';
import '../../features/captures/captures_screen.dart';
import '../../shared/main_shell.dart';

class ManuscriptEditScreen extends StatefulWidget {
  const ManuscriptEditScreen({
    required this.projectId,
    required this.manuscriptId,
    super.key,
  });

  final String projectId;
  final String manuscriptId;

  @override
  State<ManuscriptEditScreen> createState() => _ManuscriptEditScreenState();
}

class _ManuscriptEditScreenState extends State<ManuscriptEditScreen> {
  final _documentsRepository = DocumentsRepository();
  final _projectsRepository = ProjectsRepository();

  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  bool get isNew => widget.manuscriptId == 'new';
  bool isLoading = false;
  bool isSaving = false;
  bool isDeleting = false;
  bool isProjectCompleted = false;
  bool isToolRailOpen = false;
  Object? loadError;
  String? documentId;

  @override
  void initState() {
    super.initState();
    _loadProjectStatus();
    if (!isNew) {
      documentId = widget.manuscriptId;
      _load();
    }
  }

  Future<void> _loadProjectStatus() async {
    try {
      final project = await _projectsRepository.get(widget.projectId);
      if (mounted) setState(() => isProjectCompleted = project.isDone);
    } catch (_) {
      // 프로젝트 상태 확인 실패 시 편집 가능 상태로 두고 저장 API에서 최종 검증합니다.
    }
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final document =
          await _documentsRepository.get(widget.projectId, widget.manuscriptId);
      titleController.text = document.title;
      bodyController.text = document.content;
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
    bodyController.dispose();
    super.dispose();
  }

  Future<void> deleteManuscript() async {
    if (isProjectCompleted) return;
    final confirmed = await showConfirmDialog(
      context,
      title: '원고를 삭제할까요?',
      message: '삭제한 원고는 복구할 수 없습니다.',
    );
    if (!confirmed || !mounted) return;
    setState(() => isDeleting = true);
    try {
      await _documentsRepository.delete(widget.projectId, documentId!);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('삭제하지 못했습니다: $e')));
      setState(() => isDeleting = false);
    }
  }

  Future<void> saveManuscript() async {
    if (isProjectCompleted) return;
    setState(() => isSaving = true);
    try {
      if (documentId == null) {
        final created = await _documentsRepository.create(
          widget.projectId,
          title: titleController.text.trim().isEmpty
              ? '제목 없음'
              : titleController.text.trim(),
          content: bodyController.text,
        );
        documentId = created.id;
      } else {
        await _documentsRepository.update(
          widget.projectId,
          documentId!,
          title: titleController.text.trim(),
          content: bodyController.text,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('원고를 저장했습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('저장하지 못했습니다: $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void openCaptureConnector() {
    if (isProjectCompleted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CaptureConnectorSheet(projectId: widget.projectId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(documentId == null ? '새 원고' : '원고 수정'),
        actions: const [ProfileAction()],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('원고를 불러오지 못했습니다.\n$loadError',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      OutlinedButton(
                          onPressed: _load, child: const Text('다시 시도')),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 64, 28),
                      children: [
                        if (isProjectCompleted)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              color: AppTheme.mist,
                              child: const ListTile(
                                leading: Icon(Icons.lock_outline),
                                title: Text('완료된 프로젝트'),
                                subtitle: Text('완료된 프로젝트의 원고는 읽기만 가능해요.'),
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.paper,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppTheme.line),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.coffee.withValues(alpha: 0.06),
                                blurRadius: 22,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: titleController,
                                readOnly: isProjectCompleted,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                                decoration: const InputDecoration(
                                  hintText: '원고 제목',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                ),
                              ),
                              const Divider(height: 28),
                              TextField(
                                controller: bodyController,
                                readOnly: isProjectCompleted,
                                minLines: 18,
                                maxLines: 32,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontFamily: 'Gowun Batang',
                                      fontSize: 17,
                                      height: 1.75,
                                    ),
                                decoration: const InputDecoration(
                                  hintText: '여기에 원고를 이어 써보세요.',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: isSaving || isProjectCompleted
                              ? null
                              : saveManuscript,
                          icon: isSaving
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: const Text('저장'),
                        ),
                        if (documentId != null)
                          TextButton.icon(
                            onPressed: isDeleting || isProjectCompleted
                                ? null
                                : deleteManuscript,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('원고 삭제'),
                          ),
                      ],
                    ),
                    _EditorToolRail(
                      isOpen: isToolRailOpen,
                      isDisabled: isProjectCompleted,
                      onToggle: () =>
                          setState(() => isToolRailOpen = !isToolRailOpen),
                      onConnectCaptures: openCaptureConnector,
                    ),
                  ],
                ),
    );
  }
}

class _EditorToolRail extends StatelessWidget {
  const _EditorToolRail({
    required this.isOpen,
    required this.isDisabled,
    required this.onToggle,
    required this.onConnectCaptures,
  });

  final bool isOpen;
  final bool isDisabled;
  final VoidCallback onToggle;
  final VoidCallback onConnectCaptures;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 18,
      right: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: AppTheme.coffee,
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(18),
            ),
            child: InkWell(
              onTap: onToggle,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 18,
                ),
                child: Icon(
                  isOpen ? Icons.chevron_right : Icons.chevron_left,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: isOpen ? 188 : 0,
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: isOpen ? 1 : 0,
                child: Container(
                  width: 188,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.paper,
                    border: Border.all(color: AppTheme.line),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.coffee.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(-8, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '원고 도구',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: isDisabled ? null : onConnectCaptures,
                        icon: const Icon(Icons.collections_bookmark_outlined),
                        label: const Text('글감 연결'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureConnectorSheet extends StatefulWidget {
  const _CaptureConnectorSheet({required this.projectId});

  final String projectId;

  @override
  State<_CaptureConnectorSheet> createState() => _CaptureConnectorSheetState();
}

class _CaptureConnectorSheetState extends State<_CaptureConnectorSheet> {
  final _capturesRepository = CapturesRepository();
  final _projectsRepository = ProjectsRepository();

  bool isLinkedExpanded = true;
  String query = '';
  bool isLoading = true;
  Object? loadError;
  List<Capture> allCaptures = [];
  Set<String> linkedIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final results = await Future.wait([
        _capturesRepository.list(),
        _projectsRepository.listCaptures(widget.projectId),
      ]);
      setState(() {
        allCaptures = results[0];
        linkedIds = results[1].map((c) => c.id).toSet();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        loadError = e;
        isLoading = false;
      });
    }
  }

  List<Capture> get filteredCaptures {
    final text = query.trim();
    if (text.isEmpty) return allCaptures;
    return allCaptures.where((capture) {
      return capture.displayTitle.contains(text) ||
          captureTypeLabel(capture.type).contains(text) ||
          capture.tags.any((tag) => tag.name.contains(text));
    }).toList();
  }

  Future<void> toggle(Capture capture) async {
    final isLinked = linkedIds.contains(capture.id);
    try {
      if (isLinked) {
        await _projectsRepository.unlinkCapture(widget.projectId, capture.id);
        setState(() => linkedIds.remove(capture.id));
      } else {
        await _projectsRepository.linkCapture(widget.projectId, capture.id);
        setState(() => linkedIds.add(capture.id));
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLinked
                ? '${capture.displayTitle} 글감 연결을 해제했습니다.'
                : '${capture.displayTitle} 글감을 연결했습니다.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('연결 상태를 바꾸지 못했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final linkedCaptures =
        allCaptures.where((c) => linkedIds.contains(c.id)).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 24),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : loadError != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('글감을 불러오지 못했습니다.\n$loadError',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        OutlinedButton(
                            onPressed: _load, child: const Text('다시 시도')),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('글감 연결',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      TextField(
                        onChanged: (value) => setState(() => query = value),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: '제목, 태그, 형태 검색',
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(
                            () => isLinkedExpanded = !isLinkedExpanded),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              AnimatedRotation(
                                turns: isLinkedExpanded ? 0.25 : 0,
                                duration: const Duration(milliseconds: 180),
                                child: const Icon(Icons.chevron_right),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '프로젝트에 연결된 글감',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Text('${linkedCaptures.length}개'),
                            ],
                          ),
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Column(
                          children: [
                            for (final capture in linkedCaptures)
                              _ConnectorCaptureTile(
                                capture: capture,
                                isLinked: true,
                                onToggle: () => toggle(capture),
                              ),
                          ],
                        ),
                        crossFadeState: isLinkedExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 180),
                      ),
                      const SizedBox(height: 8),
                      Text('모든 글감',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView(
                          children: [
                            for (final capture in filteredCaptures)
                              _ConnectorCaptureTile(
                                capture: capture,
                                isLinked: linkedIds.contains(capture.id),
                                onToggle: () => toggle(capture),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _ConnectorCaptureTile extends StatelessWidget {
  const _ConnectorCaptureTile({
    required this.capture,
    required this.isLinked,
    required this.onToggle,
  });

  final Capture capture;
  final bool isLinked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.mist,
          foregroundColor: AppTheme.moss,
          child: Icon(captureTypeIcon(capture.type)),
        ),
        title: Text(capture.displayTitle),
        subtitle: Text(
          '${capture.tags.isNotEmpty ? '#${capture.tags.first.name} · ' : ''}${captureTypeLabel(capture.type)}',
        ),
        trailing: IconButton(
          tooltip: isLinked ? '연결 해제' : '원고에 연결',
          onPressed: onToggle,
          icon: Icon(
            isLinked ? Icons.remove_circle_outline : Icons.add_circle_outline,
            color: isLinked ? AppTheme.moss : null,
          ),
        ),
      ),
    );
  }
}
