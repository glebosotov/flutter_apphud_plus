//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <apphud_plus/apphud_plus_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) apphud_plus_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "ApphudPlusPlugin");
  apphud_plus_plugin_register_with_registrar(apphud_plus_registrar);
}
