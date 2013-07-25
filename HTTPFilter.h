#import <Foundation/Foundation.h>

@protocol HTTPFilter
@optional 
- (NSURLRequest *)filteredRequest:(NSURLRequest *)request;
- (NSURLResponse *)filteredResponse:(NSURLResponse *)response;
@end

@interface HTTPFilters : NSObject <HTTPFilter>
+ (HTTPFilters *)default;
- (void)registerFilter:(id<HTTPFilter>)filter;
@end
