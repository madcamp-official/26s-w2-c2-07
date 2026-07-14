import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  refreshListenable: _authRefreshListenable,
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentSession != null;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isLoggedIn) return isLoggingIn ? null : '/login';
    if (isLoggingIn) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (_, __) => _fadePage(const LoginScreen()),
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (_, __) => _fadePage(const HomeScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/captures',
              pageBuilder: (_, __) => _fadePage(const CapturesScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/projects',
              pageBuilder: (_, __) => _fadePage(const ProjectsScreen()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (_, __) => _fadePage(const ProfileScreen()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/capture',
      pageBuilder: (_, state) => _slidePage(
        CaptureCreateScreen(
          initialType: state.uri.queryParameters['type'] ?? 'text',
        ),
      ),
    ),
    GoRoute(
      path: '/captures/:id',
      pageBuilder: (_, state) => _slidePage(
        CaptureDetailScreen(
          captureId: state.pathParameters['id']!,
        ),
      ),
    ),
    GoRoute(
      path: '/projects/new',
      pageBuilder: (_, __) => _slidePage(const ProjectFormScreen()),
    ),
    GoRoute(
      path: '/projects/:id',
      pageBuilder: (_, state) => _slidePage(
        ProjectDetailScreen(
          projectId: state.pathParameters['id']!,
        ),
      ),
    ),
    GoRoute(
      path: '/projects/:id/edit',
      pageBuilder: (_, state) => _slidePage(
        ProjectFormScreen(
          projectId: state.pathParameters['id'],
        ),
      ),
    ),
    GoRoute(
      path: '/projects/:id/manuscripts/:manuscriptId',
      pageBuilder: (_, state) => _slidePage(
        ManuscriptEditScreen(
          projectId: state.pathParameters['id']!,
          manuscriptId: state.pathParameters['manuscriptId']!,
        ),
      ),
    ),
  ],
);

final _authRefreshListenable =
    _GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange);

/// Turns the auth state stream into a Listenable so go_router re-evaluates
/// its `redirect` callback whenever the user signs in or out.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

CustomTransitionPage<void> _fadePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slidePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: animation.drive(tween), child: child),
      );
    },
  );
}
