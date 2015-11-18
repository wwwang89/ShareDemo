//
//  ViewController.m
//  ShareDemo
//
//  Created by huyujin on 15/11/9.
//  Copyright © 2015年 huyujin. All rights reserved.
//

#import "ViewController.h"
#import "HYJShareModel.h"
#import "HYJShareManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareTextAction:(id)sender {
    //
    HYJShareModel *shareModel = [[HYJShareModel alloc] init];
    shareModel.text = @"分享文字~";
    shareModel.modelType = HYJShareModelText;
    [[HYJShareManager sharedInstance] shareWithDataModel:shareModel];
}

- (IBAction)sharePicAction:(id)sender {
    UIImage *image = [UIImage imageNamed:@"xiao_mai.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    HYJShareImageModel *imageModel = [[HYJShareImageModel alloc] init];
    imageModel.imageData = imageData;
    imageModel.image = image;
    HYJShareModel *shareModel = [[HYJShareModel alloc] init];
    shareModel.mediaModel = imageModel;
    shareModel.modelType = HYJShareModelPic;
    [[HYJShareManager sharedInstance] shareWithDataModel:shareModel];
    
}


- (IBAction)shareWebpageAction:(id)sender {
    
    HYJShareWebPageModel *webpageModel = [[HYJShareWebPageModel alloc] init];
    webpageModel.webpageUrl = @"https://github.com/hyj223";
    webpageModel.title = @"hyj223";
    webpageModel.desc = @"一个github的网页分享~";
    NSData *data = UIImagePNGRepresentation([UIImage imageNamed:@"xiao_mai.jpg"]);
    webpageModel.thumbnailData = data;
    
    HYJShareModel *shareModel = [[HYJShareModel alloc] init];
    shareModel.mediaModel = webpageModel;
    shareModel.modelType = HYJShareModelWebpage;
    [[HYJShareManager sharedInstance] shareWithDataModel:shareModel];


}



@end
