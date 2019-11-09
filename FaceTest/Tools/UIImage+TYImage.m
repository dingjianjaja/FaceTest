//
//  UIImage+TYImage.m
//  FaceTest
//
//  Created by dingjianjaja on 2019/11/8.
//  Copyright © 2019 dingjianjaja. All rights reserved.
//

#import "UIImage+TYImage.h"

//#import <AppKit/AppKit.h>


@implementation UIImage (TYImage)

- (NSString *)toBase64{
    NSData *data = UIImageJPEGRepresentation(self, 0.2f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

@end
