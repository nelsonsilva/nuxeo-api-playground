library nx_structures_browser;

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html';
import 'package:polymer/polymer.dart';
import '../doctypes.dart' as nuxeo;
import 'ui_filters.dart';
import 'ui_module.dart';
import 'nx_connection.dart';
import '../yuml.dart' as yuml;
import 'semantic.dart';

class Selection extends Observable {
  @observable var type;
  @observable var id;
  @observable var item;
  Selection({this.type, this.id});
}

@CustomTag(NXStructuresBrowser.TAG)
class NXStructuresBrowser extends NXModule with SemanticUI, SearchFilter {

  static const String TAG = "nx-structures-browser";

  String title = "Data Structures",
         icon = "images/data_structure.png",
         description = "Browse all the available definitions of types, schemas and properties held by a document.",
         action = "Browse";

  final Map<String, List> items = toObservable({
    "schemas": [],
    "facets": [],
    "types": []});

  // SearchFilter
  @observable String searchTerm = '';
  @observable String searchFilter = '';

  List<nuxeo.Schema> get schemas => items["schemas"];
  List<nuxeo.Facet> get facets => items["facets"];
  List<nuxeo.Doctype> get doctypes => items["types"];

  @observable Selection selection = null;

  factory NXStructuresBrowser() => new Element.tag(TAG);

  yuml.DiagramGenerator _diagram;

  NXStructuresBrowser.created() : super.created() {
  }

  enteredView() {
    // Setup the accordion
    accordion(".ui.accordion");
  }

  get _currentItemDiagram {
    if (selection.item is nuxeo.Doctype) {
      return _diagram.generateForDoctype(selection.item.name);
    } else if (selection.item is nuxeo.Facet) {
      return _diagram.generateForFacet(selection.item.name);
    }
  }

  @override
  onConnect() {

    Future.wait([

    // Schemas
    NX.schemas().then((response) {
      schemas
        ..clear()
        ..addAll(
            JSON.decode(response.body).map((s)
                => new nuxeo.Schema.fromJSON(s)));
    }),

    // Facets
    NX.facets().then((response) {
      facets
      ..clear()
      ..addAll(
          JSON.decode(response.body).map((s)
              => new nuxeo.Facet.fromJSON(s)));
    }),

    // Doctypes
    NX.types().then((response) {
      doctypes.clear();

      JSON.decode(response.body)["doctypes"].forEach((k, v) {
        doctypes.add(new nuxeo.Doctype(k,
            parent: v["parent"],
            schemas: v["schemas"],
            facets: v["facets"]));
      });
    })])

    .then((_) {
      // Check for a selected item
      selectionChanged();
      // Setup the diagram generator
      _diagram = new yuml.DiagramGenerator(schemas: schemas, facets: facets, doctypes: doctypes);
    })
    .catchError((e) {
      connection.alerts.add(
        new Alert.error("Please check the Nuxeo URL and try connecting again.")
      );
      return false;
    });

  }

  void selectionChanged() {
    if (selection != null && items[selection.type].isNotEmpty) {
      selection.item = items[selection.type].where((d) => d.name == selection.id).first;

      // Update the UI
      if (selection.item != null) {
        async((_) {
          popup('.diagram', on: "click", position: "bottom right", html: "<img src='$_currentItemDiagram'>");
        });
      }
    }

  }

  @override
   void setupRoutes(Route route) {
     route.addRoute(
         name: 'view',
         path: '/:type/:id',
         enter: (e) {
           selection = new Selection(type: e.parameters['type'], id: e.parameters['id']);
         },
         leave: (e) {
           jQuery('.diagram').callMethod('popup', ["destroy"]);
         }
     );
   }

  select(event, detail, target) {
    // <type>-<id>
    var id = target.dataset["id"].split("-");
    router.go("$path.view", {"type": id[0], "id": id[1]});
  }

  get capitalize => new Capitalize();
}