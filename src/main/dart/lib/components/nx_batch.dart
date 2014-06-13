library nx_batch;

import 'dart:async' show Future;
import 'dart:convert' show JSON;
import 'dart:html';
import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:nuxeo_client/http.dart' as http;
import 'package:polymer/polymer.dart';
import 'ui_module.dart';

/// [NXBatch] holds information about files uploaded in a batch
@CustomTag(NXBatch.TAG)
class NXBatch extends NXElement {

  static const String TAG = "nx-batch";

  static const String UPLOAD_EVENT = "upload";

  /// The ID of the batch
  @published String batchId;

  /// read only
  @published bool readonly = false;

  // Can only change id before uploading
  @observable bool wasUploaded = false;

  /// List of filenames that belong to this batch
  final List filenames = toObservable([]);

  /// List of Blobs waiting to be uploaded
  final List<http.Blob> blobs = toObservable([]);

  nuxeo.BatchUploader _uploader;

  NXBatch.created() : super.created() {
  }

  /// Delete the batch from the server
  Future delete() =>
    //TODO(nfgs): Move this request to the NX client
    NX.httpClient.get(Uri.parse("${connection.nuxeoUrl}/site/automation/batch/drop/$batchId"))
    .send();

  /// Upload the files to the server
  Future upload(Event e) {
    // create the uploader
    if (_uploader == null) {
      _uploader = new nuxeo.BatchUploader(NX,
            batchId: batchId,
            uploadTimeout: new Duration(minutes: 20));
      // Set the proper index to start uploading files
      _uploader.uploadIdx = filenames.length;
    }

    // Upload the blobs
    return Future.wait(blobs.map((blob) => _uploader.uploadFile(blob)))
    // Clear the blob queue and fetch new info from the server
    .then((_) {
      blobs.clear();
      return fetch();
    })
    .then((_) {
      dispatchEvent(new CustomEvent(UPLOAD_EVENT));
    });
  }

  /// Fetch the files from the server
  Future fetch() {
    wasUploaded = true;
    //TODO(nfgs): Move this request to the NX client
    return NX.httpClient.get(Uri.parse("${connection.nuxeoUrl}/site/automation/batch/files/$batchId"))
    .send()
    .then((response) {
      var json = JSON.decode(response.body);
      if (json.isEmpty) {
        throw new Exception("Batch $batchId does not exist.");
      }
      filenames..clear()..addAll(json.map((f) => f["name"]));
    });
  }

  String get asJson {
    var files = [];
    for (var i = 0; i < filenames.length; i++) {
      var file = filenames[i];
      files.add({"upload-batch":"$batchId", "upload-fileId":"$i"});
    };
    if (files.length == 1) {
      return JSON.encode(files[0]);
    }
    return JSON.encode(files.map((f) => {"file": f}).toList());
  }

}