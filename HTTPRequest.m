#import "HTTPRequest.h"
#import "HTTPFilter.h"

@interface HTTPRequest () <NSURLConnectionDataDelegate>
@property (nonatomic, copy) Resource *resource;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@end

@implementation HTTPRequest

- (id)initWithResource:(Resource *)resource
{
  if ((self = [super init]))
  {
    [self setResource:resource];
    [self setData:[NSMutableData data]];
    
    NSURL *url = [resource resolvedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLRequest *filtered = [[HTTPFilters default] filteredRequest:request];
    [self setConnection:[[NSURLConnection alloc] initWithRequest:filtered delegate:self startImmediately:NO]];
  }
  
  return self;
}

- (void)start
{
  [[self connection] start];
}

- (void)cancel
{
  [[self connection] cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [[self data] appendData:data];
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  if ([self success]) [self success]([[self data] copy], [self response]);
}

@end
