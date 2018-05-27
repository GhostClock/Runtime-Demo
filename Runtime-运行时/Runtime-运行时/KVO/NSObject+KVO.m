//
//  NSObject+KVO.m
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/17.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface GCObservationInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) GCObserverBlock observerBlock;

@end

@implementation GCObservationInfo

- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)key block:(GCObserverBlock)observerBlock {
    self = [super init];
    if (self) {
        _observer = observer;
        _keyPath = key;
        _observerBlock = [observerBlock copy];
    }
    return self;
}

@end


#pragma mark - ================


static NSString *const KVONotifying = @"GCKVONotifying_";
static NSString *const AssociatedObjectKey = @"AssociatedObjectKey";

@implementation NSObject (KVO)

// 获取方法类型
const char* methodTypeEncoding(Method originalMethod) {
    return method_getTypeEncoding(originalMethod);
}

// 观察的属性前面加上set 例如setAge:
NSString * setterForGetter(NSString *key) {
    if (key.length <= 0) {
        return nil;
    }
    //把第一个字母变成大写
    NSString *firstLetter = [[key substringToIndex:1] uppercaseString];
    //其余的全部变成小写
    NSString *remainingLetter = [key substringFromIndex:1];
    // 拼接成set方法
    NSString *setter = [NSString stringWithFormat:@"set%@%@:", firstLetter, remainingLetter];
    return setter;
}

// 观察的属性前面要是有 set 前缀和 : 后缀，就将其去掉 setAge: -> age
NSString * getterForSetter(NSString *setter) {
    if (setter.length <= 0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return setter;
    }
    
    // 删除set开头和:结尾
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *getter = [setter substringWithRange:range];

    // 把第一个字母变成小写
    NSString *firstLetter = [[getter substringToIndex:1] lowercaseString];
    getter = [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:firstLetter];

    return getter;
}

#pragma mark - 判断该kvo类有没有这个setter方法
- (BOOL)haveSelector:(SEL)setter {
    Class class = object_getClass(self);
    unsigned int outCount = 0;
    Method *methods = class_copyMethodList(class, &outCount);
    for (int i = 0 ; i < outCount; i ++) {
        SEL setSelector = method_getName(methods[i]);
        if (setSelector == setter) {
            free(methods);
            return YES;
        }
    }
    free(methods);
    return NO;
}

#pragma mark - 重写setter方法
// 新的setter方法在调用原setter方法后，通知每个观察者
static void kvo_setter(id self, SEL _cmd, id newValue) {
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter(setterName);
    if (!getterName) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"没有相应的属性" userInfo:nil];
        return;
    }
    
    id oldValue = [self valueForKey:getterName];
    
    struct objc_super superClass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    void (*objc_msgSendSuperCasted)(void*, SEL, id) = (void *)objc_msgSendSuper; // 转换objc_msgSendSuper
    objc_msgSendSuperCasted(&superClass, _cmd, newValue);
    
    NSMutableArray *observer = objc_getAssociatedObject(self, &AssociatedObjectKey);
    for (GCObservationInfo *info in observer) {
        if ([info.keyPath isEqualToString:getterName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                info.observerBlock(self, getterName, oldValue, newValue);
            });
        }
    }
}

