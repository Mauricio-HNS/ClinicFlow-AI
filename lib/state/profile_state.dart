import 'package:flutter/foundation.dart';

class ProfileState {
  static final ValueNotifier<bool> isVerified = ValueNotifier<bool>(false);
  static final ValueNotifier<String> name = ValueNotifier<String>(
    'Clara Martinez',
  );
  static final ValueNotifier<String> email = ValueNotifier<String>(
    'clara@email.com',
  );
  static final ValueNotifier<String> phone = ValueNotifier<String>(
    '+34 600 000 000',
  );
  static final ValueNotifier<Uint8List?> avatarBytes =
      ValueNotifier<Uint8List?>(null);

  static void updateBasicData({
    String? updatedName,
    String? updatedEmail,
    String? updatedPhone,
  }) {
    if (updatedName != null && updatedName.trim().isNotEmpty) {
      name.value = updatedName.trim();
    }
    if (updatedEmail != null && updatedEmail.trim().isNotEmpty) {
      email.value = updatedEmail.trim();
    }
    if (updatedPhone != null && updatedPhone.trim().isNotEmpty) {
      phone.value = updatedPhone.trim();
    }
  }

  static void updateAvatar(Uint8List bytes) {
    avatarBytes.value = bytes;
  }
}
