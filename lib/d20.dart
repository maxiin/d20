/// Dart library for RPG dice rolling.
///
/// Import this library as follows:
///
/// ```
/// import 'package:d20/d20.dart';
/// ```

import 'dart:math';
import 'package:math_expressions/math_expressions.dart';

/// An expression-capable dice roller.
///
/// Simple usage:
/// ```
///   final D20 d20 = D20();
///   d20.roll('2d6+3');
/// ```
class D20 {
  final Parser _parser = Parser();
  final ContextModel _context = ContextModel();

  /// A [Random] instance that can be customized for seeding.
  Random _random;

  /// Creates a dice roller.
  ///
  /// Optionally receives a [Random].
  D20({Random random}) {
    _random = random == null ? Random() : random;
  }

  int _rollSingleDie(Match match) {
    final int numberOfRolls = match[1] == null ? 1 : int.parse(match[1]);
    final int dieSize = int.parse(match[2]);
    final List<int> rolls = List<int>.filled(numberOfRolls, dieSize)
        .map((int die) => _random.nextInt(die) + 1)
        .toList();

    final int minRoll = rolls.fold(dieSize, min);
    final int maxRoll = rolls.fold(0, max);

    final int sum = rolls.fold(0, (int sum, int roll) => sum + roll);

    if (match[3] == '-l') {
      return sum - minRoll;
    } else if (match[3] == '-h') {
      return sum - maxRoll;
    }

    return sum;
  }

  /// Compute an arithmetic expression, computing rolls defined on standard
  /// notation format.
  ///
  /// Example:
  /// ```
  ///   d20.roll('2d6+3');
  ///   d20.roll('2d20-L');
  ///   d20.roll('d% * 8');
  ///   d20.roll('cos(2 * 5d20)');
  /// ```
  int roll(String roll) {
    final String newRoll = roll
        .toLowerCase()
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll(RegExp(r'd%'), 'd100')
        .replaceAllMapped(RegExp(r'(\d+)?d(\d+)(-[l|h])?'),
            (Match m) => _rollSingleDie(m).toString());

    final double exactResult =
        _parser.parse(newRoll).evaluate(EvaluationType.REAL, _context);

    return exactResult.round();
  }
}
