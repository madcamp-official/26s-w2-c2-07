import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSigningIn = false;

  // Fixed port so it can be registered as a Supabase redirect URL.
  static const _desktopCallbackPort = 8977;

  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  Future<void> signInWithGoogle() async {
    setState(() => isSigningIn = true);
    try {
      if (_isDesktop) {
        await _signInWithGoogleDesktop();
      } else {
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.nook://login-callback/',
          authScreenLaunchMode: LaunchMode.inAppWebView,
        );
      }
      // go_router's redirect (driven by onAuthStateChange) takes over from here.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패했습니다: $e')),
      );
    } finally {
      if (mounted) setState(() => isSigningIn = false);
    }
  }

  Future<void> _signInWithGoogleDesktop() async {
    final server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      _desktopCallbackPort,
    );
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://127.0.0.1:$_desktopCallbackPort/callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      final request = await server.first.timeout(const Duration(minutes: 3));
      final callbackUri = request.requestedUri;

      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.html
        ..write('<html><body>로그인이 완료되었습니다. 이 창을 닫아주세요.</body></html>');
      await request.response.close();

      await Supabase.instance.client.auth.getSessionFromUrl(callbackUri);
    } finally {
      await server.close(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nook.', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 16),
              Text('마음에 머문 것을\n한 문장씩 꺼내 놓는 곳.',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 36),
              FilledButton(
                onPressed: isSigningIn ? null : signInWithGoogle,
                child: isSigningIn
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Google로 계속하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
