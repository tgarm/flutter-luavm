#import <Flutter/Flutter.h>

@interface Luavm : NSObject
+ (Luavm *)inst;
- (NSNumber *) open;
- (NSNumber *) close:(int)idx;
- (NSArray *)eval:(int)idx withCode:(NSString *)code;
@end
