//
//  NSObject+ModelExtension.m
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/15.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import "NSObject+ModelExtension.h"
#import <objc/runtime.h>

@implementation NSObject (ModelExtension)

+ (instancetype)modelWithDict:(id)dict {
    id obj = [[self alloc] init];
    
    unsigned int count;
    Ivar *ivarList = class_copyIvarList(self, &count);
    for (int i = 0; i < count; i ++) {
        Ivar ivar = ivarList[i];
        
        // 获取成员属性
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        // 处理成员属性名 -> 字典中的key 去掉下划线
        NSString *key = [name substringFromIndex:1];
        
        // 根据成员属性名去字典查找对应的value
        id value = dict[key];
        
        // 二级转换: 如果字典中还有字典，也需要把对应的字典转换成模型
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            // 获取成员变量的类型
            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
            
            // 裁剪类型字符串
            NSRange range = [type rangeOfString:@"\""];
            
            type = [type substringFromIndex:range.location + range.length];
            
            range = [type rangeOfString:@"\""];
            
            type = [type substringFromIndex:range.location];
            
            // 根据字符串类型生成类对象
            Class moduleClass = NSClassFromString(type);
            
            if (moduleClass) {
                value = [moduleClass modelWithDict:value];
            }
        }
        
        // 三级转换: NSArray 中也是字典 把数组中的字典转化成模型
        if ([value isKindOfClass:[NSArray class]]) {
            // 判断对应类有没有实现字典数组转模型数组的协议
            if ([self respondsToSelector:@selector(arrayContainModelClass)]) {
                // 转换成id类型 就能调用任何对象的方法
                id idSelf = self;
                
                // 获取数组中字典对应的模型
                NSString *type = [idSelf arrayContainModelClass][key];
                //生成模型
                Class classModel = NSClassFromString(type);
                NSMutableArray *arrayM = [NSMutableArray array];
                // 遍历字典数组 生成模型数组
                for (NSDictionary *dict in value) {
                    // 字典模型
                    id model = [classModel modelWithDict:dict];
                    [arrayM addObject:model];
                }
                // 把模型数组赋值给value
                value = arrayM;
            }
            
            // 模型里面套模型
            if ([self respondsToSelector:@selector(modelContainModelClass)]) {
                id idSelf = self;
                NSString *type = [idSelf modelContainModelClass][key];
                Class classModel = NSClassFromString(type);
                NSMutableArray *arrayM = [NSMutableArray array];
                for (NSDictionary *dict in value) {
                    id model = [classModel modelWithDict:dict];
                    [arrayM addObject:model];
                }
                value = arrayM;
            }
        }
        if (value) {// 有值，才需要给模型的属性赋值
            // 利用KVC给模型的属性赋值
            [obj setValue:value forKey:key];
        }
    }
    return obj;
}

@end
