#import "HTTPRequest.h"
#import "HTTPFilter.h"
#import "NSString+Gsub.h"

@interface HTTPRequest () <NSURLConnectionDataDelegate>
@property (nonatomic, copy) Resource *resource;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@end

NSString *HTTPRequestErrorDomain = @"HTTPRequestErrorDomain";
static NSString *InternalExpiryTimeKey = @"InternalExpiryTimeKey";

@implementation HTTPRequest

- (id)initWithResource:(Resource *)resource policy:(NSURLRequestCachePolicy)policy;
{
  if ((self = [super init]))
  {
    [self setResource:resource];
    [self setData:[NSMutableData data]];
    
    NSURL *url = [resource resolvedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:policy timeoutInterval:0];
    NSURLRequest *filtered = [[HTTPFilters default] filteredRequest:request];
    [self setRequest:filtered];

    [self setConnection:[[NSURLConnection alloc] initWithRequest:filtered delegate:self startImmediately:NO]];
  }
  
  return self;
}

- (void)setPOSTBody:(NSData *)body contentType:(NSString *)contentType;
{
  NSURL *url = [[self resource] resolvedURL];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:body];

  NSURLRequest *filtered = [[HTTPFilters default] filteredRequest:request];
  [self setRequest:filtered];
  
  [self setConnection:[[NSURLConnection alloc] initWithRequest:filtered delegate:self startImmediately:NO]];
}

- (void)start
{
  NSCachedURLResponse *cached = [[NSURLCache sharedURLCache] cachedResponseForRequest:[[self connection] currentRequest]];
  NSHTTPURLResponse *response = (NSHTTPURLResponse *)[cached response];
  NSData *data = [cached data];

  NSDate *expiry = [[cached userInfo] objectForKey:InternalExpiryTimeKey];
  BOOL fresh = [expiry compare:[NSDate date]] == NSOrderedDescending;

  if ([self success] && [self fastTrackCache] && response && data && fresh)
  {
    NSData *filtered_data = [[HTTPFilters default] filteredData:data response:response];
    [self success](filtered_data, response);
  }
  else
  {
    [[self connection] start];
  }
}

- (void)cancel
{
  [[self connection] cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [[self data] appendData:data];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;
{
  if (response) // if we had a redirect
  {
    __unused NSURLResponse *filtered_resp = [[HTTPFilters default] filteredResponse:response];
    return [[HTTPFilters default] filteredRequest:request];
  }
  else
  {
    return request;
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  NSURLResponse *filtered = [[HTTPFilters default] filteredResponse:response];
  [self setResponse:(NSHTTPURLResponse *)filtered];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  if ([self failure]) [self failure](error);
}

- (NSTimeInterval)maxAgeForResponse:(NSHTTPURLResponse *)response;
{
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"max-age=(\\d+)" options:0 error:nil];
  __block NSString *max_age = nil;

  NSString *control_str = [[response allHeaderFields] objectForKey:@"Cache-Control"];
  [control_str gsub:regex withMatchTransformation:^NSString *(NSString *element) {
    max_age = [element substringFromIndex:8];
    return nil;
  }];

  return [max_age doubleValue] ?: 60.;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
{
  NSTimeInterval max_age = [self maxAgeForResponse:(NSHTTPURLResponse *)[cachedResponse response]];
  NSDictionary *info = [NSDictionary dictionaryWithObject:[NSDate dateWithTimeIntervalSinceNow:max_age] forKey:InternalExpiryTimeKey];
  return [[NSCachedURLResponse alloc] initWithResponse:[cachedResponse response] data:[cachedResponse data] userInfo:info storagePolicy:[cachedResponse storagePolicy]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  // todo: why are we getting this delegate method called with status code 405?
  if ([[self response] isKindOfClass:[NSHTTPURLResponse class]] && [[self response] statusCode] / 100 == 4)
  {
    NSError *error = [NSError errorWithDomain:HTTPRequestErrorDomain code:[[self response] statusCode] userInfo:@{}];
    if ([self failure]) [self failure](error);
  }
  else if ([self success])
  {
    NSData *data = [[HTTPFilters default] filteredData:[self data] response:[self response]];
    [self success](data, [self response]);
  }
}

@end
