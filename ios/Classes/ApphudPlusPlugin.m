#import "ApphudPlusPlugin.h"
#if __has_include(<apphud_plus/apphud_plus-Swift.h>)
#import <apphud_plus/apphud_plus-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "apphud_plus-Swift.h"
#endif

@implementation ApphudPlusPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftApphudPlusPlugin registerWithRegistrar:registrar];
}
@end
