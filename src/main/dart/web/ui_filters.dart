library filters;

import 'dart:math' show max;
import 'package:polymer_expressions/filter.dart';

class StringToID extends Transformer<String, String> {
  StringToID();
  String forward(String s) => s.replaceAll(new RegExp(r'[^A-Za-z0-9]'), "-");
  String reverse(String s) => s; //throw new UnimplementedError("StringToID transformer is irreversible!");
}

class FileSizeToString extends Transformer<String, num> {
  FileSizeToString();
  String forward(num fileSizeInBytes) {
    var i = -1;
    var byteUnits = [' kB', ' MB', ' GB', ' TB', 'PB', 'EB', 'ZB', 'YB'];
    do {
      fileSizeInBytes = fileSizeInBytes / 1024;
      i++;
    } while (fileSizeInBytes > 1024);

    return max(fileSizeInBytes, 0.1).toStringAsFixed(1) + byteUnits[i];
  }
  num reverse(String s) => 0; // TODO(nfgs)
}