import 'package:flutter/material.dart';

class CaptureCreateScreen extends StatefulWidget {
  const CaptureCreateScreen({super.key});

  @override
  State<CaptureCreateScreen> createState() => _CaptureCreateScreenState();
}

class _CaptureCreateScreenState extends State<CaptureCreateScreen> {
  String type = 'text';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('글감 남기기')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'text', label: Text('조각글')),
              ButtonSegment(value: 'photo', label: Text('사진')),
              ButtonSegment(value: 'link', label: Text('링크')),
            ],
            selected: {type},
            onSelectionChanged: (value) => setState(() => type = value.first),
          ),
          const SizedBox(height: 20),
          const TextField(
            minLines: 6,
            maxLines: 12,
            decoration: InputDecoration(hintText: '떠오른 생각을 적어보세요.'),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: () {}, child: const Text('글감 저장')),
        ],
      ),
    );
  }
}
