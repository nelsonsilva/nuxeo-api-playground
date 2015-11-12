part of nuxeo_client;

class Login {
  String username;
  bool isAdministrator;
  List<String> groups;

  Login._internal(json) :
    username = json["username"],
    isAdministrator = json["isAdministrator"],
    groups = json["groups"];

  factory Login.fromJSON(json) => new Login._internal(json);
}