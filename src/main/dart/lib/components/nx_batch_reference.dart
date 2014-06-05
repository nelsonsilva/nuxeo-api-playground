library nx_batch_reference;

import 'dart:async' show Future;
import 'dart:convert' show JSON;
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:polymer/polymer.dart';
import 'package:nuxeo_api_playground/cookies.dart';
import 'ui_module.dart';

/// [Batch] holds information about files uploaded in a batch
class Batch extends Observable {
  String id;
  List filenames;

  Batch(this.id);

  factory Batch.fromJSON(String id, json) {
    return new Batch(id)..filenames = json.map((f) => f["name"]).toList();
  }

  String get asJson {
    var files = [];
    for (var i = 0; i < filenames.length; i++) {
      var file = filenames[i];
      files.add({"upload-batch":"$id", "upload-fileId":"$i"});
    };
    if (files.length == 1) {
      return JSON.encode(files[0]);
    }
    return JSON.encode(files.map((f) => {"file": f}).toList());
  }
}

@CustomTag("nx-batch-reference")
class NXBatchReference extends NXElement {

  static const NX_BATCHES_COOKIE = "Nuxeo-Batches";

  final List batches = toObservable([]);
  @published Batch selected;

  NXBatchReference.created() : super.created() {

  }

  enteredView() {
    super.enteredView();
  }

  onConnect() {
    _updateBatches();
  }

  addBatch(String batchId) {
    _fetchBatch(batchId).then((batch) {
      if (batch != null) {
        batches.add(batch);
        // Update the cookie
        cookies[NX_BATCHES_COOKIE] = batches.map((b) => b.id).join(",");
      }
    });

  }

  select(event, detail, target) {
    selected = batches.where((b) => b.id == target.dataset["id"]).first;
  }

  delete(event, detail, target) {
    var batch = batches.where((b) => b.id == target.dataset["id"]).first;
    //TODO(nfgs): Move this request to the NX client
    NX.httpClient.get(Uri.parse("${connection.nuxeoUrl}/site/automation/batch/drop/${batch.id}"))
    .send()
    .then((response) => batches.remove(batch))
    .catchError((e) => null);
  }

  Future<Batch> _fetchBatch(batchId) =>
      //TODO(nfgs): Move this request to the NX client
      NX.httpClient.get(Uri.parse("${connection.nuxeoUrl}/site/automation/batch/files/$batchId"))
      .send()
      .then((response) {
        var json = JSON.decode(response.body);
        return (json.isNotEmpty) ? new Batch.fromJSON(batchId, json) : null;
      })
      .catchError((e) => null);

  _updateBatches() {
    // Get the batches from the cookie
    String batchIds = cookies[NX_BATCHES_COOKIE];
    // Clear the existing data
    _clearBatches();
    if (batchIds != null) {
      // Fetch all the batches
      batchIds.split(",").forEach((batchId) => addBatch(batchId));
    }
  }

  _clearBatches() {
    batches.clear();
    cookies.remove(NX_BATCHES_COOKIE);
  }
}