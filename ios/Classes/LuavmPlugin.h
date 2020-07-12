#import <Flutter/Flutter.h>

@interface LuavmPlugin : NSObject<FlutterPlugin>
+(NSString *)invokeMethod:(NSString *)method withData:(NSString *)data;
@end
