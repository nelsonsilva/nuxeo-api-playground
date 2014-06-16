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

class StructuresBrowser extends Module {
  String title = "Data Structures",
         icon = "data_structure.png",
         description = "Browse all the available definitions of types, schemas and properties held by a document.",
         action = "Browse",
         tag = NXStructuresBrowser.TAG;

  @observable var selectedType;
  @observable var selectedId;

  @override
   void setupRoutes(Route route) {
     route.addRoute(
         name: 'view',
         path: '/:type/:id',
         enter: (e) {
           selectedType = e.parameters['type'];
           selectedId =  e.parameters['id'];
         }
     );
   }
}

@CustomTag(NXStructuresBrowser.TAG)
class NXStructuresBrowser extends NXModule with SemanticUI, SearchFilter {

  static const String TAG = "nx-structures-browser";

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

  @observable var selectedItem;

  @observable String get selectedType => (module as StructuresBrowser).selectedType;
  @observable String get selectedId => (module as StructuresBrowser).selectedId;

  factory NXStructuresBrowser() => new Element.tag(TAG);

  yuml.DiagramGenerator _diagram;

  NXStructuresBrowser.created() : super.created() {
  }

  @observable String currentItemDiagram;

  @override
  onConnect() {

    Future.wait([

    // Schemas
    NX.config.schemas().then((response) {
      schemas
        ..clear()
        ..addAll(
            JSON.decode(response.body).map((s)
                => new nuxeo.Schema.fromJSON(s)));
    }),

    // Facets
    NX.config.facets().then((response) {
      facets
      ..clear()
      ..addAll(
          JSON.decode(response.body).map((s)
              => new nuxeo.Facet.fromJSON(s)));
    }),

    // Doctypes
    NX.config.types().then((response) {
      doctypes.clear();

      JSON.decode(response.body)["doctypes"].forEach((k, v) {
        doctypes.add(new nuxeo.Doctype(k,
            parent: v["parent"],
            schemas: v["schemas"],
            facets: v["facets"]));
      });
    })])

    .then((_) {

      async((_) { // Setup the accordion
        accordion(".ui.accordion");
      });

      // Setup the diagram generator
      _diagram = new yuml.DiagramGenerator(schemas: schemas, facets: facets, doctypes: doctypes);

      // Check for a selected item
      updateSelection();
    })
    .catchError((e) {
      connection.alerts.add(
        new Alert.error("Please check the Nuxeo URL and try connecting again.")
      );
      return false;
    });

  }

  @ObserveProperty("module.selectedId")
  void updateSelection() {
    selectedItem = null;
    if (selectedId != null && items[selectedType].isNotEmpty) {
      selectedItem = items[selectedType].where((d) => d.name == selectedId).first;
    }
    _updateDiagram();
  }

  void _updateDiagram() {
    currentItemDiagram = null;
    if (_diagram != null && selectedItem != null) {
      // Update the UI
      if (selectedItem is nuxeo.Doctype) {
        currentItemDiagram = _diagram.generateForDoctype(selectedItem.name);
      } else if (selectedItem is nuxeo.Facet) {
        currentItemDiagram = _diagram.generateForFacet(selectedItem.name);
      } else if (selectedItem is nuxeo.Schema) {
        currentItemDiagram = _diagram.generateForSchema(selectedItem.name);
      }
    }
  }

  showDiagram() {
    var options = "top=0,left=0,width=${window.screen.width},height=${window.screen.height}";
    window.open(currentItemDiagram, selectedItem.name);
  }

  searchFilterChanged() {
    async((_) { accordion(".ui.accordion"); });
  }

  goRoot() {
    (module as StructuresBrowser).selectedType = (module as StructuresBrowser).selectedId = selectedItem = null;
    super.goRoot();
  }


  select(event, detail, target) {
    // <type>-<id>
    var id = target.dataset["id"].split("-");
    router.go("$path.view", {"type": id[0], "id": id[1]});
  }

  get capitalize => new Capitalize();
}