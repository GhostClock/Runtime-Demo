//
//  DouBanModel.m
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/15.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import "DouBanModel.h"
#import <objc/runtime.h>


#pragma mark - 可以写成宏

#define encodeCoderWithRuntime(model)\
unsigned int count = 0;\
Ivar *ivars = class_copyIvarList([model class], &count);\
for (int i = 0; i < count; i ++) {\
    Ivar ivar = ivars[i];\
    NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];\
    id value = [aCoder valueForKey:key];\
    [aCoder encodeObject:value forKey:key];\
}\
free(ivars);\

#define initCoderWithRuntime(model)\
self = [super init];\
if (self) {\
    unsigned int count = 0;\
    Ivar *ivars = class_copyIvarList([model class], &count);\
    for (int i = 0; i < count; i ++) {\
        Ivar ivar = ivars[i];\
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];\
        id value = [aDecoder decodeObjectForKey:key];\
        [self setValue:value forKey:key];\
    }\
    free(ivars);\
}\
return self;\

@implementation DouBanModel

//+ (NSDictionary *)arrayContainModelClass{
//    return @{@"subjects" : NSStringFromClass([self class])};
//}



+ (NSDictionary *)modelContainModelClass {
    return @{@"subjects": NSStringFromClass([MovieInfo class])};
}

#pragma mark - 用Runtime实现归档解档
// 存
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([DouBanModel class], &count);
    for (int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        //归档
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(ivars);
}

// 解
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([DouBanModel class], &count);
        for (int i = 0; i < count; i ++) {
            // 取出成员变量
            Ivar ivar = ivars[i];
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            //归档
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
        free(ivars);
    }
    return self;
}

@end


@implementation MovieInfo

#pragma mark - 模型里面套模型的归档
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([MovieInfo class], &count);
    for (int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        //归档
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
    free(ivars);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    initCoderWithRuntime(MovieInfo);
}

@end
