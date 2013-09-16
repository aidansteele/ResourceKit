#import "Resource.h"
#import "HTTPRequest.h"
#import "EntityFactory.h"
#import "NSString+Gsub.h"
#import "NSDictionary+Functional.h"

@interface Resource ()
@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSURL *baseURL;
@end

@implementation Resource

- (id)initWithDocument:(NSDictionary *)document baseURL:(NSURL *)baseURL
{
  if (!document) return nil;
  return [self initWithHref:document[@":href"] type:document[@":type"] baseURL:baseURL];
}

- (id)initWithHref:(NSString *)href type:(NSString *)type baseURL:(NSURL *)baseURL
{
  if ((self = [super init]))
  {
    [self setHref:href];
    [self setType:type];
    [self setBaseURL:baseURL];
  }
  
  return self;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (NSURL *)resolvedURL;
{
  return [[NSURL alloc] initWithString:[self href] relativeToURL:[self baseURL]];
}

- (BOOL)isEqual:(id)object;
{
  if (![object isKindOfClass:[Resource class]]) return NO;
  Resource *other = object;

  return [[self href] isEqual:[other href]] && [[self type] isEqual:[other type]];
}

- (NSUInteger)hash;
{
  return [[self href] hash] ^ [[self type] hash];
}

- (Resource *)resourceWithParameterSubstitution:(NSString *(^)(NSString *))substitution
{
  NSError *error = nil;

  NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"\\{([^{]+)\\}" options:0 error:&error];
  NSString *new_href = [[self href] gsub:regexp withMatchTransformation:^NSString *(NSString *element) {
    NSString *parameter_name = [element substringWithRange:NSMakeRange(1, [element length] - 2)];
    NSString *raw = substitution(parameter_name);
    NSString *escaped = [raw stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return escaped;
  }];

  return [[Resource alloc] initWithHref:new_href type:[self type] baseURL:[self baseURL]];
}

- (void (^)(NSData *, NSHTTPURLResponse *))requestHandlerWithSuccess:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure;
{
  return ^(NSData *data, NSHTTPURLResponse *response) {
    NSError *error = nil;
    NSDictionary *document = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (document)
    {
      EntityFactory *factory = [[EntityFactory alloc] initWithBaseURL:[response URL]];
      id loaded_object = [factory entityWithDocument:document error:&error];
      if (loaded_object && success)
      {
        success(loaded_object);
      }
      else if (failure)
      {
        failure(error);
      }
    }
    else if (failure)
    {
      failure(error);
    }
  };
}

- (block_t)loadWithSuccess:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure policy:(NSURLRequestCachePolicy)policy;
{
  HTTPRequest *request = [[HTTPRequest alloc] initWithResource:self policy:policy];
  [request setFailure:failure];
  [request setSuccess:[self requestHandlerWithSuccess:success failure:failure]];
  [request setFastTrackCache:policy != NSURLRequestReloadIgnoringLocalCacheData];
  [request start];
  
  return ^{
    [request cancel];
  };
}

- (block_t)loadWithSuccess:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure;
{
  return [self loadWithSuccess:success failure:failure policy:NSURLRequestUseProtocolCachePolicy];
}

- (block_t)post:(NSDictionary *)dictionary format:(ResourcePOSTFormat)format success:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure;
{
  NSData *data = nil;
  NSString *content_type = nil;

  switch (format)
  {
    default:
    case ResourcePOSTFormatFormURLEncoded:
    {
      content_type = @"application/x-www-form-urlencoded";
      NSArray *pairs = [dictionary map:^id(id key, id value) {
        NSString *enc_value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSString stringWithFormat:@"%@=%@", key, enc_value];
      }];
      NSString *query = [pairs componentsJoinedByString:@"&"];
      data = [query dataUsingEncoding:NSUTF8StringEncoding];
      break;
    }
    case ResourcePOSTFormatJSON:
    {
      content_type = @"application/json";
      data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
      break;
    }
  }

  HTTPRequest *request = [[HTTPRequest alloc] initWithResource:self policy:NSURLRequestUseProtocolCachePolicy];
  [request setSuccess:[self requestHandlerWithSuccess:success failure:failure]];
  [request setPOSTBody:data contentType:content_type];
  [request setFailure:failure];
  [request start];

  return ^{
    [request cancel];
  };
}

@end
