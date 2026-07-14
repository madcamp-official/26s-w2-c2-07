import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authReady = AuthReady();

class AuthReady extends ChangeNotifier {
  bool _isReady = false;

  bool get isReady => _isReady;

  Future<void> initialize() async {
    await _recoverSession();
    _isReady = true;
    notifyListeners();
  }

  Future<void> recover() async {
    _isReady = false;
    notifyListeners();
    await _recoverSession();
    _isReady = true;
    notifyListeners();
  }

  Future<void> _recoverSession() async {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;

    if (session == null) return;
    if (session.accessToken.isNotEmpty) return;

    try {
      await auth.refreshSession();
    } catch (_) {
      await auth.signOut();
    }
  }
}
