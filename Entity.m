#import "Entity.h"

@interface Entity ()
@property (nonatomic, copy) Resource *resource;
@end

@implementation Entity

- (id)initWithFactory:(id <EntityFactory>)factory
{
  if ((self = [super init]))
  {
    [self setResource:[factory resourceForKey:nil]];
  }
  
  return self;
}

- (BOOL)isEqual:(id)object;
{
  if (![object isKindOfClass:[Entity class]]) return NO;
  return [[self resource] isEqual:[object resource]];
}

- (NSUInteger)hash;
{
  return [[self resource] hash];
}

@end
