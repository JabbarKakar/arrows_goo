import 'package:arrows_goo/core/feel/feel_service.dart';

class FakeFeelService implements FeelService {
  final calls = <String>[];

  @override
  Future<void> validMove() async => calls.add('validMove');

  @override
  Future<void> blockedTap() async => calls.add('blockedTap');

  @override
  Future<void> cleared() async => calls.add('cleared');
}
