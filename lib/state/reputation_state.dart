import 'package:flutter/foundation.dart';

class ReputationState {
  static final ValueNotifier<double> rating = ValueNotifier<double>(4.8);
  static final ValueNotifier<int> points = ValueNotifier<int>(230);

  static void addPublishedSalePoints() {
    points.value = points.value + 8;
  }

  static void addSoldSalePoints() {
    points.value = points.value + 25;
    final next = (rating.value + 0.02).clamp(0.0, 5.0);
    rating.value = double.parse(next.toStringAsFixed(2));
  }
}
