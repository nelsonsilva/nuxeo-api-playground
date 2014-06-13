library nx_batch_reference;

import 'package:polymer/polymer.dart';
import 'package:nuxeo_api_playground/cookies.dart';
import 'nx_batch.dart';
import 'ui_module.dart';

@CustomTag("nx-batch-reference")
class NXBatchReference extends NXElement {

  static const NX_BATCHES_COOKIE = "Nuxeo-Batches";

  final List batches = toObservable([]);

  @published bool readonly = false;
  @published NXBatch selected;

  NXBatchReference.created() : super.created() {

  }

  onConnect() {
    _updateBatches();
  }

  addBatch(String batchId) {
    if (!batches.contains(batchId)) {
      batches.add(batchId);
      // Wait for the nx-batch node to be added
      async((_) {
         // Fetch updated batch info from the server
         var batch = _getBatch(batchId);
         batch.fetch()
         .catchError((_) {
           batches.remove(batchId);
           batch.remove();
          })
        . then((_) {
           _updateCookie();
          });

      });
    }
  }

  select(event, detail, target) {
    selected = target;
    return false;
  }

  delete(event, detail, target) {
    var batchId = target.dataset["id"];
    _getBatch(batchId)
     .delete()
    .then((_) {
      batches.remove(batchId);
      _updateCookie();
    });
  }

  NXBatch _getBatch(batchId) =>
      shadowRoot.querySelectorAll(NXBatch.TAG)
      .firstWhere((b) => b.batchId == batchId, orElse: () => null);

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

  _updateCookie() {
    cookies[NX_BATCHES_COOKIE] = batches.join(",");
  }
}