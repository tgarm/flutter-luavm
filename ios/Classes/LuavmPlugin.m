#import "LuavmPlugin.h"
#import "Luavm.h"

static FlutterMethodChannel *bchannel = nil;
@implementation LuavmPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"com.github.tgarm.luavm"
            binaryMessenger:[registrar messenger]];
  LuavmPlugin* instance = [[LuavmPlugin alloc] init];
  bchannel = [FlutterMethodChannel
      methodChannelWithName:@"com.github.tgarm.luavm/back"
            binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

+ (NSString *)invokeMethod:(NSString *)method withData:(NSString *)data{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __block NSString *res;
    dispatch_async(dispatch_get_main_queue(),^{
        [bchannel invokeMethod:method arguments:data result:^(id result){
            res = result;
            dispatch_semaphore_signal(sem);
        }];
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return res;
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
      NSString *res = [Luavm.inst eval:idx withCode:code withCallback:^(NSArray *ares){
          NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:@"OK" forKey:@"res"];
          [dict setObject:ares forKey:@"data"];
          result([NSDictionary dictionaryWithDictionary:dict]);
      }];
      if(![res isEqualToString:@"OK"]){
          result([NSDictionary dictionaryWithObject:res forKey:@"res"]);
      }
  }else{
    result(FlutterMethodNotImplemented);
  }
}

@end
