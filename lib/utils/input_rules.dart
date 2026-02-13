import 'package:flutter/services.dart';

class AppInputRules {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static List<TextInputFormatter> nameFormatters({int maxLength = 60}) {
    return <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÿ' -]")),
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static List<TextInputFormatter> emailFormatters({int maxLength = 80}) {
    return <TextInputFormatter>[
      FilteringTextInputFormatter.deny(RegExp(r'\s')),
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static List<TextInputFormatter> phoneFormatters({int maxDigits = 13}) {
    return <TextInputFormatter>[_PhoneIntlInputFormatter(maxDigits: maxDigits)];
  }

  static List<TextInputFormatter> priceFormatters({int maxLength = 24}) {
    return <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[0-9€.,\-\s/]')),
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static List<TextInputFormatter> shortTextFormatters({int maxLength = 80}) {
    return <TextInputFormatter>[LengthLimitingTextInputFormatter(maxLength)];
  }

  static List<TextInputFormatter> longTextFormatters({int maxLength = 320}) {
    return <TextInputFormatter>[LengthLimitingTextInputFormatter(maxLength)];
  }

  static List<TextInputFormatter> documentFormatters({int maxLength = 14}) {
    return <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
      UpperCaseTextFormatter(),
      LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email obrigatório';
    if (!_emailRegex.hasMatch(trimmed)) return 'Email inválido';
    return null;
  }

  static String? phone(String? value, {String label = 'Telefone'}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '$label obrigatório';
    if (trimmed.contains(',') ||
        trimmed.contains(';') ||
        trimmed.contains('|') ||
        trimmed.contains('/')) {
      return 'Informe apenas um número';
    }
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8 || digits.length > 15) {
      return '$label inválido';
    }
    return null;
  }

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Nome obrigatório';
    if (trimmed.length < 2) return 'Nome muito curto';
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    final raw = value ?? '';
    if (raw.trim().isEmpty) return 'Senha obrigatória';
    if (raw.length < minLength) return 'Senha mínima $minLength caracteres';
    return null;
  }

  static String? document(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Documento obrigatório';
    final dniNie = RegExp(r'^[A-Z0-9]{6,12}$');
    if (!dniNie.hasMatch(trimmed)) {
      return 'Documento inválido';
    }
    return null;
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _PhoneIntlInputFormatter extends TextInputFormatter {
  _PhoneIntlInputFormatter({required this.maxDigits});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final clipped = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;

    final country = clipped.length <= 2 ? clipped : clipped.substring(0, 2);
    final rest = clipped.length <= 2 ? '' : clipped.substring(2);

    final buffer = StringBuffer('+$country');
    for (var i = 0; i < rest.length; i++) {
      if (i % 3 == 0) buffer.write(' ');
      buffer.write(rest[i]);
    }

    final formatted = buffer.toString().trimRight();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
