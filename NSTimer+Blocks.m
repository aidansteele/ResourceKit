#import "NSTimer+Blocks.h"

@interface TimerHelper : NSObject
@property (nonatomic, copy) void (^action)(NSTimer *);
- (id)initWithAction:(void (^)(NSTimer *))action;
- (void)fired:(NSTimer *)sender;
@end

@implementation TimerHelper

- (id)initWithAction:(void (^)(NSTimer *))action;
{
  NSParameterAssert(NULL != action);
  if (self = [super init])
  {
    [self setAction:action];
  }

  return self;
}

- (void)fired:(NSTimer *)sender;
{
  _action(sender);
}

@end

@implementation NSTimer (Blocks)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)timerInterval repeats:(BOOL)repeats action:(void (^)(NSTimer *))action;
{
  TimerHelper *helper = [[TimerHelper alloc] initWithAction:action];
  return [NSTimer scheduledTimerWithTimeInterval:timerInterval target:helper selector:@selector(fired:) userInfo:nil repeats:repeats];
}

@end
