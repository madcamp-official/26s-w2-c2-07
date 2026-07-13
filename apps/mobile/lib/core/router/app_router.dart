import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/captures/capture_create_screen.dart';
import '../../features/captures/capture_detail_screen.dart';
import '../../features/captures/captures_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/projects/manuscript_edit_screen.dart';
import '../../features/projects/project_detail_screen.dart';
import '../../features/projects/project_form_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../shared/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (_, __) => const HomeScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/captures',
              builder: (_, __) => const CapturesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/projects',
              builder: (_, __) => const ProjectsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/capture',
      builder: (_, state) => CaptureCreateScreen(
        initialType: state.uri.queryParameters['type'] ?? 'text',
      ),
    ),
    GoRoute(
      path: '/captures/:id',
      builder: (_, state) => CaptureDetailScreen(
        captureId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/projects/new',
      builder: (_, __) => const ProjectFormScreen(),
    ),
    GoRoute(
      path: '/projects/:id',
      builder: (_, state) => ProjectDetailScreen(
        projectId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/projects/:id/edit',
      builder: (_, state) => ProjectFormScreen(
        projectId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: '/projects/:id/manuscripts/:manuscriptId',
      builder: (_, state) => ManuscriptEditScreen(
        projectId: state.pathParameters['id']!,
        manuscriptId: state.pathParameters['manuscriptId']!,
      ),
    ),
  ],
);
