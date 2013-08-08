import 'package:hop/hop.dart';
import 'package:hop/hop_tasks.dart';

void main() {
  addTask('build', createProcessTask('dart', args: ['build.dart'],
      description: "execute the project's build.dart file"));

  final paths = ['web/out/index.html_bootstrap.dart'];
  addTask('dart2js', createDartCompilerTask(paths,
      minify: true, liveTypeAnalysis: true, rejectDeprecatedFeatures: true));

  addChainedTask('build_js', ['build', 'dart2js']);

  addAsyncTask('pages', (ctx) =>
      branchForDir(ctx, 'master', 'web/out', 'gh-pages'));

  runHop();
}