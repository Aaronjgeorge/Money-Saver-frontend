// navigation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentIndexProvider = StateProvider<int>((ref) {
  return 0; // Initial index is set to 0
});
