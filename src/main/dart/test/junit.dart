library junit;

import 'dart:html';
import 'package:unittest/unittest.dart';

void useJUnitConfiguration() {
  unittestConfiguration = new JUnitConfiguration();
}

/**
 * A test configuration that emits JUnit compatible XML output.
 * Based on http://pub.dartlang.org/packages/junitconfiguration
 */
class JUnitConfiguration extends SimpleConfiguration {

  final StringSink _output = new StringBuffer();
  final DateTime _time = new DateTime.now();

  Map<TestCase, List<String>> _stdout = new Map();

  JUnitConfiguration() : super() {
    throwOnTestFailures = false;
    stopTestOnExpectFailure = false;
  }

  @override
  String get name => 'JUnit Test Configuration';

  @override
  void onSummary(int passed, int failed, int errors, List<TestCase> results, String uncaughtError) {
    super.onSummary(passed, failed, errors, results, uncaughtError);
    var totalTime = 0, skipped = 0;
    for (var testCase in results) {
      if (testCase.runningTime != null) {
        totalTime += testCase.runningTime.inMilliseconds;
      }
      if (!testCase.enabled) {
        skipped++;
      }
    }
    _output.writeln('<?xml version="1.0" encoding="UTF-8" ?>');
    _output.writeln('<testsuite name="All tests" ' +
        'tests="${results.length}" failures="$failed" errors="$errors" ' +
        'skipped="$skipped" time="${totalTime / 1000.0}" timestamp="${_time}">');
    for (TestCase testCase in results) {
      var time = testCase.runningTime != null ? testCase.runningTime.inMilliseconds : 0;
      _output.writeln('  <testcase id="${testCase.id}" name="${_xml(testCase.description)}" ' +
          'time="${time / 1000.0}">');
      if (testCase.result == FAIL) {
        _output.writeln('    <failure>${_xml(testCase.message)}</failure>');
      } else if (testCase.result == ERROR) {
        _output.writeln('    <error>${_xml(testCase.message)}</error>');
      } else if (!testCase.enabled) {
        _output.writeln('    <skipped>${_xml(testCase.message)}</skipped>');
      }
      if (_stdout.containsKey(testCase)) {
        var output = _stdout[testCase].join('\n');
        _output.writeln('    <system-out>${_xml(output)}</system-out>');
      }
      if (testCase.stackTrace != null) {
        _output.writeln('    <system-err>${_xml(testCase.stackTrace)}</system-err>');
      }
      _output.writeln('  </testcase>');
    }
    if (uncaughtError != null && !uncaughtError.isEmpty) {
      _output.writeln('  <system-err>${_xml(uncaughtError)}</system-err>');
    }
    _output.writeln('</testsuite>');
  }

  void onDone(bool success) {
    print(_output.toString());
    super.onDone(success);
    window.postMessage('unittest-suite-done', '*');
  }

  String _xml(value) {
    return value.toString()
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

}