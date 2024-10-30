import "dart:async";
import "package:burt_network/generated.dart";

import "package:autonomy/interfaces.dart";

mixin ValueReporter {
  AutonomyInterface get collection;
  Message getMessage();

  Timer? timer;
  Duration get reportInterval => const Duration(milliseconds: 10);

  Future<bool> init() async {
    timer = Timer.periodic(reportInterval, (timer) => _reportValue());
    return true;
  }
  
  Future<void> dispose() async => timer?.cancel();
  void _reportValue() => collection.server.sendMessage(getMessage());
}
