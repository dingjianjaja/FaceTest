//
//  TYImageRecognitionVC.m
//  FaceTest
//
//  Created by dingjianjaja on 2020/1/9.
//  Copyright © 2020 dingjianjaja. All rights reserved.
//

#import "TYImageRecognitionVC.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>

@interface TYImageRecognitionVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UIView *resultBgV;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelectSg;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel2;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel3;

@property (strong,nonatomic) NSDictionary *typeModelDic;

@end

@implementation TYImageRecognitionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark -- actions
- (IBAction)typeChangeAction:(UISegmentedControl *)sender {
    
    
}



- (IBAction)getPhotoAction:(UIButton *)sender {
    self.resultBgV.hidden = YES;
    self.typeBtn.hidden = YES;
    [self selectPhotoImage:1];
    
}

- (IBAction)judgeAction:(UIButton *)sender {
    NSString *url = @"https://aip.baidubce.com/rpc/2.0/ai_custom/v1/classification/distinguishType";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *image1 = [self base64FromImage:_imageV.image];
    /*token 24.ddc39dc33c978770bfd7a281a42c18ef.2592000.1581212207.282335-18239613*/
    NSString *urlStr = @"https://aip.baidubce.com/rpc/2.0/ai_custom/v1/classification/distinguishType?access_token='24.ddc39dc33c978770bfd7a281a42c18ef.2592000.1581212207.282335-18239613'";
    NSDictionary *param = @{@"image": image1};

    // 获得请求管理者
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
    // 设置请求格式
    session.requestSerializer = [AFJSONRequestSerializer serializer];
    [session.requestSerializer requestWithMethod:@"POST" URLString:urlStr parameters:param error:nil];
    [session POST:urlStr parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"%@",responseObject);
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSArray *result = dic[@"results"];
        for (int i = 0; i < result.count; i++) {
            NSDictionary *modelType = result[i];
            NSString *scroStr = [NSString stringWithFormat:@"%@",modelType[@"score"]];
            NSString *typeName = modelType[@"name"];
            if (i == 0) {
                self->_typeLabel1.text = [NSString stringWithFormat:@"%@:%.2f",self.typeModelDic[typeName],scroStr.floatValue];
                [self.typeBtn setTitle:self.typeModelDic[typeName] forState:UIControlStateNormal];
                if ([typeName isEqualToString:@"RRU"]) {
                    self.typeLabel2.text = @"品牌：ZTE 中兴";
                    self.typeLabel3.text = @"型号：ZXSDR R8860E GU908";
                }else if ([typeName isEqualToString:@"rectifier"]) {
                    self.typeLabel2.text = @"品牌：EMERSON艾默生";
                    self.typeLabel3.text = @"型号：R48-2900整流模块";
                }else{
                    self.typeLabel2.text = @"";
                    self.typeLabel3.text = @"";
                }
            }
        }
        
        self.resultBgV.hidden = NO;
        self.typeBtn.hidden = NO;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark -- imagePicker
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



- (NSString *)base64FromImage:(UIImage *)originImage{
    NSData *data = UIImageJPEGRepresentation(originImage, 0.2f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}



- (NSDictionary *)typeModelDic{
    if (!_typeModelDic) {
        _typeModelDic = @{@"tower_room":@"塔房",
                                 @"beautify_pipes":@"美化排气管",
                                 @"RRU":@"RRU",
                                 @"rectifier":@"整流器",
                          @"image_tianxian":@"美化树",
                          @"[default]":@"其他"};
    }
    return _typeModelDic;
}

@end
