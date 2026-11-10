import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Toggle simulasi offline — biar demo tidak bergantung ke Wi-Fi kelas.
final forceOfflineProvider = StateProvider<bool>((ref) => false);