
#import "NSHTTPURLResponse+Extras.h"

@implementation NSHTTPURLResponse (Extras)

- (NSStringEncoding)stringEncoding;
{
    NSString *textEncodingName = self.textEncodingName ?: @"utf8";
    CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)textEncodingName);
    return CFStringConvertEncodingToNSStringEncoding(encoding);
}

@end
