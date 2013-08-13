import 'dart:io';
import 'package:polymer/component_build.dart';

// Ref: http://www.dartlang.org/articles/dart-web-components/tools.html
main() {

  final args = new Options().arguments;
  final changes = getChangedFiles(args);

  if(changes.any((c) => c.startsWith(r'web/'))) {
    Process.run('./bin/copy_assets.sh', [])
      .then((ProcessResult pr) {
        if(pr.exitCode == 0) {
          log('copy of assets from web dir completed');
        } else {
          log(pr.stderr);
        }
      });
  } else {
    log(' - skipping copy assets');
  }

  args.addAll(['--', '--no-rewrite-urls']);

  build(args, ['web/index.html']);
}

void log(value) {
  if(value != null) {
    print(value);
  }
}

List<String> getChangedFiles(List<String> args) {
  return args.where((value) => value.contains('='))
      .map((value) {
        final indexOfEqu = value.indexOf('=');
        return value.substring(indexOfEqu+1);
      })
      .toList();
}
