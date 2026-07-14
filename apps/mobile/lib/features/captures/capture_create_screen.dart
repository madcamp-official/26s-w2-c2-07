import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/capture.dart';
import '../../data/models/tag.dart';
import '../../data/repositories/captures_repository.dart';
import '../../data/repositories/storage_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../shared/main_shell.dart';

class CaptureCreateScreen extends StatefulWidget {
  const CaptureCreateScreen({this.initialType = 'text', super.key});

  final String initialType;

  @override
  State<CaptureCreateScreen> createState() => _CaptureCreateScreenState();
}

class _CaptureCreateScreenState extends State<CaptureCreateScreen> {
  final _capturesRepository = CapturesRepository();
  final _tagsRepository = TagsRepository();
  final _storageRepository = StorageRepository();
  final _imagePicker = ImagePicker();

  late String type;
  final contentController = TextEditingController();
  final linkController = TextEditingController();
  final tagController = TextEditingController();
  final tags = <String>[];

  List<Tag> existingTags = [];
  XFile? pickedFile;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    type = switch (widget.initialType) {
      'photo' => 'photo',
      'video' => 'video',
      'link' => 'link',
      _ => 'text',
    };
    _tagsRepository.list().then((value) {
      if (mounted) setState(() => existingTags = value);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    contentController.dispose();
    linkController.dispose();
    tagController.dispose();
    super.dispose();
  }

  void addTag() {
    final value = tagController.text.trim();
    if (value.isEmpty || tags.contains(value)) return;
    setState(() {
      tags.add(value);
      tagController.clear();
    });
  }

  Future<void> pickMedia() async {
    final file = type == 'video'
        ? await _imagePicker.pickVideo(source: ImageSource.gallery)
        : await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => pickedFile = file);
  }

  String _contentTypeFor(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'heic' => 'image/heic',
      'webp' => 'image/webp',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      _ => 'application/octet-stream',
    };
  }

  Future<List<String>> _resolveTagIds() async {
    final ids = <String>[];
    for (final name in tags) {
      Tag? existing;
      for (final tag in existingTags) {
        if (tag.name == name) {
          existing = tag;
          break;
        }
      }
      if (existing != null) {
        ids.add(existing.id);
        continue;
      }
      final created = await _tagsRepository.create(name);
      existingTags = [...existingTags, created];
      ids.add(created.id);
    }
    return ids;
  }

  Future<void> saveCapture() async {
    final content = contentController.text.trim();
    final url = linkController.text.trim();

    if (type == 'text' && content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('내용을 입력해주세요.')));
      return;
    }
    if (type == 'link' && url.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('링크 주소를 입력해주세요.')));
      return;
    }

    setState(() => isSaving = true);
    try {
      final tagIds = await _resolveTagIds();
      final capture = await _capturesRepository.create(
        type: captureTypeFromString(type),
        content: content.isEmpty ? null : content,
        url: type == 'link' ? url : null,
        tagIds: tagIds,
      );

      if ((type == 'photo' || type == 'video') && pickedFile != null) {
        final bytes = await pickedFile!.readAsBytes();
        await _storageRepository.uploadCaptureAsset(
          captureId: capture.id,
          fileName: pickedFile!.name,
          contentType: _contentTypeFor(pickedFile!.name),
          bytes: bytes,
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
        title: const Text('글감 수집'),
        actions: const [ProfileAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            '지금 붙잡은 것을\n짧게 남겨두세요.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'text',
                  icon: Icon(Icons.short_text),
                  label: Text('글')),
              ButtonSegment(
                  value: 'photo',
                  icon: Icon(Icons.photo_camera_outlined),
                  label: Text('사진')),
              ButtonSegment(
                  value: 'video',
                  icon: Icon(Icons.videocam_outlined),
                  label: Text('동영상')),
              ButtonSegment(
                  value: 'link', icon: Icon(Icons.link), label: Text('링크')),
            ],
            selected: {type},
            onSelectionChanged: (value) =>
                setState(() {
                  type = value.first;
                  pickedFile = null;
                }),
          ),
          const SizedBox(height: 20),
          if (type == 'link')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: linkController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: '링크',
                  hintText: 'https://',
                ),
              ),
            ),
          if (type == 'photo' || type == 'video')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton.icon(
                onPressed: pickMedia,
                icon: Icon(type == 'photo'
                    ? Icons.photo_library_outlined
                    : Icons.video_library_outlined),
                label: Text(pickedFile == null
                    ? (type == 'photo' ? '사진 선택' : '동영상 선택')
                    : pickedFile!.name),
              ),
            ),
          TextField(
            controller: contentController,
            minLines: type == 'text' ? 8 : 4,
            maxLines: type == 'text' ? 16 : 8,
            decoration: InputDecoration(
              labelText: type == 'link' ? '메모' : '내용',
              hintText: '떠오른 문장, 장면, 감정을 그대로 적어보세요.',
            ),
          ),
          const SizedBox(height: 16),
          Text('태그', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
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
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: tagController,
                  decoration: const InputDecoration(hintText: '새 태그'),
                  onSubmitted: (_) => addTag(),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: '태그 추가',
                onPressed: addTag,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isSaving ? null : saveCapture,
            icon: isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('글감 저장'),
          ),
        ],
      ),
    );
  }
}
