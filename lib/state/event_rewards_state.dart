import 'package:flutter/foundation.dart';

class EventRewardsState {
  static final ValueNotifier<int> soldSales = ValueNotifier<int>(0);
  static final ValueNotifier<int> freeEventCredits = ValueNotifier<int>(0);

  static bool registerSoldSale() {
    soldSales.value = soldSales.value + 1;
    final earnedNow = soldSales.value % 5 == 0;
    if (earnedNow) {
      freeEventCredits.value = freeEventCredits.value + 1;
    }
    return earnedNow;
  }

  static bool consumeFreeCredit() {
    if (freeEventCredits.value <= 0) return false;
    freeEventCredits.value = freeEventCredits.value - 1;
    return true;
  }

  static int salesUntilNextReward() {
    final mod = soldSales.value % 5;
    return mod == 0 ? 5 : 5 - mod;
  }
}
