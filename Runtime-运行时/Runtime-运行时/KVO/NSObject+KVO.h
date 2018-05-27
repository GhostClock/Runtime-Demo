//
//  NSObject+KVO.h
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/17.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^GCObserverBlock)(id observedKey, NSString *keyPath, id oldValue, id newValue);

@interface NSObject (KVO)

- (void)GC_addObserver:(NSObject *)observer forKey:(NSString *)key withBlock:(GCObserverBlock)observerBlock;

- (void)GC_removeObserver:(NSObject *)observer forKey:(NSString *)key;

@end
