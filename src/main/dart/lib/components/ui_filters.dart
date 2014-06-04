library filters;

import 'dart:async';
import 'dart:math' show max;
// TODO(nfgs)
// @MirrorsUsed(symbols: const["name","label"], override: '*')
// import 'dart:mirrors';
import 'package:polymer_expressions/filter.dart';

class Capitalize extends Transformer<String, String> {
  Capitalize();
  String forward(String s) => s.split(" ").map((p) => p.substring(0, 1) .toUpperCase() + p.substring(1)).join(" ");
  String reverse(String s) => s; //throw new UnimplementedError("Capitalize transformer is irreversible!");
}

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

abstract class SearchFilter extends Object {
  // TODO(nfgs) - Find out why dart2js does not like the @observable annotation
  /// The term to filter with
  //@observable
  String searchTerm = '';
  /// searchFilter adds a delay to the searchTerm to prevent immediate changes to the results
  //@observable
  String searchFilter = '';

  int minSearchTermLength = 0;
  
  String labelFor(item) => item.toString();

  filter(term) => (items) {
    if (term.length < minSearchTermLength) {
      return [];
    }
    
    return term.isEmpty ? items : items.where((i) => labelFor(i).toLowerCase().contains(term.toLowerCase())).toList();
  };
  
  // Only "name" or "label" for now
  sort(fieldName) => (items) {
    if (fieldName != "name" && fieldName != "label") throw new UnimplementedError("sort only support 'name' or 'label' for now!");
    var lst = new List.from(items);
    var field = new Symbol(fieldName);
    lst.sort((a, b) {
      var fa, fb;
      // TODO(nfgs) Use reflection
      //var fa = reflect(a).getField(field).reflectee,
      //    fb = reflect(b).getField(field).reflectee;
      if (fieldName == "name") { fa = a.name; fb = b.name; }
      if (fieldName == "label") { fa = a.label; fb = b.label; }
      return fa.compareTo(fb);
    });
    return lst;
  };

  Timer _searchTimer;

  searchTermChanged(oldValue) {
    // If there's another keystroke during the delay then reset it
    if (_searchTimer != null) _searchTimer.cancel();
    new Timer(new Duration(milliseconds: 300), () => searchFilter = searchTerm);
  }

}