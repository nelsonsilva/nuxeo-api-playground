library nx_batch_upload;

import 'dart:html';
import 'dart:math' as Math;

import 'package:polymer/polymer.dart';

import 'nx_batch.dart';
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

  factory NXBatchUpload() => new Element.tag(TAG);

  NXBatchUpload.created() : super.created() {
    _resetBatch();
  }

  @override
  void setupRoutes(Route route) {
  }

  onUpload(Event event) {
    ($["batches"] as NXBatchReference).addBatch((event.target as NXBatch).batchId);
    _resetBatch();
  }

  void _resetBatch() {
    var batch = shadowRoot.querySelector("nx-batch") as NXBatch;
    batch.batchId = "batch-" +
            new DateTime.now().millisecondsSinceEpoch.toString() +
            "-" + new Math.Random().nextInt(100000).toString();
    batch.reset();
  }
}