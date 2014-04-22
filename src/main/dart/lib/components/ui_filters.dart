library filters;

import 'dart:async';
import 'dart:math' show max;
import 'dart:mirrors';
import 'package:polymer/polymer.dart';
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

abstract class SearchFilter extends Object implements Observable {
  /// The term to filter with
  @observable String searchTerm = '';

  String labelFor(item);

  filter(term) => (items) => term.isEmpty ? items : items.where((i) => labelFor(i).toLowerCase().contains(term.toLowerCase())).toList();

  sort(fieldName) => (items) {
    var lst = new List.from(items);
    var field = new Symbol(fieldName);
    lst.sort((a, b) {
      var fa = reflect(a).getField(field).reflectee,
          fb = reflect(b).getField(field).reflectee;
      return fa.compareTo(fb);
    });
    return lst;
  };

  /// searchFilter adds a delay to the searchTerm to prevent immediate changes to the results
  @observable String searchFilter = '';

  Timer _searchTimer;

  searchTermChanged(oldValue) {
    // If there's another keystroke during the delay then reset it
    if (_searchTimer != null) _searchTimer.cancel();
    new Timer(new Duration(milliseconds: 300), () => searchFilter = searchTerm);
  }

}