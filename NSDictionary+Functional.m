//
// Created by Aidan Steele on 5/09/13.
// Copyright (c) 2013 Kathmandu. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSDictionary+Functional.h"


@implementation NSDictionary (Functional)

- (NSArray *)map:(id (^)(id key, id value))action;
{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];

  [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    id item = action(key, obj);
    if (item) [array addObject:item];
  }];

  return array;
}

- (NSDictionary *)transform:(id (^)(id *key, id value))action;
{
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[self count]];

  [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    id key_copy = key; // todo: necessary?
    id new_value = action(&key_copy, obj);
    if (key_copy && new_value) [dictionary setObject:new_value forKey:key_copy];
  }];

  return dictionary;
}

@end