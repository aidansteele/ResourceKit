#import <Foundation/Foundation.h>
#import "EntityFactory.h"

typedef void (^block_t)();

@interface Resource : NSObject <NSCopying>
- (id)initWithHref:(NSString *)href type:(NSString *)type baseURL:(NSURL *)baseURL;
- (id)initWithDocument:(NSDictionary *)document baseURL:(NSURL *)baseURL;
- (NSString *)href;
- (NSString *)type;
- (NSURL *)resolvedURL;
- (Resource *)resourceWithParameterSubstitution:(NSString *(^)(NSString *parameterName))substitution;
- (block_t)loadWithSuccess:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure;
- (block_t)loadWithSuccess:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure policy:(NSURLRequestCachePolicy)policy;
@end
