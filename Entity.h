#import <Foundation/Foundation.h>
#import "Resource.h"
#import "EntityFactory.h"

@interface Entity : NSObject <NSCoding>
- (id)initWithFactory:(id <EntityFactory>)factory;
- (Resource *)resource;
@end
