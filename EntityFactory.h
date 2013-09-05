#import <Foundation/Foundation.h>

@class Resource;

@protocol EntityFactory
- (NSString *)stringForKey:(NSString *)key;
- (NSNumber *)numberForKey:(NSString *)key;
- (NSDate *)dateForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (Resource *)resourceForKey:(NSString *)key;
- (id)entityForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key; // todo: use with caution
@end

@interface EntityFactory : NSObject <EntityFactory>
+ (void)registerClass:(Class)class forType:(NSString *)type;
- (id)initWithBaseURL:(NSURL *)baseURL;
- (id)entityWithDocument:(NSDictionary *)document error:(NSError **)error;
- (NSURL *)baseURL;
@end
