//
//  NetWorkTooth.h
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/15.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetWorkTooth : NSObject

+ (instancetype)shendeInstence;

- (void)requestWithUrl:(NSString *)url success:(void(^)(NSDictionary *dictData))success failed:(void(^)(NSError *error))failed;

- (NSDictionary *)requestWithUrl:(NSString *)url;

@end
