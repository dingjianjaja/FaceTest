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

@end

@implementation FaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}




- (IBAction)getPhotoAction:(UIButton *)sender {
    [self selectPhotoImage:1];
    
}

- (IBAction)judgeAction:(UIButton *)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *imageStr = [_imageV.image toBase64];
    
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
    
    
    UIImage *newImage = [self createShareImage:_imageV.image Context:@"ces的十多个大哥哥"];
    UIImage *fImage = [self drawRectOnImage:newImage frames:rectArr];
    self.imageV.image = fImage;
}

// 在图片上添加矩形框 底图片名字image
- (UIImage *)drawRectOnImage:(UIImage *)image frames:(NSArray *)frameArr
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
        
        CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
        CGContextStrokeRect(context,rect);//画方框
        
        // 帽子的高度
        float hatH = (totalModel.landmark.neck.y - totalModel.landmark.head.y) *0.6;
        float hatW = 2 * hatH;
        
        // 头部
        CGRect headRect = CGRectMake(totalModel.landmark.head.x + totalModel.body_rectangle.left - 0.5*hatW, totalModel.body_rectangle.top, hatW, hatH);
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextStrokeRect(context,headRect);
        
        // 颈部
//        CGRect neckRect = CGRectMake(totalModel.landmark.neck.x + totalModel.body_rectangle.left, totalModel.landmark.neck.y + totalModel.body_rectangle.top, 50, 50);
//        CGContextStrokeRect(context, neckRect);
        
    }
    
    //返回绘制的新图形
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
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
    CGFloat nameFont = 8.f;
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
