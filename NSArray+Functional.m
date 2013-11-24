#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray *)map:(id (^)(id, NSUInteger))action
{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
  
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    id mapped = action(obj, idx);
    if (mapped) [array addObject:mapped];
  }];
  
  return array;
}

- (NSArray *)pick:(BOOL (^)(id item, NSUInteger index))action;
{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];

  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if (action(obj, idx)) [array addObject:obj];
  }];

  return array;
}

- (NSDictionary *)group:(id (^)(id item, NSUInteger index))action;
{
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    id key = action(obj, idx);
    NSMutableArray *array = [dictionary objectForKey:key];
    if (!array)
    {
      array = [NSMutableArray array];
      [dictionary setObject:array forKey:key];
    }
    if (obj) [array addObject:obj];
  }];

  return dictionary;
}

- (NSArray *)flatten;
{
  NSMutableArray *flat = [NSMutableArray arrayWithCapacity:2*[self count]];
  for (NSArray *arr in self) [flat addObjectsFromArray:arr];
  return flat;
}

@end
