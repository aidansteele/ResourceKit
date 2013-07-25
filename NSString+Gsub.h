#import <Foundation/Foundation.h>

@interface NSString (Gsub)
- (NSString *)gsub:(NSRegularExpression *)regexp withMatchTransformation:(NSString *(^)(NSString *element))block;
@end