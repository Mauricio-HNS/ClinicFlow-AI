import 'package:flutter/foundation.dart';

import '../models/sale.dart';
import '../services/favorites_api_client.dart';
import 'auth_session_state.dart';

class FavoritesState {
  static final ValueNotifier<Set<String>> favoriteSaleIds =
      ValueNotifier<Set<String>>(<String>{});

  static bool isFavorite(String saleId) =>
      favoriteSaleIds.value.contains(saleId);

  static Future<void> toggleSale(Sale sale) async {
    final next = Set<String>.from(favoriteSaleIds.value);
    final added = next.add(sale.id);
    if (!added) {
      next.remove(sale.id);
    }
    favoriteSaleIds.value = next;

    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) return;

    try {
      if (added) {
        await FavoritesApiClient.instance.add(token, sale.id);
      } else {
        await FavoritesApiClient.instance.remove(token, sale.id);
      }
    } catch (_) {
      // Keep optimistic local state.
    }
  }

  static Future<void> removeSale(String saleId) async {
    if (!favoriteSaleIds.value.contains(saleId)) return;
    final next = Set<String>.from(favoriteSaleIds.value)..remove(saleId);
    favoriteSaleIds.value = next;

    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) return;
    try {
      await FavoritesApiClient.instance.remove(token, saleId);
    } catch (_) {
      // Keep optimistic local state.
    }
  }

  static Future<void> syncMine() async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) return;
    try {
      favoriteSaleIds.value = await FavoritesApiClient.instance.fetchMine(
        token,
      );
    } catch (_) {
      // Keep local state when backend is unavailable.
    }
  }
}
