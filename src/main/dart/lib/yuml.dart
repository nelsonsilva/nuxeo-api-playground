library yuml;

import 'doctypes.dart';

class DiagramStyle {
  static const String BORING = "nofunky";
  static const String PLAIN = "plain";
}

class DiagramGenerator {

  static const String STYLE = DiagramStyle.BORING;
  static const int SCALE = 80;
  static const String DIRECTION = "TB";
  static const String KIND = "class";
  static const String URL = "http://yuml.me/diagram/$STYLE;scale:$SCALE;dir:$DIRECTION;/$KIND/";

  Map<String, Doctype> doctypes = {};
  Map<String, Schema> schemas = {};
  Map<String, Facet> facets = {};

  DiagramGenerator({
    Iterable<Doctype> doctypes,
    Iterable<Schema> schemas,
    Iterable<Facet> facets}) {
    doctypes.forEach((d){ this.doctypes[d.name] = d; });
    schemas.forEach((s){ this.schemas[s.name] = s; });
    facets.forEach((f){ this.facets[f.name] = f; });
  }

  String generateForDoctype(String name) => URL + _umlForDoctype(name).join(",");

  List _umlForDoctype(String name) {
    var doctype = doctypes[name];

    var uml = ["[${doctype.name}]"];

    var inheritedFacets = [],
        inheritedSchemas = [];

    // Inheritance
    // [Parent]^-[Child]
    // TODO(nfgs) - Remove None!!! test
    if (doctype.parent != null && doctype.parent != "None!!!") {
      uml.add("[${doctype.parent}]^-[${doctype.name}]");
      uml.addAll(_umlForDoctype(doctype.parent));

      // Get the list of inherited facets and schemas
      inheritedFacets = doctypes[doctype.parent].facets;
      inheritedSchemas = doctypes[doctype.parent].schemas;
    }

    // Facets
    // [Doctype]-.->[Facet]
    doctype.facets
    .where((f) => !inheritedFacets.contains(f))
    .forEach((f) {
      uml.add("[${doctype.name}]-.->[<<${f}>>]");
      uml.addAll(_umlForFacet(f));
    });

    var facetSchemas = doctype.facets.fold([], (s, f) => s..addAll(facets[f].schemas));

    // Schemas
    // [Doctype or Facet]++->[Schema]
    doctype.schemas
    .where((s) => !inheritedSchemas.contains(s) && !facetSchemas.contains(s))
    .forEach((s) {
      var schema = schemas[s];
      uml.add("[${doctype.name}]++->[${schema.prefix}:${schema.name}]");
      uml.addAll(_umlForSchema(s));
    });

    return uml;
  }

  List _umlForFacet(String name) {
    var facet = facets[name];
    var uml = ["[<<${facet.name}>>]"];
    // Schemas
    // [Doctype or Facet]++->[Schema]
    facet.schemas
    .forEach((s) {
      var schema = schemas[s];
      uml.add("[<<${facet.name}>>]++->[${schema.prefix}:${schema.name}]");
      uml.addAll(_umlForSchema(s));
    });
    return uml;
  }

  List _umlForSchema(String name) {
    var schema = schemas[name];
    var fields = schema.fields.map((f) => f.name).join(";");
    return ["[${schema.prefix}:${schema.name}|$fields]"];
  }
}