import 'package:flutter/foundation.dart';

import '../services/auth_api_client.dart';
import '../services/auth_session_storage.dart';
import 'profile_state.dart';

class AuthSessionState {
  static final ValueNotifier<String?> token = ValueNotifier<String?>(null);
  static final ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);
  static final ValueNotifier<String?> userId = ValueNotifier<String?>(null);

  static void applySession(AuthSession session) {
    token.value = session.token;
    userId.value = session.user.id;
    isAuthenticated.value = true;
    ProfileState.updateBasicData(
      updatedName: session.user.name,
      updatedEmail: session.user.email,
      updatedPhone: session.user.phone,
    );
  }

  static Future<void> applyAndPersist(AuthSession session) async {
    applySession(session);
    await AuthSessionStorage.save(
      token: session.token,
      userId: session.user.id,
      name: session.user.name,
      email: session.user.email,
      phone: session.user.phone,
    );
  }

  static Future<bool> restoreFromStorage() async {
    final storedToken = await AuthSessionStorage.readToken();
    if (storedToken == null || storedToken.isEmpty) {
      clear();
      return false;
    }

    try {
      final user = await AuthApiClient.instance.me(storedToken);
      applySession(
        AuthSession(
          token: storedToken,
          user: AuthUser(
            id: user.id,
            name: user.name,
            email: user.email,
            phone: user.phone,
          ),
        ),
      );
      return true;
    } catch (_) {
      await clearPersisted();
      return false;
    }
  }

  static void clear() {
    token.value = null;
    userId.value = null;
    isAuthenticated.value = false;
  }

  static Future<void> clearPersisted() async {
    clear();
    await AuthSessionStorage.clear();
  }
}
