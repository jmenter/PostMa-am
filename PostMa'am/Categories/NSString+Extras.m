
#import "NSString+Extras.h"

@implementation NSString (Extras)

- (BOOL)hasHTTPPrefix;
{
    return [self hasPrefix:@"http://"] || [self hasPrefix:@"https://"];
}

@end
