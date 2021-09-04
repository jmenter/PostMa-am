
@import Foundation;

@interface NSURLRequest (Extras)

/**
 Convenient initializer for a complete http url request.
 */

+ (instancetype)requestWithURL:(NSURL *)url
                    httpMethod:(NSString *)method
                       headers:(NSDictionary <NSString *, NSString*> *)headers;

@end
