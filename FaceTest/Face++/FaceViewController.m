//
//  FaceViewController.m
//  FaceTest
//
//  Created by dingjianjaja on 2019/11/8.
//  Copyright © 2019 dingjianjaja. All rights reserved.
//

#import "FaceViewController.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "UIImage+TYImage.h"
#import "TotalModel.h"
#import <MJExtension/MJExtension.h>

@interface FaceViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (retain, nonatomic)UIImage *originImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelectSg;

@end

@implementation FaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)typeChangeAction:(UISegmentedControl *)sender {
    
    
}



- (IBAction)getPhotoAction:(UIButton *)sender {
    [self selectPhotoImage:1];
    
}

- (IBAction)judgeAction:(UIButton *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *imageStr = [_imageV.image toBase64];
    
    
    // 萤石 安全帽检测
    if (_typeSelectSg.selectedSegmentIndex == 1) {
        NSString *urlStr = @"https://open.ys7.com/api/lapp/intelligence/target/analysis";
        NSString *base64Str = [NSString stringWithFormat:@"data:image/jpeg;base64,%@",imageStr];
            NSDictionary *params = @{@"accessToken":@"at.3983qloz9pj7rwu71ok539s3czvhsruo-7eesalpec2-1t7t3u6-kryqmuleh",
                                     @"dataType":@0,
                                     @"image":@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573451218310&di=f9598ddcc08e3626ba9aeda8da02c218&imgtype=0&src=http%3A%2F%2Ffile03.16sucai.com%2F2017%2F1100%2F16sucai_P591F5C006.JPG",
                                     @"serviceType":@"helmet"};

            // 获得请求管理者
            AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
            
            // 设置请求格式
        //    session.requestSerializer = [AFJSONRequestSerializer serializer];
            
            session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
            
            [session POST:urlStr parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"%@",responseObject);
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSLog(@"%@",error);
            }];
        
        
        
        return;
    }
    
    
    
    
    NSString *urlStr = @"https://api-cn.faceplusplus.com/humanbodypp/v1/skeleton";
    
    NSDictionary *params = @{@"api_key":@"iDtyaruCOhWby3tyr-AG5iTOE2Rlfh-X",
                             @"api_secret":@"hzN6mOYP3Jx0W52MaXpY7Q-FZNB9ZKxL",
                             @"image_base64":imageStr};

    // 获得请求管理者
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    // 设置请求格式
//    session.requestSerializer = [AFJSONRequestSerializer serializer];
    
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", nil];
    
    [session POST:urlStr parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"%@",responseObject);
        
        NSArray *dicArr = responseObject[@"skeletons"];
        NSArray *modelArr = [TotalModel mj_objectArrayWithKeyValuesArray:dicArr];
        NSLog(@"%@",modelArr);
        [self calculatedPosition:modelArr];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"%@",error);
    }];
    
    
    
}


#pragma 针对返回的尺寸进行位置计算
- (void)calculatedPosition:(NSArray*)rectArr{
    TotalModel *model = rectArr.firstObject;
    NSLog(@"左边：%ld",(long)model.body_rectangle.left);
    NSLog(@"顶部：%ld",(long)model.body_rectangle.top);
    NSLog(@"宽度：%ld",(long)model.body_rectangle.width);
    NSLog(@"高度%ld",(long)model.body_rectangle.height);
    
    
    NSLog(@"头部-X：%ld",(long)model.landmark.head.x);
    NSLog(@"头部-Y：%ld",(long)model.landmark.head.y);
    
    
    UIImage *newImage = [self createShareImage:_imageV.image Context:@"安全帽检测"];
    [self drawRectOnImage:newImage frames:rectArr];
//    self.imageV.image = fImage;
}

