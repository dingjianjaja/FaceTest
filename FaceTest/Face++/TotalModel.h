//
//  TotalModel.h
//  FaceTest
//
//  Created by dingjianjaja on 2019/11/8.
//  Copyright © 2019 dingjianjaja. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface Body_rectangle :NSObject
@property (nonatomic , assign) NSInteger              top;
@property (nonatomic , assign) NSInteger              width;
@property (nonatomic , assign) NSInteger              height;
@property (nonatomic , assign) NSInteger              left;

@end

@interface DJSizeModel :NSObject
@property (nonatomic , assign) NSInteger              y;
@property (nonatomic , assign) NSInteger              x;
@property (nonatomic , assign) float              score;

@end

@interface Landmark :NSObject
@property (nonatomic , strong) DJSizeModel              * right_hand;
@property (nonatomic , strong) DJSizeModel              * neck;
@property (nonatomic , strong) DJSizeModel              * left_buttocks;
@property (nonatomic , strong) DJSizeModel              * head;
@property (nonatomic , strong) DJSizeModel              * right_knee;
@property (nonatomic , strong) DJSizeModel              * right_buttocks;
@property (nonatomic , strong) DJSizeModel              * left_hand;
@property (nonatomic , strong) DJSizeModel              * left_shoulder;
@property (nonatomic , strong) DJSizeModel              * left_knee;
@property (nonatomic , strong) DJSizeModel              * right_foot;
@property (nonatomic , strong) DJSizeModel              * left_foot;
@property (nonatomic , strong) DJSizeModel              * right_elbow;
@property (nonatomic , strong) DJSizeModel              * right_shoulder;
@property (nonatomic , strong) DJSizeModel              * left_elbow;

@end

@interface TotalModel :NSObject
// 人体整体位置
@property (nonatomic , strong) Body_rectangle              * body_rectangle;
// 人体各个关键点的坐标
@property (nonatomic , strong) Landmark              * landmark;

@end



NS_ASSUME_NONNULL_END
