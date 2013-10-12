#import "HTTPFilter.h"
#import "NSArray+Functional.h"

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

- (NSURLRequest *)filteredRequest:(NSURLRequest *)request;
{
  __block NSURLRequest *filtered = request;
  
  [[[self filters] pick:^BOOL(id item, NSUInteger index) {
    return [item respondsToSelector:@selector(filteredRequest:)];
  }] enumerateObjectsUsingBlock:^(id<HTTPFilter> obj, NSUInteger idx, BOOL *stop) {
    filtered = [obj filteredRequest:filtered];
  }];
  
  return filtered;
}

- (NSURLResponse *)filteredResponse:(NSURLResponse *)response;
{
  __block NSURLResponse *filtered = response;

  [[[self filters] pick:^BOOL(id item, NSUInteger index) {
    return [item respondsToSelector:@selector(filteredResponse:)];
  }] enumerateObjectsUsingBlock:^(id<HTTPFilter> obj, NSUInteger idx, BOOL *stop) {
    filtered = [obj filteredResponse:filtered];
  }];

  return filtered;
}

- (NSData *)filteredData:(NSData *)data response:(NSURLResponse *)response;
{
  __block NSData *filtered = data;

  [[[self filters] pick:^BOOL(id item, NSUInteger index) {
    return [item respondsToSelector:@selector(filteredData:response:)];
  }] enumerateObjectsUsingBlock:^(id<HTTPFilter> obj, NSUInteger idx, BOOL *stop) {
    filtered = [obj filteredData:filtered response:response];
  }];

  return filtered;
}

@end
