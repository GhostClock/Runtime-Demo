//
//  NSObject+ModelExtension.h
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/15.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NSObjectDelegate <NSObject>

@optional
+ (NSDictionary *)arrayContainModelClass; ///< array 转字典
@optional
+ (NSDictionary *)modelContainModelClass; /// < array 转model

@end


@interface NSObject (ModelExtension)

+ (instancetype)modelWithDict:(id)dict;

@end
