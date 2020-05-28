#import "LuavmPlugin.h"
#import "Luavm.h"

@implementation LuavmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"com.github.tgarm.luavm"
            binaryMessenger:[registrar messenger]];
  LuavmPlugin* instance = [[LuavmPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"open" isEqualToString:call.method]) {
      NSNumber *res = [Luavm.inst open];
      result(res);
  } else if([@"close" isEqualToString:call.method]){
      int idx = [call.arguments intValue];
      NSNumber *res = [Luavm.inst close:idx];
      result(res);
  } else if([@"eval" isEqualToString:call.method]){
      NSDictionary *args = (NSDictionary *)call.arguments;
      int idx = [[args objectForKey:@"id"] intValue];
      NSString *code = [args objectForKey:@"code"];
      NSArray *res = [Luavm.inst eval:idx withCode:code];
      result(res);
  }else{
    result(FlutterMethodNotImplemented);
  }
}

@end
