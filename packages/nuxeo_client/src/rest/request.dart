part of nuxeo_rest_client;

class Request extends nx.BaseRequest {

  static final Logger LOG = new Logger("nuxeo.client.request");

  Map methods;
  String _method;

  Map<String, String> _queryParameters = {};

  Request(Uri uri, nx.Client client) : super(uri, client) {
    methods = {
      "GET": httpClient.get,
      "POST": httpClient.post,
      "PUT": httpClient.put,
      "DELETE": httpClient.delete
    };
  }

  Request method(String method) => this.._method = method;

  param(String name, String value) => this.._queryParameters[name] = value;
  
  fetch() => method("GET")();
  create(content) => method("POST")(content);
  update(content) => method("PUT")(content);
  delete() => method("DELETE")();

  execute([body]) {

    // Add the query parameters
    var queryParameters = [];
    _queryParameters.forEach((k, v) {
      queryParameters.add("$k=$v");
    });

    var uri = Uri.parse("${this.uri}${this.uri.hasQuery ? '' : '?'}${queryParameters.join('&')}");

    request = methods[_method](uri);
    setRequestHeaders();

    // Set the content type
    request.headers.set(http.HEADER_CONTENT_TYPE, nx.CTYPE_JSON);

    requestData = body;

    return request.send(requestData);
  }

  handleResponse(response) {
    var obj = super.handleResponse(response);

    if (obj is nx.Document) {
      return new RemoteDocument.wrap(obj, nxClient);
    }

    return obj;
  }

  /// Default adapters

  /// Get the children of a document
  children({int currentPageIndex, int pageSize, int maxResults})
    => _addAdapter("children", queryParams: {
      "currentPageIndex": currentPageIndex,
      "pageSize": pageSize,
      "maxResults" : maxResults
    });

  /// Search for documents
  search({
    String query, String fullText, String orderBy,
    int currentPageIndex, int pageSize, int maxResults})
    => _addAdapter("search", queryParams: {
      "query" : query,
      "fullText": fullText,
      "orderBy": orderBy,
      "currentPageIndex": currentPageIndex,
      "pageSize": pageSize,
      "maxResults": maxResults
    });

  /// Execute a page provider on document
  pp(String name, {int currentPageIndex, int pageSize, int maxResults})
  => _addAdapter("pp", pathParams: [name], queryParams: {
    "currentPageIndex": currentPageIndex,
    "pageSize": pageSize,
    "maxResults" : maxResults
  });

  /// View the ACL of a document
  acl() => _addAdapter("acl");

  /// View the audit trail of a document
  audit() => _addAdapter("audit");

  /// Business object adapter on a document
  bo(nameOrType, [String docName]) {
    var type = (nameOrType is String) ? nameOrType : nx.BusinessAdapter.entityTypeOf(nameOrType).name;

    var pathParams = [type];
    if (docName != null) {
      pathParams.add(docName);
    }
   return _addAdapter("bo", pathParams: pathParams);
  }

  /// Execute an operation or a chain on a document
  op(String name, {Map params})
  => _addAdapter("op", pathParams: [name], queryParams: params);

  /// All method calls with be used as adapters
  noSuchMethod(Invocation invocation) {
    String member = MirrorSystem.getName(invocation.memberName);
    if (invocation.isMethod) {
      _addAdapter(member, pathParams: invocation.positionalArguments, queryParams: invocation.namedArguments);
    }
  }

  _addAdapter(String name, {List<String> pathParams, Map queryParams}) {

    uri = Uri.parse("$uri/@$name");

    if (pathParams != null) {
      var params = pathParams.join(""); // ?!
      uri = Uri.parse("$uri/$params");
    }

    if (queryParams != null) {
      queryParams.forEach((k, v) {
        if (v!= null) {
          _queryParameters[k.toString()] = v.toString();
        }
      });
    }

    return this;
  }


}