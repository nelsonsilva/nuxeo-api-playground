library doctypes;

/// [Doctype]
class Doctype {

  static const NONE = "None!!!";

  String name;
  String parent;
  List<String> facets;
  List<String> schemas;

  Doctype(this.name, {String parent, this.facets, this.schemas}) :
    this.parent = (parent == NONE) ? null : parent;

  toString() => name;
}

/// [Schema] field
class SchemaField {
  String name;
  var type;

  SchemaField._(this.name, this.type);

  factory SchemaField(String name, type) {
    if (type is String) {
      return new SchemaField._(name, type);
    } else if (type is Map) {
      var schema = new Schema.fromJSON(type);
      return new SchemaField._(name, schema);
    }
  }

  bool get isComplex => type is Schema;

  toString() => name;
}

/// [Schema]
class Schema {
  String name, prefix;
  List<SchemaField> fields = [];

  Schema({this.name, this.prefix});

  factory Schema.fromJSON(json) {
    var schema = new Schema(name: json["name"], prefix: json["@prefix"]);
    json["fields"].forEach((k, v) { schema.fields.add(new SchemaField(k, v)); });
    return schema;
  }

  toString() => name;
}

/// [Facet]
class Facet {
  String name;
  List<String> schemas = [];

  Facet(this.name);

  factory Facet.fromJSON(json) {
    var facet = new Facet(json["name"]);
    if (json["schemas"] != null) {
      facet.schemas.addAll(json["schemas"].map((s) => s["name"]));
    }
    return facet;
  }

  toString() => name;
}