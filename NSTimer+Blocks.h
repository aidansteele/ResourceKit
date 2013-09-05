#import <Foundation/Foundation.h>

@interface NSTimer (Blocks)
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)timerInterval repeats:(BOOL)repeats action:(void (^)(NSTimer *sender))action;
@end
