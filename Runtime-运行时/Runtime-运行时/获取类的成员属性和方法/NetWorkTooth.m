//
//  NetWorkTooth.m
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/15.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import "NetWorkTooth.h"

@implementation NetWorkTooth

+ (instancetype)shendeInstence {
    static NetWorkTooth *netWorkTooth = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netWorkTooth = [[NetWorkTooth alloc] init];
    });
    return netWorkTooth;
}

- (void)requestWithUrl:(NSString *)url success:(void(^)(NSDictionary *dictData))success failed:(void(^)(NSError *error))failed {
    
    void(^dataBlock)(NSData *data, NSError *error) = ^(NSData *data, NSError *error) {
        NSError *jsonError;
        NSDictionary *dictJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        if (error) {
            failed(jsonError);
        } else {
            success(dictJson);
        }
    };
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSURL *urlRequest = [NSURL URLWithString:url];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dataBlock(data, error);
        dispatch_semaphore_signal(sem);
    }];
    [task resume];
    dispatch_time_t timeOut = dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC);
    dispatch_semaphore_wait(sem, timeOut);
}

- (NSDictionary *)requestWithUrl:(NSString *)url{
    __block NSDictionary *dict;
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *err;
        dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        dispatch_semaphore_signal(sem);
    }];
    [task resume];
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC));
    return dict;
}


@end
