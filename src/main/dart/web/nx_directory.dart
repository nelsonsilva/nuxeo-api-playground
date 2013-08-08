import 'model.dart';
import 'package:web_ui/web_ui.dart';

class DirectoryEntry {
  var id, label;
  DirectoryEntry.fromJSON(json) :
    label = json["label"],
    id = json["id"];
  toString() => id;
}

class NXDirectory extends WebComponent {
  String name;

  @observable
  List<DirectoryEntry> entries = toObservable([]);

  inserted() {
    NX.op("Directory.Entries")({"directoryName": name}).then((List list) {
      entries.addAll(list.map((e) => new DirectoryEntry.fromJSON(e)));
    });
  }
}
