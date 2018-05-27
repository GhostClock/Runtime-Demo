//
//  RuntimeTest.h
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/15.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RunTimeProtocol <NSObject>

- (NSString *)testProtocol:(int)age;

@end

typedef NS_ENUM(NSUInteger, SEX) {
    SEX_MAN,
    SEX_WAMEN,
    SEX_OTHER,
};

@interface RuntimeTest : NSObject

@property (nonatomic, copy) NSString *log;
@property (nonatomic, assign) NSInteger *age;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) SEX sex;

- (instancetype)initWithLog:(NSString *)log;
- (void)getPropertyList;
- (void)getMethodList;
- (void)getIvarList;
- (void)getProtocolList;
@end
