library nx_batch_upload;

import 'dart:async' show Future;
import 'dart:html';

import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:nuxeo_client/http.dart' as http;
import 'package:polymer/polymer.dart';

import 'ui_module.dart';
import 'semantic.dart';

/// [Batch] holds information about files uploaded in a batch
class Batch {
  String id;
  List filenames;
  Batch(List<nuxeo.Upload> uploads) {
    id = uploads[0].batchId;
    filenames = toObservable(uploads.map((u) => u.file.filename));
  }
}

@CustomTag(NXBatchUpload.TAG)
class NXBatchUpload extends NXModule with SemanticUI {

  static const String TAG = "nx-batch-upload";

  String title = "Batch Upload",
         icon = "batch_upload.png",
         description = "Create batches by uploading any number of files. These batches can later be referenced in Resource endpoints methods by clicking on the “Reference a batch” button",
         action = "Upload";

  nuxeo.AutomationUploader _uploader;

  @observable String batchId;
  @observable List<http.Blob> blobs = toObservable([]);

  final List batches = toObservable([]);

  factory NXBatchUpload() => new Element.tag(TAG);

  NXBatchUpload.created() : super.created() {

  }

  enteredView() {
    super.enteredView();
  }

  @override
  onConnect() {
    _newBatchUpload();
  }

  @override
  void setupRoutes(Route route) {
  }

  upload(_) {
    Future.wait(blobs.map((blob) => _uploader.uploadFile(blob)))
    .then((uploads) {
      batches.add(new Batch(uploads));
      _newBatchUpload();
    });
  }

  _newBatchUpload() {
    _uploader = NX.createUploader(uploadTimeout: new Duration(minutes: 20));
    batchId = _uploader.batchId;
    blobs.clear();
  }
}