#include "include/apphud_plus/apphud_plus_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "apphud_plus_plugin.h"

void ApphudPlusPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  apphud_plus::ApphudPlusPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
