part of nuxeo_client;

class AutomationUploaderEvent {
  String type;
  AutomationUploaderEvent(this.type);
}

// invoked when a new batch is started
// batchStarted

// invoked when the upload for given file has been started
// uploadStarted : function(fileIndex, file) {

// invoked when the upload for given file has been finished
//uploadFinished : function(fileIndex, file, time) {

// invoked when the progress for given file has changed
//fileUploadProgressUpdated : function(fileIndex, file, newProgress) {

// invoked when the upload speed of given file has changed
//fileUploadSpeedUpdated : function(fileIndex, file, KBperSecond) {

// invoked when all files have been uploaded
//batchFinished : function(batchId) {

class Upload {
  Completer _completer = new Completer();
  http.Blob file;
  int fileIndex;
  DateTime downloadStartTime;
  DateTime currentStart;
  int currentProgress;
  int startData;
  String batchId;
  Duration timeDiff;
  Upload(this.file);
  void complete() {
    var now = new DateTime.now();
    timeDiff = now.difference(downloadStartTime);
    _completer.complete(this);
   }
  Future<Upload> get future => _completer.future;
}

/**
 * [BatchUploader] manages the upload of files in a queue with a target
 * number of concurrent uploads.
 */
class BatchUploader {

  static final LOG = new Logger("nuxeo.automation.uploader");

  Client client;

  StreamController<AutomationUploaderEvent> evtController = new StreamController<AutomationUploaderEvent>();
  Stream<AutomationUploaderEvent> get onBatchStarted => evtController.stream.where((e) => e.type == "batchStarted");

  int numConcurrentUploads;

  // define if upload should be triggered directly
  bool directUpload;

  // update upload speed every second
  int uploadRateRefreshTime;

  Duration uploadTimeout;

  String batchId;
  bool _sendingRequestsInProgress = false;
  Queue<Upload> _uploadStack = new Queue();
  int uploadIdx = 0;
  int _nbUploadInprogress = 0;
  List _completedUploads = [];

  BatchUploader(this.client, {
    this.numConcurrentUploads : 5,
    // define if upload should be triggered directly
    this.directUpload : true,
    // update upload speed every second
    this.uploadRateRefreshTime : 1000,
    this.uploadTimeout,
    this.batchId
  }) {
    if (batchId == null) {
      batchId = "batch-" +
        new DateTime.now().millisecondsSinceEpoch.toString() +
        "-" + new Math.Random().nextInt(100000).toString();
    }
  }

  Future<Upload> uploadFile(cfile) {
    var entry = new Upload(cfile);
    _uploadStack.add(entry);
    if (directUpload && !_sendingRequestsInProgress && _uploadStack.isNotEmpty) {
      uploadFiles();
    }
    return entry.future;
  }

