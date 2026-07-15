import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/capture_type_ui.dart';
import '../../data/models/capture.dart';
import '../../data/repositories/captures_repository.dart';
import '../../data/repositories/documents_repository.dart';
import '../../data/repositories/projects_repository.dart';
import '../../data/repositories/settings_repository.dart';
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
  final _settingsRepository = SettingsRepository();

  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  bool get isNew => widget.manuscriptId == 'new';
  bool isLoading = false;
  bool isSaving = false;
  bool isDeleting = false;
  bool isProjectCompleted = false;
  bool useDarkEditor = false;
  Object? loadError;
  String? documentId;

  @override
  void initState() {
    super.initState();
    _loadProjectStatus();
    _loadEditorSettings();
    if (!isNew) {
      documentId = widget.manuscriptId;
      _load();
    }
  }

  Future<void> _loadEditorSettings() async {
    try {
      final settings = await _settingsRepository.get();
      if (mounted) setState(() => useDarkEditor = settings.darkEditorEnabled);
    } catch (_) {
      // 설정 확인 실패 시 기본 밝은 원고 화면을 사용합니다.
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
    if (isProjectCompleted || documentId == null) return;
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
          .showSnackBar(SnackBar(content: Text('삭제하지 못했어요. $e')));
      setState(() => isDeleting = false);
    }
  }

  Future<void> saveManuscript() async {
    if (isProjectCompleted) return;

    setState(() => isSaving = true);
    try {
      final title = titleController.text.trim().isEmpty
          ? '제목 없음'
          : titleController.text.trim();
      if (documentId == null) {
        final created = await _documentsRepository.create(
          widget.projectId,
          title: title,
          content: bodyController.text,
        );
        documentId = created.id;
      } else {
        await _documentsRepository.update(
          widget.projectId,
          documentId!,
          title: title,
          content: bodyController.text,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('원고를 저장했어요.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('저장하지 못했어요. $e')));
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> openCaptureConnector() async {
    if (isProjectCompleted) return;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '글감 연결 닫기',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, _, __) => Align(
        alignment: Alignment.centerRight,
        child: _CaptureConnectorPanel(
          projectId: widget.projectId,
          onInsert: insertCaptureIntoManuscript,
        ),
      ),
      transitionBuilder: (context, animation, _, child) {
        final offset = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(offset),
          child: child,
        );
      },
    );
  }

  void insertCaptureIntoManuscript(Capture capture) {
    final text = _captureText(capture);
    if (text.trim().isEmpty) return;

    final selection = bodyController.selection;
    final current = bodyController.text;
    final insertText = current.isEmpty ? text : '\n\n$text';

    if (!selection.isValid) {
      bodyController.text = '$current$insertText';
      bodyController.selection = TextSelection.collapsed(
        offset: bodyController.text.length,
      );
      return;
    }

    final start = selection.start.clamp(0, current.length);
    final end = selection.end.clamp(0, current.length);
    final next = current.replaceRange(start, end, insertText);
    bodyController.text = next;
    bodyController.selection = TextSelection.collapsed(
      offset: start + insertText.length,
    );
  }

  String _captureText(Capture capture) {
    final parts = [
      capture.displayTitle,
      if (capture.content?.trim().isNotEmpty == true) capture.content!.trim(),
      if (capture.url?.trim().isNotEmpty == true) capture.url!.trim(),
    ];
    return parts.toSet().join('\n');
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
                      Text('원고를 불러오지 못했어요.\n$loadError',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _load,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 34, 28),
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
                        _ManuscriptPaper(
                          titleController: titleController,
                          bodyController: bodyController,
                          isReadOnly: isProjectCompleted,
                          useDarkEditor: useDarkEditor,
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: isSaving || isProjectCompleted
                              ? null
                              : saveManuscript,
                          icon: isSaving
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
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
                    Positioned(
                      top: 92,
                      right: 0,
                      child: _CaptureBookmarkTab(
                        isDisabled: isProjectCompleted,
                        onTap: openCaptureConnector,
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ManuscriptPaper extends StatelessWidget {
  const _ManuscriptPaper({
    required this.titleController,
    required this.bodyController,
    required this.isReadOnly,
    required this.useDarkEditor,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final bool isReadOnly;
  final bool useDarkEditor;

  @override
  Widget build(BuildContext context) {
    final paperColor = useDarkEditor ? AppTheme.darkPaper : AppTheme.paper;
    final borderColor = useDarkEditor ? AppTheme.darkLine : AppTheme.line;
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: useDarkEditor ? AppTheme.cream : AppTheme.ink,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: useDarkEditor ? AppTheme.cream : AppTheme.ink,
          fontFamily: 'Gowun Batang',
          fontSize: 17,
          height: 1.75,
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
      decoration: BoxDecoration(
        color: paperColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.coffee.withValues(alpha: useDarkEditor ? 0.18 : 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            readOnly: isReadOnly,
            style: titleStyle,
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
            readOnly: isReadOnly,
            minLines: 22,
            maxLines: 44,
            style: bodyStyle,
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
    );
  }
}

class _CaptureBookmarkTab extends StatelessWidget {
  const _CaptureBookmarkTab({
    required this.isDisabled,
    required this.onTap,
  });

  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDisabled ? AppTheme.muted : AppTheme.coffee,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
      elevation: 6,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          child: Text(
            '글감\n연결',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureConnectorPanel extends StatefulWidget {
  const _CaptureConnectorPanel({
    required this.projectId,
    required this.onInsert,
  });

  final String projectId;
  final ValueChanged<Capture> onInsert;

  @override
  State<_CaptureConnectorPanel> createState() => _CaptureConnectorPanelState();
}

class _CaptureConnectorPanelState extends State<_CaptureConnectorPanel> {
  final _capturesRepository = CapturesRepository();
  final _projectsRepository = ProjectsRepository();

  String query = '';
  bool isLoading = true;
  bool isLinkedExpanded = true;
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
        linkedIds = results[1].map((capture) => capture.id).toSet();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        loadError = e;
        isLoading = false;
      });
    }
  }

  List<Capture> get linkedCaptures => filteredCaptures
      .where((capture) => linkedIds.contains(capture.id))
      .toList();

  List<Capture> get filteredCaptures {
    final text = query.trim();
    if (text.isEmpty) return allCaptures;
    return allCaptures.where((capture) {
      return capture.displayTitle.contains(text) ||
          captureTypeLabel(capture.type).contains(text) ||
          capture.tags.any((tag) => tag.name.contains(text));
    }).toList();
  }

  Future<void> linkCapture(Capture capture) async {
    try {
      await _projectsRepository.linkCapture(widget.projectId, capture.id);
      if (!mounted) return;
      setState(() => linkedIds.add(capture.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('글감을 연결하지 못했어요. $e')));
    }
  }

  Future<void> unlinkCapture(Capture capture) async {
    try {
      await _projectsRepository.unlinkCapture(widget.projectId, capture.id);
      if (!mounted) return;
      setState(() => linkedIds.remove(capture.id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('글감 연결을 해제하지 못했어요. $e')));
    }
  }

  void openDetail(Capture capture) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _ConnectorCaptureDetail(
        capture: capture,
        isLinked: linkedIds.contains(capture.id),
        onLink: () async {
          await linkCapture(capture);
          if (context.mounted) Navigator.of(context).pop();
        },
        onUnlink: () async {
          await unlinkCapture(capture);
          if (context.mounted) Navigator.of(context).pop();
        },
        onInsert: () {
          widget.onInsert(capture);
          Navigator.of(context).pop();
          Navigator.of(this.context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SizedBox(
          width: width * 0.88,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : loadError != null
                    ? _ConnectorError(error: loadError!, onRetry: _load)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '글감 연결',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            onChanged: (value) => setState(() => query = value),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: '제목, 태그, 형태 검색',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: ListView(
                              children: [
                                _LinkedCaptureSection(
                                  captures: linkedCaptures,
                                  isExpanded: isLinkedExpanded,
                                  onToggle: () => setState(
                                    () => isLinkedExpanded = !isLinkedExpanded,
                                  ),
                                  onOpen: openDetail,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text(
                                      '모든 글감',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${filteredCaptures.length}개',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: AppTheme.muted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (filteredCaptures.isEmpty)
                                  const _ConnectorEmpty(
                                    message: '검색 조건에 맞는 글감이 없어요.',
                                  )
                                else
                                  for (final capture in filteredCaptures)
                                    _ConnectorCaptureTile(
                                      capture: capture,
                                      isLinked: linkedIds.contains(capture.id),
                                      onTap: () => openDetail(capture),
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

class _ConnectorError extends StatelessWidget {
  const _ConnectorError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('글감을 불러오지 못했어요.\n$error', textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

class _LinkedCaptureSection extends StatelessWidget {
  const _LinkedCaptureSection({
    required this.captures,
    required this.isExpanded,
    required this.onToggle,
    required this.onOpen,
  });

  final List<Capture> captures;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ValueChanged<Capture> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: const Icon(Icons.chevron_right),
                ),
                const SizedBox(width: 4),
                Text(
                  '이미 연결된 글감',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  '${captures.length}개',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: captures.isEmpty
              ? const _ConnectorEmpty(message: '아직 연결된 글감이 없어요.')
              : Column(
                  children: [
                    for (final capture in captures)
                      _ConnectorCaptureTile(
                        capture: capture,
                        isLinked: true,
                        onTap: () => onOpen(capture),
                      ),
                  ],
                ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
          firstCurve: Curves.easeOutCubic,
          secondCurve: Curves.easeOutCubic,
        ),
      ],
    );
  }
}

class _ConnectorEmpty extends StatelessWidget {
  const _ConnectorEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.paper,
        border: Border.all(color: AppTheme.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppTheme.muted),
      ),
    );
  }
}

class _ConnectorCaptureTile extends StatelessWidget {
  const _ConnectorCaptureTile({
    required this.capture,
    required this.isLinked,
    required this.onTap,
  });

  final Capture capture;
  final bool isLinked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: AppTheme.mist,
            foregroundColor: AppTheme.moss,
            child: Icon(captureTypeIcon(capture.type)),
          ),
          title: Text(
            capture.displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${capture.tags.isNotEmpty ? '#${capture.tags.first.name} · ' : ''}${captureTypeLabel(capture.type)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Icon(
            isLinked ? Icons.bookmark : Icons.bookmark_border,
            color: isLinked ? AppTheme.clay : null,
          ),
        ),
      ),
    );
  }
}

class _ConnectorCaptureDetail extends StatelessWidget {
  const _ConnectorCaptureDetail({
    required this.capture,
    required this.isLinked,
    required this.onLink,
    required this.onUnlink,
    required this.onInsert,
  });

  final Capture capture;
  final bool isLinked;
  final Future<void> Function() onLink;
  final Future<void> Function() onUnlink;
  final VoidCallback onInsert;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.68,
        child: ListView(
          children: [
            Chip(
              avatar: Icon(captureTypeIcon(capture.type), size: 18),
              label: Text(captureTypeLabel(capture.type)),
            ),
            const SizedBox(height: 12),
            _CapturePreview(capture: capture),
            const SizedBox(height: 14),
            Text(
              capture.displayTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (capture.content?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(
                capture.content!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (capture.url?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 10),
              SelectableText(capture.url!),
            ],
            const SizedBox(height: 18),
            if (!isLinked)
              FilledButton.icon(
                onPressed: onLink,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('글감 연결'),
              )
            else ...[
              OutlinedButton.icon(
                onPressed: onUnlink,
                icon: const Icon(Icons.bookmark_remove_outlined),
                label: const Text('글감 연결 해제'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onInsert,
                icon: const Icon(Icons.add),
                label: const Text('원고에 추가'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CapturePreview extends StatelessWidget {
  const _CapturePreview({required this.capture});

  final Capture capture;

  @override
  Widget build(BuildContext context) {
    final imageUrl = capture.type == CaptureType.link
        ? capture.linkImageUrl
        : capture.imageUrl ?? capture.linkImageUrl;

    if (imageUrl == null || imageUrl.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
