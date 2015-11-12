library nuxeo_client_browser;

import 'client.dart' as nx;
export 'client.dart';
import 'http/client.dart' as http;

class Client extends nx.Client {

  Client({
    String url : "http://localhost:8080/nuxeo",
    String username : nx.DEFAULT.USERNAME,
    String password : nx.DEFAULT.PASSWORD,
    Duration timeout : nx.DEFAULT.TIMEOUT,
    List schemas : nx.DEFAULT.SCHEMAS,
    String repository : nx.DEFAULT.REPOSITORY,
    Map headers}) :
    super(
        new http.Client(username: username, password: password, url: url),
        timeout: timeout, schemas: schemas, repositoryName: repository, headers: headers);

}

