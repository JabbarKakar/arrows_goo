import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef Now = DateTime Function();

final clockProvider = Provider<Now>((ref) => DateTime.now);
