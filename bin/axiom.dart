import 'dart:io';

import 'package:axiom/src/command_runner.dart';

Future<void> main(List<String> args) async {
  await _flushThenExit(await AxiomCommandRunner().run(args));
}

Future<void> _flushThenExit(int status) {
  return Future.wait<void>([stdout.close(), stderr.close()])
      .then<void>((_) => exit(status));
}
