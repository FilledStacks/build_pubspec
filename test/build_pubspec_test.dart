import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_pubspec/builder.dart';
import 'package:build_test/build_test.dart';
import 'package:checked_yaml/checked_yaml.dart';
import 'package:test/test.dart';

// Simple wrapper function to make test cases more readable
Future<dynamic> Function() build({
  required Map<String, String> pubspecContent,
  String? expectedOutput,
  Map<String, dynamic>? config,
}) {
  return () {
    return testBuilder(
      buildPubspec(BuilderOptions(config ?? {})),
      <String, String>{'pkg|pubspec.yaml': jsonEncode(pubspecContent)},
      outputs: {'pkg|lib/src/pubspec.dart': expectedOutput ?? ''},
    );
  };
}

const _parsedYamlException = TypeMatcher<ParsedYamlException>();

void main() {
  test('no name provided', () {
    expect(
      build(pubspecContent: {'version': '1.0.0'}),
      throwsA(_parsedYamlException),
    );
  });

  test('bad version provided', () {
    expect(
      build(
        pubspecContent: {
          'name': 'pkg',
          'version': 'not a version',
        },
      ),
      throwsA(_parsedYamlException),
    );
  });

  test(
      'valid input',
      build(
          pubspecContent: {'name': 'pkg', 'version': '1.0.0'},
          expectedOutput: r"""
// Generated file. Do not modify.
//
// This file is generated using the build_pubspec package.
// For more information, go to: https://pub.dev/packages/build_pubspec
const String name = '''pkg''';
const String version = '''1.0.0''';
"""));

  test(
      'valid input with custom field',
      build(
        config: {'version_field_name': 'myVersion'},
        pubspecContent: {'name': 'pkg', 'version': '1.0.0'},
        expectedOutput: r"""
// Generated file. Do not modify.
//
// This file is generated using the build_pubspec package.
// For more information, go to: https://pub.dev/packages/build_pubspec
const String name = '''pkg''';
const String myVersion = '''1.0.0''';
""",
      ));

  test(
      'valid input with custom and default fields',
      build(
        config: {
          'version_field_name': 'currentVersion',
          'name_field_name': 'packageName',
          'homepage_field_name': 'url',
        },
        pubspecContent: {
          'name': 'build_pubspec',
          'version': '1.0.0',
          'repository': 'https://github.com/dartsidedev/build_pubspec',
          'homepage': 'https://pub.dev/packages/build_pubspec',
          'issue_tracker':
              'https://github.com/dartsidedev/build_pubspec/issues',
          'description':
              'Extract pubspec details (such as package version, author and description) into Dart code.',
          'author': 'Vince Varga <vince.varga@serial.dev>',
        },
        expectedOutput: r"""
// Generated file. Do not modify.
//
// This file is generated using the build_pubspec package.
// For more information, go to: https://pub.dev/packages/build_pubspec
const List<String> authors = [
  'Vince Varga <vince.varga@serial.dev>',
];
const String description = '''Extract pubspec details (such as package version, author and description) into Dart code.''';
const String url = '''https://pub.dev/packages/build_pubspec''';
const String issueTracker = '''https://github.com/dartsidedev/build_pubspec/issues''';
const String packageName = '''build_pubspec''';
const String repository = '''https://github.com/dartsidedev/build_pubspec''';
const String currentVersion = '''1.0.0''';
""",
      ));
}
