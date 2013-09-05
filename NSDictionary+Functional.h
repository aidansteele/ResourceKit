//
// Created by Aidan Steele on 5/09/13.
// Copyright (c) 2013 Kathmandu. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface NSDictionary (Functional)
- (NSArray *)map:(id (^)(id key, id value))action;
- (NSDictionary *)transform:(id (^)(id *key, id value))action;
@end