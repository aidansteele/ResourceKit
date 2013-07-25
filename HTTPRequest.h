#import <Foundation/Foundation.h>
#import "Resource.h"

@interface HTTPRequest : NSObject
@property (nonatomic, copy) void (^success)(NSData *data, NSHTTPURLResponse *response);
@property (nonatomic, copy) void (^failure)(NSError *error);
- (id)initWithResource:(Resource *)resource;
- (void)start;
- (void)cancel;
@end
