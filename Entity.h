#import <Foundation/Foundation.h>
#import "Resource.h"
#import "EntityFactory.h"

@interface Entity : NSObject
- (id)initWithFactory:(id <EntityFactory>)factory;
- (Resource *)resource;
@end
