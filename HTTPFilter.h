#import <Foundation/Foundation.h>

@protocol HTTPFilter <NSObject>
@optional 
- (NSURLRequest *)filteredRequest:(NSURLRequest *)request;
- (NSURLResponse *)filteredResponse:(NSURLResponse *)response;
- (NSData *)filteredData:(NSData *)data response:(NSURLResponse *)response;
@end

@interface HTTPFilters : NSObject <HTTPFilter>
+ (HTTPFilters *)default;
- (void)registerFilter:(id<HTTPFilter>)filter;
@end
