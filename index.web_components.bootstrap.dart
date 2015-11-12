import 'package:initialize/src/static_loader.dart';
import 'package:initialize/initialize.dart';
import 'index.bootstrap.dart' as i0;
import 'package:polymer_interop/polymer_interop.dart' as i1;
import 'package:web_components/html_import_annotation.dart' as i2;
import 'package:polymer/polymer.dart' as i3;
import 'package:nuxeo_api_playground/components/nx_connection.dart' as i4;
import 'package:nuxeo_api_playground/components/tree/tree_node.dart' as i5;
import 'package:nuxeo_api_playground/components/tree/tree.dart' as i6;
import 'package:nuxeo_api_playground/components/nx_xpath.dart' as i7;
import 'package:nuxeo_api_playground/components/nx_widget.dart' as i8;
import 'package:nuxeo_api_playground/components/nx_batch.dart' as i9;
import 'package:nuxeo_api_playground/components/nx_batch_reference.dart' as i10;
import 'package:nuxeo_api_playground/components/nx_batch_upload.dart' as i11;
import 'package:nuxeo_api_playground/components/nx_content_enrichers.dart'
    as i12;
import 'package:nuxeo_api_playground/components/nx_resource_endpoints.dart'
    as i13;
import 'package:nuxeo_api_playground/components/nx_web_adapters.dart' as i14;
import 'package:nuxeo_api_playground/components/nx_request_monitor.dart' as i15;
import 'package:nuxeo_api_playground/components/nx_request_options.dart' as i16;
import 'package:nuxeo_api_playground/components/ui_sidebar.dart' as i17;
import 'package:nuxeo_api_playground/components/nx_repository_browser.dart'
    as i18;
import 'package:nuxeo_api_playground/components/nx_schema.dart' as i19;
import 'package:nuxeo_api_playground/components/nx_structures_browser.dart'
    as i20;
import 'package:nuxeo_api_playground/components/nx_operation.dart' as i21;
import 'package:nuxeo_api_playground/components/nx_command_endpoints.dart'
    as i22;
import 'package:nuxeo_api_playground/app.dart' as i23;

main() {
  initializers.addAll([
    new InitEntry(const i3.CustomTag(i4.NXConnection.TAG), i4.NXConnection),
    new InitEntry(const i3.CustomTag('nx-tree-node'), i5.TreeNode),
    new InitEntry(const i3.CustomTag('nx-tree'), i6.Tree),
    new InitEntry(const i3.CustomTag('nx-xpath'), i7.NXXPath),
    new InitEntry(const i3.CustomTag('nx-widget'), i8.NXWidget),
    new InitEntry(const i3.CustomTag(i9.NXBatch.TAG), i9.NXBatch),
    new InitEntry(
        const i3.CustomTag('nx-batch-reference'), i10.NXBatchReference),
    new InitEntry(const i3.CustomTag(i11.NXBatchUpload.TAG), i11.NXBatchUpload),
    new InitEntry(
        const i3.CustomTag('nx-content-enrichers'), i12.NXContentEnrichers),
    new InitEntry(const i3.CustomTag(i13.NXResourceEndpoints.TAG),
        i13.NXResourceEndpoints),
    new InitEntry(const i3.CustomTag('nx-web-adapters'), i14.NXWebAdapters),
    new InitEntry(
        const i3.CustomTag('nx-request-monitor'), i15.NXRequestMonitor),
    new InitEntry(
        const i3.CustomTag('nx-request-options'), i16.NXRequestOptions),
    new InitEntry(const i3.CustomTag('ui-sidebar'), i17.UISidebar),
    new InitEntry(const i3.CustomTag(i18.NXRepositoryBrowser.TAG),
        i18.NXRepositoryBrowser),
    new InitEntry(const i3.CustomTag('nx-schema'), i19.NXSchema),
    new InitEntry(const i3.CustomTag(i20.NXStructuresBrowser.TAG),
        i20.NXStructuresBrowser),
    new InitEntry(const i3.CustomTag('nx-operation'), i21.NXOperation),
    new InitEntry(
        const i3.CustomTag(i22.NXCommandEndpoints.TAG), i22.NXCommandEndpoints),
    new InitEntry(const i3.CustomTag('nx-sandbox-app'), i23.NXSandboxApp),
  ]);

  return i0.main();
}
