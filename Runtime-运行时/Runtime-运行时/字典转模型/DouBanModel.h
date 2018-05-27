//
//  DouBanModel.h
//  Runtime-运行时
//
//  Created by GhostClock on 2018/5/15.
//  Copyright © 2018年 GhostClock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ModelExtension.h"

@interface MovieInfo : NSObject <NSCoding>

@property (nonatomic, strong)   NSDictionary *rating;
@property (nonatomic, assign)   NSInteger id;
@property (nonatomic, copy)     NSString  *original_title;
@property (nonatomic, assign)   NSInteger collect_count;
@property (nonatomic, copy)     NSArray *directors;
@property (nonatomic, copy)     NSString  *title;
@property (nonatomic, copy)     NSString  *year;
@property (nonatomic, copy)     NSArray *casts;
@property (nonatomic, copy)     NSArray *genres;
@property (nonatomic, strong)   NSDictionary *images;
@property (nonatomic, copy)     NSString  *subtype;
@property (nonatomic, copy)     NSString  *alt;

@end


@interface DouBanModel : NSObject <NSObjectDelegate, NSCoding>

@property (nonatomic, assign)   NSInteger count;
@property (nonatomic, assign)   NSInteger start;
@property (nonatomic, assign)   NSInteger total;
@property (nonatomic, copy)     NSString *title;
@property (nonatomic, strong)   NSArray<MovieInfo *> *subjects;

@end
