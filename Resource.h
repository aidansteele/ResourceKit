#import <Foundation/Foundation.h>
#import "EntityFactory.h"

typedef void (^block_t)();

typedef enum
{
  ResourcePOSTFormatFormURLEncoded,
  ResourcePOSTFormatJSON,
} ResourcePOSTFormat;

@interface Resource : NSObject <NSCopying, NSCoding>
- (id)initWithHref:(NSString *)href type:(NSString *)type baseURL:(NSURL *)baseURL;
- (id)initWithDocument:(NSDictionary *)document baseURL:(NSURL *)baseURL;
- (NSString *)href;
- (NSString *)type;
- (NSURL *)resolvedURL;
- (Resource *)resourceWithParameterSubstitution:(NSString *(^)(NSString *parameterName))substitution;
- (block_t)loadWithSuccess:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure;
- (block_t)loadWithSuccess:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure policy:(NSURLRequestCachePolicy)policy;
- (block_t)post:(NSDictionary *)dictionary format:(ResourcePOSTFormat)format success:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure;
@end
