#import "HTTPFilter.h"

@interface HTTPFilters ()
@property (nonatomic, strong) NSMutableArray *filters;
@end

@implementation HTTPFilters

+ (HTTPFilters *)default;
{
  static dispatch_once_t once;
  static HTTPFilters *instance;

  dispatch_once(&once, ^{
    instance = [[self alloc] init];
  });
  
  return instance;
}

- (id)init;
{
  if ((self = [super init]))
  {
    [self setFilters:[NSMutableArray array]];
  }

  return self;
}

- (void)registerFilter:(id<HTTPFilter>)filter;
{
  [[self filters] addObject:filter];
}

- (id)filter:(id)orig action:(SEL)selector with:(id)arg;
{
  id filtered = orig;

  for (id<HTTPFilter> filter in [self filters])
  {
    if (![filter respondsToSelector:selector]) continue;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    filtered = [filter performSelector:selector withObject:arg];
#pragma clang diagnostic pop
  }

  return filtered;
}

- (NSURLRequest *)filteredRequest:(NSURLRequest *)request;
{
  return [self filter:request action:_cmd with:nil];
}

- (NSURLResponse *)filteredResponse:(NSURLResponse *)response;
{
  return [self filter:response action:_cmd with:nil];
}

- (NSData *)filteredData:(NSData *)data response:(NSURLResponse *)response;
{
  return [self filter:data action:_cmd with:data];
}

@end
