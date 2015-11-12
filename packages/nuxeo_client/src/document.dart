part of nuxeo_client;

class PropertyMap {

  Map _map;

  PropertyMap(this._map);

  operator[]= (key, value) => _map[key] = value;
  operator[] (key) => _map[key];

  toString() => _map.keys.map((k) => "$k=${_map[k]}").join("\n");
}

class Document {

  String repository;
  String uid;
  String path;
  String type;
  String state;
  String versionLabel;
  bool isCheckedOut;
  String title;
  DateTime lastModified;
  List<String> facets;

  Map<String, dynamic> properties = {};

  Document._internal(json) :
    repository = json["repository"],
    uid = json["uid"],
    path = json["path"],
    type = json["type"],
    state = json["state"],
    versionLabel = json["versionLabel"],
    isCheckedOut = json["isCheckedOut"],
    title = json["title"],
    facets = json["facets"] {

    if (json["lastModified"]!= null) {
      lastModified = DateTime.parse(json["lastModified"]);
    }

    if (json.containsKey("properties")) {
      json["properties"].forEach((k, v) { properties[k] = v; });
    }
  }

  factory Document.fromJSON(json) => new Document._internal(json);

  operator[]= (key, value) {
    if (key is List) {
      for (var i = 0; i < key.length; i++) {
        this[key[i]] = value[i];
      }
    }
    properties[key] = value;
  }

  operator[] (key) {
    if (key is List) {
      return key.map((k) => this[k]).toList();
    }
    return properties[key];
  }

  toString() => properties.toString();
}

class Pageable<T> extends IterableBase<T> {

  Iterable<T> entries;
  int totalSize,
      currentPageIndex,
      currentPageSize,
      maxPageSize,
      numberOfPages,
      pageSize;
  bool isLastPageAvailable,
       isNextPageAvailable,
       isPreviousPageAvailable,
       isSortable;

  Pageable(this.entries) : super();

  int get length => entries.length;

  get iterator => entries.iterator;
}
