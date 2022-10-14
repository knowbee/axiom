import 'dart:convert';

import 'package:axiom/src/encoder/util.dart';

/// SingularEncoder
class SingularEncoder extends Converter<String, String> {
  /// SingularEncoder Initializer
  SingularEncoder() {
    final rules = <List<Object>>[
      [r's$', (Match m) => ''],
      [r'(ss)$', (Match m) => m[1]],
      [r'(n)ews$', (Match m) => '${m[1]}ews'],
      [r'([ti])a$', (Match m) => '${m[1]}um'],
      [
        r'((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)(sis|ses)$',
        (Match m) => '${m[1]}sis'
      ],
      [r'(^analy)(sis|ses)$', (Match m) => '${m[1]}sis'],
      [r'([^f])ves$', (Match m) => '${m[1]}fe'],
      [r'(hive|tive)s$', (Match m) => m[1]],
      [r'([lr])ves$', (Match m) => '${m[1]}f'],
      [r'([^aeiouy]|qu)ies$', (Match m) => '${m[1]}y'],
      [r'(s)eries$', (Match m) => '${m[1]}eries'],
      [r'(m)ovies$', (Match m) => '${m[1]}ovie'],
      [r'(x|ch|ss|sh)es$', (Match m) => m[1]],
      [r'^(m|l)ice$', (Match m) => '${m[1]}ouse'],
      [r'(bus)(es)?$', (Match m) => m[1]],
      [r'(shoe)s$', (Match m) => m[1]],
      [r'(cris|test)(is|es)$', (Match m) => '${m[1]}is'],
      [r'^(a)x[ie]s$', (Match m) => '${m[1]}xis'],
      [r'(octop|vir)(us|i)$', (Match m) => '${m[1]}us'],
      [r'(alias|status)(es)?$', (Match m) => m[1]],
      ['^(ox)en', (Match m) => m[1]],
      [r'(vert|ind)ices$', (Match m) => '${m[1]}ex'],
      [r'(matr)ices$', (Match m) => '${m[1]}ix'],
      [r'(quiz)zes$', (Match m) => m[1]],
      [r'(database)s$', (Match m) => m[1]]
    ];

    for (final rule in rules) {
      _addInflectionRule(rule.first as String, rule.last);
    }
  }

  final List<List<dynamic>> _inflectionRules = <List<dynamic>>[];

  void _addInflectionRule(String plural, dynamic singular) {
    _inflectionRules
        .add(<dynamic>[RegExp(plural, caseSensitive: false), singular]);
  }

  @override
  String convert(String input) {
    if (input.isNotEmpty) {
      for (final r in _inflectionRules) {
        final pattern = r.first as RegExp;
        if (pattern.hasMatch(input)) {
          final matcher = r.last as MatchToString;
          return input.replaceAllMapped(
            pattern,
            (Match match) => matcher(match)!,
          );
        }
      }
    }
    return input;
  }
}
