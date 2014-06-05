library nx_batch_upload;

import 'dart:async' show Future;
import 'dart:html';

import 'package:nuxeo_client/browser_client.dart' as nuxeo;
import 'package:nuxeo_client/http.dart' as http;
import 'package:polymer/polymer.dart';

import 'nx_batch_reference.dart';
import 'ui_module.dart';
import 'semantic.dart';


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
      var batchId = uploads[0].batchId;
      ($["batches"] as NXBatchReference).addBatch(batchId);
      _newBatchUpload();
    });
  }

  _newBatchUpload() {
    _uploader = NX.createUploader(uploadTimeout: new Duration(minutes: 20));
    batchId = _uploader.batchId;
    blobs.clear();
  }
}