// 在图片上添加矩形框 底图片名字image
- (void)drawRectOnImage:(UIImage *)image frames:(NSArray *)frameArr
{
    UIImage *sourceImage = image;
    CGSize imageSize; //画的背景 大小
    imageSize = [sourceImage size];
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [sourceImage drawAtPoint:CGPointMake(0, 0)];
    //获得 图形上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    //画 自己想要画的内容(添加的图片)
    CGContextDrawPath(context, kCGPathStroke);
 
    for (TotalModel *totalModel in frameArr) {
        CGRect rect = CGRectMake(totalModel.body_rectangle.left, totalModel.body_rectangle.top, totalModel.body_rectangle.width, totalModel.body_rectangle.height);
        [[UIColor blueColor] setStroke];// 人物整体用蓝色
        CGContextSetLineWidth(context, 3);
        CGContextStrokeRect(context,rect);//画方框
        // 帽子的高度
        float hatH;
        if (totalModel.landmark.neck.y > 0) {
            hatH = (totalModel.landmark.neck.y - totalModel.landmark.head.y) *0.6;
        }else{
            hatH = (totalModel.landmark.left_shoulder.y - totalModel.landmark.head.y) *0.6;
        }
        float hatW = 2 * hatH;
        
        // 头部
        CGRect headRect = CGRectMake(totalModel.landmark.head.x + totalModel.body_rectangle.left - 0.5*hatW, totalModel.body_rectangle.top, hatW, hatH);
        [[UIColor redColor] setStroke];// 还未判定或判定为否的安全帽用个红色
        CGContextStrokeRect(context,headRect);
        
        NSString *subImageStr = [[self getPartOfImage:_imageV.image rect:headRect] toBase64];
        NSString *url = @"https://aip.baidubce.com/rest/2.0/image-classify/v2/advanced_general?access_token='24.65c36dd236ac63e0cdac5ca0e491458d.2592000.1575944387.282335-17737295'";
        NSDictionary *params = @{@"image":subImageStr};
            // 获得请求管理者
            AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
            // 设置请求格式
        //    session.requestSerializer = [AFJSONRequestSerializer serializer];
        [session.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        session.completionQueue = dispatch_get_global_queue(0, 0);
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSDictionary *resp = [NSDictionary dictionary];
        [session POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"%@",responseObject);
            resp = responseObject;
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            dispatch_semaphore_signal(semaphore);
            NSLog(@"%@",error);
        }];
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
        NSArray *arr = resp[@"result"];
        for (NSDictionary *resultDic in arr) {
            NSLog(@"%@",resultDic[@"keyword"]);
            if ([resultDic[@"keyword"] containsString:@"安全帽"] || [resultDic[@"keyword"] containsString:@"头盔"]) {
                [[UIColor greenColor] setStroke];// 判定正确的安全帽用绿色
                CGContextStrokeRect(context,headRect);
                UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
                continue;
            }
        }
    }
    
    //返回绘制的新图形
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    self.imageV.image = newImage;
    UIGraphicsEndImageContext();
}

- (NSString *)URLEncodedString:(NSString *)str
{
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";

    NSString *unencodedString = str;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));

    return encodedString;
}

// 1.将文字添加到图片上;imageName 图片名字， text 需画的字体
- (UIImage *)createShareImage:(UIImage *)tImage Context:(NSString *)text
{
    UIImage *sourceImage = tImage;
    CGSize imageSize; //画的背景 大小
    imageSize = [sourceImage size];
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [sourceImage drawAtPoint:CGPointMake(0, 0)];
    //获得 图形上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    CGFloat nameFont = 18.f;
    //画 自己想要画的内容
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]};
    CGRect sizeToFit = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, nameFont) options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
    NSLog(@"图片: %f %f",imageSize.width,imageSize.height);
    NSLog(@"sizeToFit: %f %f",sizeToFit.size.width,sizeToFit.size.height);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawAtPoint:CGPointMake((imageSize.width-sizeToFit.size.width)/2,0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]}];
    //返回绘制的新图形
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}


// get part of the image
- (UIImage *)getPartOfImage:(UIImage *)img rect:(CGRect)partRect {
    CGImageRef imageRef = img.CGImage;
    CGImageRef imagePartRef = CGImageCreateWithImageInRect(imageRef, partRect);
    UIImage *retImg = [UIImage imageWithCGImage:imagePartRef];
    CGImageRelease(imagePartRef);
    return retImg;
    
}



- (void)selectPhotoImage:(NSInteger)current{
    //创建UIImagePickerController对象，并设置代理和可编辑
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.editing = YES;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    //创建sheet提示框，提示选择相机还是相册
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"请选择打开方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //相机选项
    UIAlertAction * camera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //选择相机时，设置UIImagePickerController对象相关属性
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
//        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        //跳转到UIImagePickerController控制器弹出相机
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    //相册选项
    UIAlertAction * photo = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //选择相册时，设置UIImagePickerController对象相关属性
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //跳转到UIImagePickerController控制器弹出相册
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    //取消按钮
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    //添加各个按钮事件
    [alert addAction:camera];
    [alert addAction:photo];
    [alert addAction:cancel];
    
    //弹出sheet提示框
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - imagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    //获取到的图片
    UIImage * image = [info valueForKey:UIImagePickerControllerEditedImage];
    _imageV.image = image;
}


@end
