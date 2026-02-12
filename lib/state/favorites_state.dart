import 'package:flutter/foundation.dart';

import '../models/sale.dart';

class FavoritesState {
  static final ValueNotifier<Set<String>> favoriteSaleIds =
      ValueNotifier<Set<String>>(<String>{});

  static bool isFavorite(String saleId) =>
      favoriteSaleIds.value.contains(saleId);

  static void toggleSale(Sale sale) {
    final next = Set<String>.from(favoriteSaleIds.value);
    if (!next.add(sale.id)) {
      next.remove(sale.id);
    }
    favoriteSaleIds.value = next;
  }

  static void removeSale(String saleId) {
    if (!favoriteSaleIds.value.contains(saleId)) return;
    final next = Set<String>.from(favoriteSaleIds.value)..remove(saleId);
    favoriteSaleIds.value = next;
  }
}
