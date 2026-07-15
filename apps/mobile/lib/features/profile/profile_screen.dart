import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/profile.dart';
import '../../data/models/project.dart';
import '../../data/repositories/captures_repository.dart';
import '../../data/repositories/me_repository.dart';
import '../../data/repositories/memory_cache.dart';
import '../../data/repositories/projects_repository.dart';
import '../../data/repositories/settings_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _meRepository = MeRepository();
  final _settingsRepository = SettingsRepository();
  final _capturesRepository = CapturesRepository();
  final _projectsRepository = ProjectsRepository();

  bool isLoading = true;
  Object? loadError;
  Profile? profile;
  int captureCount = 0;
  int activeProjectCount = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });
    try {
      final results = await Future.wait([
        _meRepository.get(),
        _capturesRepository.list(),
        _projectsRepository.list(),
      ]);
      if (!mounted) return;
      final loadedProfile = results[0] as Profile;
      final captures = results[1] as List;
      final projects = results[2] as List<Project>;
      setState(() {
        profile = loadedProfile;
        captureCount = captures.length;
        activeProjectCount = projects.where((p) => !p.isDone).length;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadError = e;
        isLoading = false;
      });
    }
  }

  Future<void> updateSettings({
    bool? captureAlertsEnabled,
    bool? darkEditorEnabled,
  }) async {
    final current = profile;
    if (current == null) return;
    try {
      final updated = await _settingsRepository.update(
        captureAlertsEnabled: captureAlertsEnabled,
        darkEditorEnabled: darkEditorEnabled,
      );
      setState(() {
        profile = Profile(
          id: current.id,
          email: current.email,
          displayName: current.displayName,
          avatarUrl: current.avatarUrl,
          provider: current.provider,
          createdAt: current.createdAt,
          settings: updated,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('설정을 저장하지 못했습니다. $e')),
      );
    }
  }

  Future<void> editDisplayName() async {
    final current = profile;
    if (current == null) return;
    final controller = TextEditingController(text: current.displayName ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 수정'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '이름'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      final updated = await _meRepository.update(displayName: name);
      if (!mounted) return;
      setState(() => profile = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필을 수정하지 못했습니다. $e')),
      );
    }
  }

  Future<void> signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('현재 계정에서 로그아웃할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    repositoryCache.clear();
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text(
          '계정을 삭제하면 프로필과 개인 데이터가 삭제됩니다. 이 작업은 되돌릴 수 없어요. 정말 탈퇴할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _meRepository.delete();
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원 탈퇴에 실패했어요. $e')),
      );
    }
  }

  void goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: '뒤로 가기',
          onPressed: goBack,
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text('내 프로필'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '프로필을 불러오지 못했습니다.\n$loadError',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: load,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final current = profile!;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: AppTheme.mist,
          foregroundColor: AppTheme.coffee,
          backgroundImage: current.avatarUrl != null
              ? NetworkImage(current.avatarUrl!)
              : null,
          child: current.avatarUrl == null
              ? const Icon(Icons.person_outline, size: 42)
              : null,
        ),
        const SizedBox(height: 18),
        Text(
          current.displayName ?? '이름 없음',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          current.email ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.muted,
              ),
        ),
        const SizedBox(height: 28),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('수집한 글감'),
                trailing: Text('$captureCount'),
                onTap: () => context.go('/captures'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('진행 중인 프로젝트'),
                trailing: Text('$activeProjectCount'),
                onTap: () => context.go('/projects'),
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
            subtitle: const Text('모바일이나 웹에서 글감이 추가되면 알려드려요.'),
            value: current.settings.captureAlertsEnabled,
            activeThumbColor: AppTheme.clay,
            onChanged: (value) => updateSettings(captureAlertsEnabled: value),
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
            value: current.settings.darkEditorEnabled,
            activeThumbColor: AppTheme.clay,
            onChanged: (value) => updateSettings(darkEditorEnabled: value),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: editDisplayName,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('프로필 수정'),
        ),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: signOut,
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                onPressed: deleteAccount,
                icon: const Icon(Icons.person_remove_outlined),
                label: const Text('회원 탈퇴'),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
