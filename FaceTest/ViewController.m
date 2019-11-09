//
//  ViewController.m
//  FaceTest
//
//  Created by dingjianjaja on 2019/9/19.
//  Copyright © 2019 dingjianjaja. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *resultImageV;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (nonatomic, assign) NSInteger currentPhoto;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UILabel *jyjgLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)takePhoto1:(UIButton *)sender {
    [self selectPhotoImage:1];
}
- (IBAction)takePhto2:(UIButton *)sender {
    [self selectPhotoImage:2];
    self.resultImageV.image = [UIImage imageNamed:@""];
    self.jyjgLabel.text = @"";
    self.jyjgLabel.backgroundColor = [UIColor whiteColor];
    self.resultLabel.text = @"";
    self.errorLabel.text = @"";
}
- (IBAction)compare:(UIButton *)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *image1 = [self base64FromImage:_imageView1.image];
    
    NSString *image2 = [self base64FromImage:_imageView2.image];
    NSString *urlStr = @"https://aip.baidubce.com/rest/2.0/face/v3/match?access_token='24.42be2a441a5fa515b87fc94f0287f0fc.2592000.1574912675.282335-17281894'";
    NSArray *arr = @[@{@"image": image1,@"image_type": @"BASE64",@"face_type": @"LIVE",@"liveness_control": @"NONE"},@{@"image": image2,@"image_type": @"BASE64",@"face_type": @"LIVE",@"liveness_control": @"NONE"},];

    // 获得请求管理者
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    // 设置请求格式
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    [session.requestSerializer requestWithMethod:@"POST" URLString:urlStr parameters:arr error:nil];
    [session POST:urlStr parameters:arr progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"%@",responseObject);
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSDictionary *result = dic[@"result"];
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSString *scroStr = [NSString stringWithFormat:@"%@",result[@"score"]];
            self->_resultLabel.text = scroStr;
            if (scroStr.floatValue > 75) {
                self.jyjgLabel.text = @"校验通过";
                self.jyjgLabel.backgroundColor = [UIColor greenColor];
                self.resultImageV.image = [UIImage imageNamed:@"true"];
            }else{
                self.jyjgLabel.text = @"校验不通过";
                self.resultImageV.image = [UIImage imageNamed:@"false"];
                self.jyjgLabel.backgroundColor = [UIColor redColor];
            }
            
        }else{
            self->_errorLabel.text = dic[@"error_msg"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];

    
}


- (void)selectPhotoImage:(NSInteger)current{
    self.currentPhoto = current;
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
    if (self.currentPhoto == 1) {
        _imageView1.image = image;
    }else{
        _imageView2.image = image;
    }
}


- (NSString *)base64FromImage:(UIImage *)originImage{
    NSData *data = UIImageJPEGRepresentation(originImage, 0.2f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}


@end
