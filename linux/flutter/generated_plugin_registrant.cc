//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <file_selector_linux/file_selector_plugin.h>
#include <modal_progress_hud_nsn/modal_progress_hud_nsn_plugin.h>
#include <webview_universal/webview_universal_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) file_selector_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "FileSelectorPlugin");
  file_selector_plugin_register_with_registrar(file_selector_linux_registrar);
  g_autoptr(FlPluginRegistrar) modal_progress_hud_nsn_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ModalProgressHudNsnPlugin");
  modal_progress_hud_nsn_plugin_register_with_registrar(modal_progress_hud_nsn_registrar);
  g_autoptr(FlPluginRegistrar) webview_universal_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WebviewUniversalPlugin");
  webview_universal_plugin_register_with_registrar(webview_universal_registrar);
}
