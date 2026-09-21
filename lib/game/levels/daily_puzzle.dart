import '../engine/level_generator.dart';

abstract final class DailyPuzzle {
  static String idFor(DateTime date) {
    final local = date.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  static int seedFor(String id) => int.parse(id);

  static String labelFor(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final local = date.toLocal();
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }

  static CampaignSpec specFor(String id) {
    final variant = seedFor(id) % 3;
    return switch (variant) {
      0 => CampaignSpec.forLevel(30),
      1 => CampaignSpec.forLevel(55),
      _ => CampaignSpec.forLevel(85),
    };
  }
}
