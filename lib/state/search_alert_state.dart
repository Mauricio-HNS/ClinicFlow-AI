import 'package:flutter/foundation.dart';

class SearchAlert {
  final String term;
  final bool active;

  const SearchAlert({
    required this.term,
    this.active = true,
  });
}

class SearchAlertState {
  static final ValueNotifier<List<SearchAlert>> alerts = ValueNotifier<List<SearchAlert>>([]);

  static void addAlert(String term) {
    final clean = term.trim();
    if (clean.isEmpty) return;
    final normalized = _normalize(clean);
    final exists = alerts.value.any((item) => _normalize(item.term) == normalized);
    if (exists) return;
    alerts.value = [SearchAlert(term: clean), ...alerts.value];
  }

  static void removeAlert(SearchAlert alert) {
    alerts.value = alerts.value.where((item) => item.term != alert.term).toList(growable: false);
  }

  static String? matchTerm(String text) {
    final normalizedText = _normalize(text);
    for (final alert in alerts.value) {
      if (!alert.active) continue;
      final normalizedTerm = _normalize(alert.term);
      if (normalizedTerm.isEmpty) continue;
      if (normalizedText.contains(normalizedTerm)) return alert.term;
    }
    return null;
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }
}
