#import "EntityFactory.h"
#import "Resource.h"
#import "Entity.h"
#import <objc/runtime.h>

static char kEntityFactoryTypeMapKey;

@interface EntityFactory ()
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSMutableArray *documentStack;
@end

@implementation EntityFactory

+ (void)registerClass:(Class)class forType:(NSString *)type;
{
  NSMutableDictionary *type_map = objc_getAssociatedObject(self, &kEntityFactoryTypeMapKey);
  if (!type_map)
  {
    type_map = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &kEntityFactoryTypeMapKey, type_map, OBJC_ASSOCIATION_RETAIN);
  }

  [type_map setObject:class forKey:type];
}

- (id)initWithBaseURL:(NSURL *)baseURL;
{
  if ((self = [super init]))
  {
    [self setBaseURL:baseURL];
    [self setDocumentStack:[NSMutableArray array]];
  }
  
  return self;
}

- (NSDictionary *)typeMap
{
  return objc_getAssociatedObject([self class], &kEntityFactoryTypeMapKey);
}

- (NSDictionary *)document;
{
  return [[self documentStack] lastObject];
}

- (NSString *)stringForKey:(NSString *)key;
{
  NSString *string = [[self document] valueForKeyPath:key];
  return [string isKindOfClass:[NSString class]] ? string : @"";
}

- (NSNumber *)numberForKey:(NSString *)key;
{
  return [[self document] valueForKeyPath:key] ?: @0;
}

- (NSDate *)dateForKey:(NSString *)key;
{
  NSNumber *epoch_time = [self numberForKey:key];
  return [NSDate dateWithTimeIntervalSince1970:[epoch_time doubleValue]];
}

- (NSArray *)arrayForKey:(NSString *)key;
{
  NSArray *orig = [[self document] valueForKeyPath:key];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:[orig count]];

  for (id item in orig)
  {
    if ([item isKindOfClass:[NSDictionary class]])
    {
      id entity = [self entityWithDocument:item error:nil];
      [array addObject:entity ?: item];
    }
    else
    {
      [array addObject:item];
    }
  }

  return array;
}

- (NSDictionary *)dictionaryForKey:(NSString *)key;
{
  return key ? [[self document] valueForKeyPath:key] : [self document];
}

- (Resource *)resourceForKey:(NSString *)key;
{
  return [[Resource alloc] initWithDocument:[self dictionaryForKey:key] baseURL:[self baseURL]];
}

- (id)entityForKey:(NSString *)key;
{
  return [self entityWithDocument:[self dictionaryForKey:key] error:nil];
}

- (id)entityWithDocument:(NSDictionary *)document error:(NSError *__autoreleasing *)error
{
  Class klass = [[self typeMap] objectForKey:document[@":type"]];
  if (!klass)
  {
    if (error) *error = [NSError errorWithDomain:@"" code:0 userInfo:@{}];
    return nil;
  }

  [[self documentStack] addObject:document];
  id entity = [[klass alloc] initWithFactory:self];
  [[self documentStack] removeLastObject];

  return entity;
}

@end
