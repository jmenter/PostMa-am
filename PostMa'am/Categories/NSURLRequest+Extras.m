
#import "NSURLRequest+Extras.h"

@implementation NSURLRequest (Extras)

+ (instancetype)requestWithURL:(NSURL *)url
                    httpMethod:(NSString *)method
                      httpBody:(NSData *)body
                       headers:(NSDictionary <NSString *, NSString*> *)headers;
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = method;
    request.HTTPBody = body;
    request.allHTTPHeaderFields = headers;
    return request.copy;
}

@end
