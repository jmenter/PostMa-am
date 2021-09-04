
#import "NSData+Extras.h"

@implementation NSData (Extras)

- (NSString *)stringWithEncoding:(NSStringEncoding)encoding;
{
    return [[NSString alloc] initWithData:self encoding:encoding];
}

@end
