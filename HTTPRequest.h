#import <Foundation/Foundation.h>
#import "Resource.h"

@interface HTTPRequest : NSObject
@property (nonatomic, copy) void (^success)(NSData *data, NSHTTPURLResponse *response);
@property (nonatomic, copy) void (^failure)(NSError *error);
@property (nonatomic, assign) BOOL fastTrackCache;
- (id)initWithResource:(Resource *)resource policy:(NSURLRequestCachePolicy)policy;
- (void)setPOSTBody:(NSData *)body contentType:(NSString *)contentType;
- (void)start;
- (void)cancel;
@end
