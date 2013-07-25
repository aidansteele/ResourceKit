#import "NSString+Gsub.h"

@implementation NSString (Gsub)

- (NSString *)gsub:(NSRegularExpression *)regexp withMatchTransformation:(NSString *(^)(NSString *element))block
{
  NSMutableString *mutated = [self mutableCopy];

  NSInteger offset = 0; // keeps track of range changes in the string due to replacements.
  for (NSTextCheckingResult *result in [regexp matchesInString:self options:0 range:NSMakeRange(0, [self length])])
  {
    NSRange range = [result range];
    range.location += offset;

    NSString *match = [regexp replacementStringForResult:result inString:mutated offset:offset template:@"$0"];

    NSString *replacement = block(match) ?: match;
    [mutated replaceCharactersInRange:range withString:replacement];

    offset += ([replacement length] - range.length);
  }

  return [mutated copy];
}

@end