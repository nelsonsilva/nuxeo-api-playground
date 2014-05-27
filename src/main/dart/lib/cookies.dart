library cookie;

import 'dart:html';

class _Cookies {
  operator[] (String key) {

    var cookies = document.cookie != null ? document.cookie.split('; ') : [];

    for (var i = 0, l = cookies.length; i < l; i++) {
      var parts = cookies[i].split('=');
      var name = _decode(parts[0]);

      if (key == name) {
        return parts[1] != null ? _decode(parts[1]) : null;
      }
    }
  }

  void operator[]= (String key, String value) {
    var cookie = Uri.encodeComponent(key) + '=' + Uri.encodeComponent(value);
    document.cookie = cookie;
  }

  bool remove(String key, {path, domain, secure}) {
    if (this[key] != null) {
      // In order to delete a cookie must set the expires date to something in the past.
      document.cookie = Uri.encodeComponent(key) + '=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
      return true;
    }
    return false;
  }

  String _decode(s) => Uri.decodeComponent(s.replaceAll(r"\+", ' '));
}

var cookies = new _Cookies();