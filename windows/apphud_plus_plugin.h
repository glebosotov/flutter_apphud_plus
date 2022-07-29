#ifndef FLUTTER_PLUGIN_APPHUD_PLUS_PLUGIN_H_
#define FLUTTER_PLUGIN_APPHUD_PLUS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace apphud_plus {

class ApphudPlusPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ApphudPlusPlugin();

  virtual ~ApphudPlusPlugin();

  // Disallow copy and assign.
  ApphudPlusPlugin(const ApphudPlusPlugin&) = delete;
  ApphudPlusPlugin& operator=(const ApphudPlusPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace apphud_plus

#endif  // FLUTTER_PLUGIN_APPHUD_PLUS_PLUGIN_H_
