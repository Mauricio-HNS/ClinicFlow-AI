import 'package:flutter/foundation.dart';

import '../models/sale.dart';

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
}
