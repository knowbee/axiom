// Copyright (c) 2022, Igwaneza Bruce
// https://github.com/knowbee
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

@Tags(['version-verify'])
import 'package:build_verify/build_verify.dart';
import 'package:test/test.dart';

void main() {
  test('ensure_build', expectBuildClean);
}