  uploadFiles() {

    if (_nbUploadInprogress >= numConcurrentUploads) {
      _sendingRequestsInProgress = false;
      LOG.info("delaying upload for next file(s) $uploadIdx"
            "+ since there are already $_nbUploadInprogress"
            " active uploads");
      return;
    }

    // this.opts.handler.batchStarted();
    _sendingRequestsInProgress = true;

    while (_uploadStack.isNotEmpty) {

      var upload = _uploadStack.removeFirst();

      // create a new xhr object
      var xhr = client.httpClient.post(Uri.parse("${client._rpcUri}/batch/upload"));

      upload.fileIndex = uploadIdx + 0;
      upload.downloadStartTime = new DateTime.now();
      upload.currentStart = upload.downloadStartTime;
      upload.currentProgress = 0;
      upload.startData = 0;
      upload.batchId = batchId;

      var file = upload.file;

      _nbUploadInprogress++;


      //var upload = xhr.upload;

      // add listeners
      //xhr.upload.onProgress.listen(_progress);

      //if (file.callback) {
      //  upload.callback = file.callback;
      //}

      // The "load" event doesn't work correctly on WebKit (Chrome,
      // Safari),
      // it fires too early, before the server has returned its response.
      // still it is required for Firefox
      //if (navigator.userAgent.indexOf('Firefox') > -1) {
      //  upload.addEventListener("load", function(event) {
      //    log("trigger load");
      //    log(event);
      //    me.load(event.target)
      //  }, false);
      //}

      // on ready state change is not fired in all cases on webkit
      // - on webkit we rely on progress lister to detected upload end
      // - but on Firefox the event we need it
      //xhr.onreadystatechange = (function(xhr) {
      //  return function() {
      //    me.readyStateChange(xhr)
      //  }
      //})(xhr);

      // compute timeout in seconds and integer
      int uploadTimeoutS = (uploadTimeout + new Duration(seconds: 5)).inSeconds;

      LOG.info("starting upload for file $uploadIdx");

      xhr.headers.set("Cache-Control", "no-cache");
      xhr.headers.set("X-Requested-With", "XMLHttpRequest");
      xhr.headers.set("X-File-Name", Uri.encodeComponent(file.filename));
      xhr.headers.set("X-File-Size", file.length.toString());
      xhr.headers.set("X-File-Type", file.mimetype);
      xhr.headers.set("X-Batch-Id", batchId);
      xhr.headers.set("X-File-Idx", uploadIdx.toString());

      xhr.headers.set('Nuxeo-Transaction-Timeout', uploadTimeoutS.toString());
      //xhr.headers.set("Content-Type", "multipart/form-data");

      //this.opts.handler.uploadStarted(uploadIdx, file);
      uploadIdx++;

      xhr.send(file).then((response) {
        load(upload);
      });

      if (_nbUploadInprogress >= numConcurrentUploads) {
        _sendingRequestsInProgress = false;
        LOG.info("delaying upload for next file(s) $uploadIdx"
              "+ since there are already "
              "$_nbUploadInprogress active uploads");
        return;
      }
      _sendingRequestsInProgress = false;
    }

  }
  /*
  readyStateChange : function(xhr) {
    var upload = xhr.upload;
    log("readyStateChange event on file upload " + upload.fileIndex
        + " (state : " + xhr.readyState + ")");
    if (xhr.readyState == 4) {
      if (xhr.status == 200) {
        this.load(upload);
      } else {
        log("Upload failed, status: " + xhr.status);
      }
    }
  },*/

  load(Upload upload) {
    var fileIdx = upload.fileIndex;
    LOG.info("Received loaded event on  file $fileIdx");
    if (!_completedUploads.contains(fileIdx)) {
      _completedUploads.add(fileIdx);
    } else {
      LOG.info("Event already processsed for file $fileIdx, exiting");
      return;
    }

    //this.opts.handler.uploadFinished(upload.fileIndex, upload.file,timeDiff);
    LOG.info("upload of file ${upload.fileIndex} completed");

    upload.complete();

    _nbUploadInprogress--;
    if (!_sendingRequestsInProgress && _uploadStack.isNotEmpty
        && _nbUploadInprogress < numConcurrentUploads) {
      // restart upload
      LOG.info("restart pending uploads");
      uploadFiles();
    } else if (_nbUploadInprogress == 0) {
      //this.opts.handler.batchFinished(this.batchId);
    }
  }

  /*
  _progress : function(event) {
    log(event);
    if (event.lengthComputable) {
      var percentage = Math.round((event.loaded * 100) / event.total);
      if (event.target.currentProgress != percentage) {

        log("progress event on upload of file "
            + event.target.fileIndex + " --> " + percentage + "%");

        event.target.currentProgress = percentage;
        this.opts.handler.fileUploadProgressUpdated(
            event.target.fileIndex, event.target.fileObj,
            event.target.currentProgress);

        var elapsed = new Date().getTime();
        var diffTime = elapsed - event.target.currentStart;
        if (diffTime >= this.opts.handler.uploadRateRefreshTime) {
          var diffData = event.loaded - event.target.startData;
          var speed = diffData / diffTime; // in KB/sec

          this.opts.handler
              .fileUploadSpeedUpdated(event.target.fileIndex,
                  event.target.fileObj, speed);

          event.target.startData = event.loaded;
          event.target.currentStart = elapsed;
        }
        if (event.loaded == event.total) {
          log("file " + event.target.fileIndex
              + " detected upload complete");
          // having all the bytes sent to the server does not mean the
          // server did actually receive everything
          // but since load event is not reliable on Webkit we need
          // this
          // window.setTimeout(function(){load(event.target, opts);},
          // 5000);
        } else {
          log("file " + event.target.fileIndex + " not completed :"
              + event.loaded + "/" + event.total);
        }
      }
    }
  }*/

}