Class kvo_class(id self, SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

#pragma mark - 动态创建这个kvo类
- (Class)createKVONotifyingClassWithOriginalClassName:(NSString *)originClassName {
    
    NSString *kvoClassName = [KVONotifying stringByAppendingString:originClassName];
    // 如果这个kvo类存在，就直接返回
    Class kvoClass = NSClassFromString(kvoClassName);
    if (kvoClass) {
        return kvoClass;
    }
    
    // 这个kvo类不存在, 就用runtime创建一个, 父类是该观察者
    Class originalClass = object_getClass(self);
    kvoClass = objc_allocateClassPair(originalClass, [kvoClassName UTF8String], 0);
    
    // 重写掉系统的class方法
    Method originMethod = class_getInstanceMethod(originalClass, @selector(class));
    class_addMethod(kvoClass, @selector(class), (IMP)kvo_class, methodTypeEncoding(originMethod));
    // 向runtime注册这个类
    objc_registerClassPair(kvoClass);
    
    return kvoClass;
}

#pragma mark - 外部方法
- (void)GC_addObserver:(NSObject *)observer forKey:(NSString *)key withBlock:(GCObserverBlock)observerBlock {
    // 用setterForGetter获得相应的setter方法，得到型如 setAge: 的选择器
    SEL setterSelector = NSSelectorFromString(setterForGetter(key));
    
    Method setterMethood = class_getInstanceMethod([self class], setterSelector);
    // 1. 检查对象的类有没有相应的setter方法，如果没有则抛出异常
    if (!setterMethood) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"没有相应的属性" userInfo:nil];
        return;
    }
    
    // 2. 检查对象 isa 指针指向的是否是一个KVO类,如果不是,用runtime新建一个继承原来类的子类,并把 isa 指向这个新建的子类
    Class kvoClass = object_getClass(self);
    NSString *className = NSStringFromClass(kvoClass);
    if (![className hasPrefix:KVONotifying]) {
        kvoClass = [self createKVONotifyingClassWithOriginalClassName:className];
        // 把isa指向新建的类
        object_setClass(self, kvoClass);
    }
    
    // 3. 检查对象的KVO类有没有重写过这个类的setter方法，如果没有,添加重写的setter方法
    if (![self haveSelector:setterSelector]) {
        // 添加setter方法
//        class_addMethod(kvoClass, setterSelector, (IMP)kvo_setter, methodTypeEncoding(setterMethood));
        class_addMethod([kvoClass class], setterSelector, class_getMethodImplementation(kvoClass, @selector(kvoSetter:)), methodTypeEncoding(setterMethood));
    }
    
    // 4.添加这个观察者
    GCObservationInfo *observerInfo = [[GCObservationInfo alloc] initWithObserver:observer keyPath:key block:observerBlock];
    NSMutableArray *observers = objc_getAssociatedObject(self, &AssociatedObjectKey);
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, &AssociatedObjectKey, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:observerInfo];
}

- (void)kvoSetter:(id)newValue {
    unsigned int outCount = 0;
    Method *methods = class_copyMethodList([self class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Method method = methods[i];
        NSString *setterName = NSStringFromSelector(method_getName(method));
        if ([setterName hasPrefix:@"set"] && [setterName hasSuffix:@":"]) {
            NSString *getterName = getterForSetter(setterName);
            
            // 用kvo获取旧值
            id oldValue = [self valueForKey:getterName];
            
            struct objc_super superClass;
            superClass.receiver = self;
            superClass.super_class = class_getSuperclass(object_getClass(self));
            
            // 转换 objc_msgSendSuper
            void(* myMsgSendSuper)(void *, SEL, id) = (void *)objc_msgSendSuper;
            
            myMsgSendSuper(&superClass, method_getName(method), newValue);
            
            NSMutableArray *observers = objc_getAssociatedObject(self, &AssociatedObjectKey);
            for (GCObservationInfo *info in observers) {
                if ([info.keyPath isEqualToString:getterName]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        info.observerBlock(self, getterName, oldValue, newValue);
                    });
                }
            }
            
            break;
        }
    }
}



- (void)GC_removeObserver:(NSObject *)observer forKey:(NSString *)key {
    NSMutableArray *observers = objc_getAssociatedObject(self, &AssociatedObjectKey);
    GCObservationInfo *removeInfo = nil;
    for (GCObservationInfo *info in observers) {
        if ([info.keyPath isEqualToString:key] && info.observer == observer) {
            removeInfo = info;
            break;
        }
    }
    [observers removeObject:removeInfo];
}

@end


