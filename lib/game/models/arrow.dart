import 'package:meta/meta.dart';

import 'direction.dart';
import 'grid_pos.dart';

@immutable
class Arrow {
  Arrow({
    required this.id,
    required this.direction,
    required this.colorIndex,
    required List<GridPos> cells,
  }) : cells = List.unmodifiable(cells);

  final int id;
  final Direction direction;
  final int colorIndex;

  /// Tail → head, orthogonal steps. Facing [direction] is at the head.
  final List<GridPos> cells;

  GridPos get head => cells.last;

  GridPos get tail => cells.first;

  int get turnCount {
    if (cells.length < 3) return 0;
    var turns = 0;
    for (var i = 1; i < cells.length - 1; i++) {
      final inRow = cells[i].row - cells[i - 1].row;
      final inCol = cells[i].col - cells[i - 1].col;
      final outRow = cells[i + 1].row - cells[i].row;
      final outCol = cells[i + 1].col - cells[i].col;
      if (inRow != outRow || inCol != outCol) turns++;
    }
    return turns;
  }

  bool occupies(GridPos pos) {
    for (final cell in cells) {
      if (cell == pos) return true;
    }
    return false;
  }

  /// True when the polyline U-turns into itself or the head faces its own body.
  bool get bendsTowardSelf {
    if (cells.length < 2) return false;
    final ahead = GridPos(
      head.row + direction.dRow,
      head.col + direction.dCol,
    );
    if (occupies(ahead)) return true;
    for (var i = 0; i < cells.length; i++) {
      for (var j = i + 2; j < cells.length; j++) {
        final dr = (cells[i].row - cells[j].row).abs();
        final dc = (cells[i].col - cells[j].col).abs();
        if (dr + dc == 1) return true;
      }
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is Arrow &&
      other.id == id &&
      other.direction == direction &&
      other.colorIndex == colorIndex &&
      _sameCells(other.cells);

  bool _sameCells(List<GridPos> other) {
    if (other.length != cells.length) return false;
    for (var i = 0; i < cells.length; i++) {
      if (cells[i] != other[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(id, direction, colorIndex, Object.hashAll(cells));

  @override
  String toString() => 'Arrow($id, ${direction.token}, ${cells.length})';
}
