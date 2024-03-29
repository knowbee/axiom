## axiom

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A CLI tool that converts JSON into gorgeous, typesafe code in dart

---

## Getting Started 🚀

Activate globally via:

```sh
dart pub global activate axiom
```

Or locally via:

```sh
dart pub global activate --source=path <path to this package>
```

## Usage

```sh
# Example
$ axiom generate --path {path} --outDir {output path}  --modelName {Your dart class name}

# Show CLI version
$ axiom --version

# Show usage help
$ axiom --help
```

## Running Tests with coverage 🧪

To run all unit tests use the following command:

```sh
$ dart pub global activate coverage 1.2.0
$ dart test --coverage=coverage
$ dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov)
.

```sh
# Generate Coverage Report
$ genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
$ open coverage/index.html
```

## Credits

[![Deriv](https://avatars.githubusercontent.com/u/61439569?s=200&v=4)](https://github.com/deriv-com 'Deriv')

## Author

Igwaneza Bruce

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
