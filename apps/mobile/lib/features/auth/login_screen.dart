import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                onPressed: () => context.go('/'),
                child: const Text('Google로 계속하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
