part of nuxeo_client;

/**
 * [OperationRegistry] retrieves and caches the available operations per server [Uri].
 */
class OperationRegistry {
  Map<String, String> paths;
  Map<String, Operation> ops;
  Map<String, Operation> chains;

  static Map<Uri, OperationRegistry> _registries = new Map<Uri, OperationRegistry>();

  static Future<OperationRegistry> get(Uri uri, [http.Client client]) {
    if (_registries.containsKey(uri)) {
      return new Future.value(_registries[uri]);
    } else {
      var request = client.get(uri)..headers.set("Accept", CTYPE_AUTOMATION);
      return request.send()
          .then((http.Response response) {
            var body = response.body,
                json = JSON.decode(body);
            _registries[uri] = new OperationRegistry._fromJSON(json);
            return _registries[uri];
          })
          .catchError((e) {
            throw new http.ClientException(e.toString());
          });
    }
  }

  OperationRegistry._internal(this.paths, this.ops, this.chains);

  factory OperationRegistry._fromJSON(Map<String, Object> json) {

    var paths = json["paths"];

    var ops = {};
    (json["operations"] as List).forEach((json) {
      var op = new Operation.fromJSON(json);
      ops[op.id] = op;
    });

    var chains = {};

    return new OperationRegistry._internal(paths, ops, chains);
  }

  getPath(String key) => paths[key];

  /// Get an [Operation] with the given id.
  Operation operator[](String key) => ops.containsKey(key) ? ops[key] : chains[key];
}