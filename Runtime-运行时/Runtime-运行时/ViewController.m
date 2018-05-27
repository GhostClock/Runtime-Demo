//
//  ViewController.m
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/14.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import "ViewController.h"
#import "RuntimeTest.h"
#import "NetWorkTooth.h"
#import "DouBanModel.h"
#import "NSObject+ModelExtension.h"
#import "NSObject+KVO.h"
#import <objc/runtime.h>

@interface Message : NSObject

@property (nonatomic, copy) NSString *age;

@end

@implementation Message

@end

@interface ViewController ()

@property (nonatomic, copy) NSString *strText;
@property (nonatomic, strong) Message *msg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    RuntimeTest *test = [[RuntimeTest alloc] initWithLog:@"123"];
    [test performSelector:@selector(printLog1:log2:) withObject:@"One" withObject:@"Two"]; // 动态添加方法
//
    [test getPropertyList];
    [test getMethodList];
    [test getIvarList];
    [test getProtocolList];
    
    
//    [self GC_addObserver:self forKey:NSStringFromSelector(@selector(strText)) withBlock:^(id observedKey, NSString *keyPath, id oldValue, id newValue) {
//        
//    }];
    
//    _msg = [Message new];
//    [_msg GC_addObserver:self forKey:@"age" withBlock:^(id observedKey, NSString *keyPath, id oldValue, id newValue) {
//        NSLog(@"- %@ - %@ - %@ - %@ -", observedKey, keyPath, oldValue, newValue);
//    }];
//    _msg.age = @"0000";
    
    NSDictionary *dict = [[NetWorkTooth shendeInstence]requestWithUrl:@"https://api.douban.com/v2/movie/top250?start=0&count=2"];
    NSLog(@"%@", dict);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self testWithEncodeAndinitCode];
    NSArray<NSString *> *msg = @[@"111", @"222", @"333", @"444", @"555", @"666", @"777"];
    NSInteger index = arc4random_uniform((uint32_t)msg.count);
//    _strText = msg[index];
//    NSLog(@"-- %@ --", self.strText);
    _msg.age = msg[index];
}

// 测试归档解档
- (void)testWithEncodeAndinitCode {
    [self getData:^(DouBanModel *model) {
        if (model) {
            NSLog(@"本地存储的:");
            for (MovieInfo *info in model.subjects) {
                NSLog(@"%@ - %@", info.title, info.year);
            }
        } else {
            [[NetWorkTooth shendeInstence] requestWithUrl:@"https://api.douban.com/v2/movie/top250?start=0&count=50" success:^(NSDictionary *dictData) {
                DouBanModel *model = [DouBanModel modelWithDict:dictData];
                [self saveData:model];
                NSLog(@"请求的到的:");
                for (MovieInfo *info in model.subjects) {
                    NSLog(@"%@ - %@", info.title, info.year);
                }
            } failed:^(NSError *error) {
                
            }];
        }
    }];
}

- (void)getData:(void(^)(DouBanModel *model))dataModel {
    NSString *doctPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *target = [doctPath stringByAppendingString:@"/model.plist"];
    DouBanModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:target];
    if (model) {
        NSLog(@"解档成功");
    } else {
        NSLog(@"解档失败");
    }
    dataModel(model);
}

- (void)saveData:(DouBanModel *)model {
    NSString *doctPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *target = [doctPath stringByAppendingString:@"/model.plist"];
    BOOL ok = [NSKeyedArchiver archiveRootObject:model toFile:target];
    if (ok) {
        NSLog(@"归档成功");
    } else {
        NSLog(@"归档失败");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
