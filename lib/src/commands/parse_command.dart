// Copyright (c) 2022, Igwaneza Bruce
// https://github.com/knowbee
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
// ignore_for_file: type_annotate_public_apis

import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:axiom/src/parser.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template sample_command}
///
/// `axiom sample`
/// A [Command] to exemplify a sub command
/// {@endtemplate}
class ParseCommand extends Command<int> {
  /// {@macro sample_command}
  ParseCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addFlag(
        'path',
        abbr: 'p',
        help: 'Path where the json file is located',
        negatable: false,
      )
      ..addFlag(
        'outDir',
        abbr: 'o',
        help: 'Path where the generated model will be saved',
        negatable: false,
      )
      ..addFlag(
        'modelName',
        abbr: 'c',
        help: 'Name of the generated Model',
        negatable: false,
      );
  }

  @override
  String get description => 'A sub command that generates model from json';

  @override
  String get name => 'generate';

  final Logger _logger;
  final jsonSchemaParser = JsonSchemaParser();

  @override
  Future<int> run() async {
    if (argResults!.rest.isEmpty) {
      _logger.info(red.wrap('Run the following command: axiom --help'));
      return ExitCode.success.code;
    }
    final schemaObj = File(argResults!.rest[0]).readAsStringSync();
    final models = jsonSchemaParser.getModels(
      schema: jsonDecode(schemaObj) as Map<String, dynamic>,
    );
    final results = jsonSchemaParser.getClasses(
      models: models,
      className: argResults!.rest[2],
    );
    await File('${argResults!.rest[1]}/${argResults!.rest[2]}.dart')
        .writeAsString(results.toString());

    final output = lightCyan.wrap('Your model is generated successfully');

    _logger.info(output);
    return ExitCode.success.code;
  }
}
