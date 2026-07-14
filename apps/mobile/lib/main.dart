import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // video_player has no native Windows implementation; fvp fills that gap.
  fvp.registerWith(options: {'platforms': ['windows']});
  await _loadEnvironment();
  await _initializeSupabase();
  runApp(const NookApp());
}

Future<void> _loadEnvironment() async {
  try {
    await dotenv.load();
  } catch (error) {
    debugPrint('Failed to load .env: $error');
  }
}

Future<void> _initializeSupabase() async {
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    debugPrint('Skipped Supabase initialization: missing environment values.');
    return;
  }

  try {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  } catch (error) {
    debugPrint('Failed to initialize Supabase: $error');
  }
}
