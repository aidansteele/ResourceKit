#import <Foundation/Foundation.h>

@interface NSArray (Functional)
- (NSArray *)map:(id (^)(id item, NSUInteger index))action;
- (NSArray *)pick:(BOOL (^)(id item, NSUInteger index))action;
- (NSDictionary *)group:(id (^)(id item, NSUInteger index))action;
- (NSArray *)flatten;
@end
