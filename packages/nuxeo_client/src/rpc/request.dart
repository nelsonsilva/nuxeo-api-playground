part of nuxeo_automation_client;

/**
 * [OperationRequest] wraps an [Operation] call.
 * This class implements the [call] method so it can be invoked as a [Function].
 * Tipically this is called through the [OperationRegistry].
 */
class OperationRequest extends nx.BaseRequest {

  static final Logger LOG = new Logger("nuxeo.client.request");

  String id;
  Uri _opUri;
  Map<String, Object> _params = {};
  var _input;
  Map<String, String> _context  = {};
  bool _voidOperation = false;

  nx.BatchUploader _batchUploader;

  OperationRequest(this.id, Uri uri, nx.Client client) : super(uri, client) {
    _opUri = Uri.parse("$uri/$id");
  }

  Future<nx.Operation> get op => nx.OperationRegistry.get(uri, httpClient).then((registry) => registry[id]);

  // Fluent API
  OperationRequest params(Map params) => this.._params.addAll(params);
  OperationRequest param(String name, value) => this.._params[name] = value;
  OperationRequest context(Map context) => this.._context.addAll(context);
  OperationRequest input(input) => this.._input = input;
  OperationRequest voidOperation(voidOperation) => this.._voidOperation = voidOperation;

  bool get isMultipart => (_input is http.Blob) || (_input is List && _input.isNotEmpty && _input[0] is http.Blob);

  /// Executes the request.
  /// Returns a [Future]
  /// Throws [ClientException]
  Future<http.Response> execute([arguments]) => op.then((nx.Operation op) {

      if (op == null) {
        throw new ArgumentError("No such operation: $id");
      }

      // Set the automation parameters
      var data = {};
      if (_params != null) data["params"] = _params;
      if (_input != null && !isMultipart) data["input"] = _input;
      if (_context != null) data["context"] = _context;

      // Check the parameters
      data["params"].forEach((key, value) {
        var param = op[key];
        if (param == null) {
          throw new ArgumentError("No such parameter '$key' for operation ${op.id}.");
        }
      });

      var targetUri = _opUri;

      // Check for batch upload
      if (hasBatchUpload) {
        if (data["params"] == null) {
          data["params"] = {};
        }
        data["params"]["operationId"] = id;
        data["params"]["batchId"] = batchId;
        // Override the target url
        targetUri = Uri.parse("${uri}/batch/execute");
      }

      // Create the request
      request = httpClient.post(targetUri, multipart: isMultipart);

      // Setup the headers
      setRequestHeaders();

      request.headers.set(nx.HEADER_NX_VOIDOP, _voidOperation.toString());

      var json = JSON.encode(data);

      // check for multipart request
      if (isMultipart) {
        var params = new http.Blob(content: json, mimetype: nx.CTYPE_REQUEST_NOCHARSET, filename: "request");
        var formData = new http.MultipartFormData();
        formData.append("request", params);
        var blobs = (_input is List) ? _input : [_input];
        blobs.forEach((http.Blob blob) {
          formData.append(blob.filename, blob);
        });
        requestData = formData;
      } else {
        // Set the content type
        request.headers.set(http.HEADER_CONTENT_TYPE, nx.CTYPE_REQUEST_NOCHARSET);
        requestData = json;
      }

      return request.send(requestData);
  });

  String get batchId => _batchUploader.batchId;
  bool get hasBatchUpload => _batchUploader != null;

  nx.BatchUploader get uploader {
    if (_batchUploader == null) {
      _batchUploader = new nx.BatchUploader(nxClient, uploadTimeout: timeout);
    }
    return _batchUploader;
  }
}