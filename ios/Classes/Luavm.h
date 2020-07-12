#import <Flutter/Flutter.h>

typedef void(^LuavmCallback)(NSArray *);

@interface Luavm : NSObject
+ (Luavm *)inst;
- (NSNumber *) open;
- (NSNumber *) close:(int)idx;
- (NSString *)eval:(int)idx withCode:(NSString *)code withCallback:(LuavmCallback)callback;

@end
