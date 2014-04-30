/// Swagger
library swagger;

/// [Listing]
class Listing {
  String apiVersion, basePath, resourcePath;
  List<Resource> resources;

  Listing();

  factory Listing.fromJSON(Map json) =>
      new Listing()
      ..apiVersion = json["apiVersion"]
      ..basePath = json["basePath"]
      ..resourcePath = json["resourcePath"]
      ..resources = json["apis"].map((j) => new Resource.fromJSON(j)).toList();
}

/// [Resource]
class Resource {

  String path,
         description;
  List<Operation> operations;

  Resource();

  factory Resource.fromJSON(Map json) =>
    new Resource()
    ..path = json["path"]
    ..description = json["description"]
    ..operations = json["operations"].map((j) => new Operation.fromJSON(j)).toList();
}

/// [Operation]
class Operation {
  String method,
         name,
         type,
         summary,
         notes;
  List<Parameter> parameters;

  Operation._();

  factory Operation.fromJSON(Map json) =>
      new Operation._()
      ..method = json["method"]
      ..name = json["nickname"]
      ..type = json["type"]
      ..summary = json["summary"]
      ..notes = json["notes"]
      ..parameters = json["parameters"].map((j) => new Parameter.fromJSON(j)).toList();
}

/// [Parameter]
class Parameter {

  String name,
         type,
         description,
         dataType;
  bool required;

  Parameter._();

  factory Parameter.fromJSON(Map json) =>
      new Parameter._()
      ..name = json["name"]
      ..type = json["paramType"]
      ..dataType = json["dataType"]
      ..description = json["description"]
      ..required = json["required"] == "true";

  bool get isPathParam => type == "path";
}