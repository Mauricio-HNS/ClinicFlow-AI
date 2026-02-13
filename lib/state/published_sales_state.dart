import 'package:flutter/foundation.dart';

import '../models/sale.dart';
import '../services/listings_api_client.dart';
import 'auth_session_state.dart';

class PublishedSalesState {
  static final ValueNotifier<List<Sale>> sales = ValueNotifier<List<Sale>>(
    const <Sale>[],
  );

  static void addSale(Sale sale) {
    sales.value = <Sale>[sale, ...sales.value];
  }

  static void removeSale(String saleId) {
    sales.value = sales.value.where((sale) => sale.id != saleId).toList();
  }

  static void updateSale(Sale updatedSale) {
    sales.value = sales.value
        .map((sale) => sale.id == updatedSale.id ? updatedSale : sale)
        .toList();
  }

  static Future<void> syncMine() async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) return;
    try {
      final remoteSales = await ListingsApiClient.instance.fetchMine(token);
      sales.value = remoteSales;
    } catch (_) {
      // Keep local state as fallback when backend is unavailable.
    }
  }

  static Future<void> createSmart(Sale sale) async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) {
      addSale(sale);
      return;
    }

    try {
      final created = await ListingsApiClient.instance.create(token, sale);
      addSale(created);
    } catch (_) {
      addSale(sale);
    }
  }

  static Future<void> updateSmart(Sale sale) async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) {
      updateSale(sale);
      return;
    }

    try {
      final updated = await ListingsApiClient.instance.update(token, sale);
      updateSale(updated);
    } catch (_) {
      updateSale(sale);
    }
  }

  static Future<void> removeSmart(String saleId) async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) {
      removeSale(saleId);
      return;
    }

    try {
      await ListingsApiClient.instance.remove(token, saleId);
      removeSale(saleId);
    } catch (_) {
      // Keep state unchanged on remote failure.
    }
  }
}
