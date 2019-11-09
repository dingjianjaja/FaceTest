//
//  UIImage+TYImage.h
//  FaceTest
//
//  Created by dingjianjaja on 2019/11/8.
//  Copyright © 2019 dingjianjaja. All rights reserved.
//
//#if !TARGET_OS_IOS #import <AppKit/AppKit.h>

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TYImage)

- (NSString *)toBase64;

@end

NS_ASSUME_NONNULL_END
