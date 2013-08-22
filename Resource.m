#import "Resource.h"
#import "HTTPRequest.h"
#import "EntityFactory.h"
#import "NSString+Gsub.h"

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
    return substitution(parameter_name);
  }];

  return [[Resource alloc] initWithHref:new_href type:[self type] baseURL:[self baseURL]];
}

- (block_t)loadWithSuccess:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure policy:(NSURLRequestCachePolicy)policy;
{
  HTTPRequest *request = [[HTTPRequest alloc] initWithResource:self policy:policy];
  [request setSuccess:^(NSData *data, NSHTTPURLResponse *response) {
    NSError *error = nil;
    NSDictionary *document = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (document)
    {
      EntityFactory *factory = [[EntityFactory alloc] initWithBaseURL:[response URL]];
      id loaded_object = [factory entityWithDocument:document error:&error];
      if (loaded_object)
      {
        success(loaded_object);
      }
      else
      {
        failure(error);
      }
    }
    else
    {
      failure(error);
    }
  }];
  [request setFailure:failure];
  [request start];
  
  return ^{
    [request cancel];
  };
}

- (block_t)loadWithSuccess:(void (^)(id loadedObject))success failure:(void (^)(NSError *error))failure;
{
  return [self loadWithSuccess:success failure:failure policy:NSURLRequestUseProtocolCachePolicy];
}

@end
