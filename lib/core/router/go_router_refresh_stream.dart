import 'dart:async';
import 'package:flutter/foundation.dart';

/// Converts a [Stream] into a [ChangeNotifier], which is needed by [GoRouter]
/// for its [refreshListenable] parameter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
