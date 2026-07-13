import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          const SizedBox(height: 16),
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
