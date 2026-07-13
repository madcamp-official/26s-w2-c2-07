import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool captureAlertsEnabled = true;
  bool darkReadingEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로필')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 42,
            child: Icon(Icons.person_outline, size: 42),
          ),
          const SizedBox(height: 18),
          Text(
            '우현',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'nook@example.com',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 28),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.bookmark_border),
                  title: Text('수집한 글감'),
                  trailing: Text('24'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.folder_outlined),
                  title: Text('진행 중 프로젝트'),
                  trailing: Text('3'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('알림', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('새 글감 알림'),
              subtitle: const Text('모바일이나 웹에서 새 글감이 추가되면 알려드려요.'),
              value: captureAlertsEnabled,
              activeThumbColor: AppTheme.moss,
              onChanged: (value) =>
                  setState(() => captureAlertsEnabled = value),
            ),
          ),
          const SizedBox(height: 20),
          Text('원고 보기 환경', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('어두운 화면으로 보기'),
              subtitle: const Text('원고를 확인할 때 눈이 편안한 어두운 배경을 사용해요.'),
              value: darkReadingEnabled,
              activeThumbColor: AppTheme.moss,
              onChanged: (value) =>
                  setState(() => darkReadingEnabled = value),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            label: const Text('프로필 수정'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
