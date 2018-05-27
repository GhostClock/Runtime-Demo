//
//  RuntimeTest.m
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/15.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import "RuntimeTest.h"
#import <objc/runtime.h>

@implementation RuntimeTest

- (instancetype)initWithLog:(NSString *)log {
    self = [super init];
    if (self) {
        self.log = log;
    }
    return self;
}

// 获取一个类的属性列表
- (void)getPropertyList {
    unsigned int count;
    objc_property_t *propertys = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i ++) {
        objc_property_t property = propertys[i];
        NSLog(@"%s %s\n", property_getName(property), property_getAttributes(property));
    }
    free(propertys);
}

// 获取一个类的方法列表
- (void)getMethodList {
    unsigned int count;
    Method *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i ++) {
        Method method = methods[i];
        NSLog(@"%@ %u \n", NSStringFromSelector(method_getName(method)), method_getNumberOfArguments(method));
    }
    free(methods);
}

// 获取成员变量
- (void)getIvarList {
    unsigned int count;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        NSLog(@"%s %s \n", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    free(ivars);
}

// 获取协议名
- (void)getProtocolList {
    unsigned int count;
    __unsafe_unretained Protocol **protocols = class_copyProtocolList([self class], &count);
    for (int i = 0; i < count; i ++) {
        NSLog(@"%s", protocol_getName(protocols[i]));
    }
    free(protocols);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(printLog1:log2:)) {
        class_addMethod(self, @selector(printLog1:log2:), (IMP)printLog, "v@:@@");
    }
    return [super resolveInstanceMethod:sel];
}

void printLog(id self, SEL _cmd, NSString *log1, NSString *log2) {
    
}

@end
