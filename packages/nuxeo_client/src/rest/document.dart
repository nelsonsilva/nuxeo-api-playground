part of nuxeo_rest_client;

@proxy
class RemoteDocument implements nx.Document {

  nx.Client nuxeo;
  nx.Document doc;
  List _dirtyFields = [];

  RemoteDocument.wrap(this.doc, this.nuxeo);

  update(Map properties) {
    properties.forEach((k, v) {
      doc.properties[k] = v;
      _dirtyFields.add(k);
    });
  }

  get dirtyFields {
    var dirty = {};
    _dirtyFields.forEach((f) {
      dirty[f] = doc.properties[f];
    });
    return dirty;
  }

  get changeSet => new ChangeSet(doc, dirtyFields);

  save() => nuxeo.doc(doc.uid).update(changeSet.toMap());

  noSuchMethod(Invocation invocation) => reflect(doc).delegate(invocation);
}

class ChangeSet {
  final String entityType;
  final String repository;
  final String uid;
  final Map properties;

  ChangeSet(nx.Document doc, [Map dirtyFields]) :
    entityType = "document",
    repository = doc.repository,
    uid = doc.uid,
    properties = dirtyFields;

  toMap() => {
    "entity-type": entityType,
    "repository": repository,
    "uid": uid,
    "properties": properties
  };
}