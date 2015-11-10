//
//  HYJShareManager.m
//  HYJ
//
//  Created by huyujin on 15-10-26.
//
//
#import "HYJShareManager.h"
#import "HYJShareModel.h"
#import "HYJShareUI.h"
#import "AppDelegate.h"


#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]



@interface HYJShareManager ()<HYJShareUIDelegate,HYJShareManagerDelegate>{

}

@property (nonatomic, strong) HYJShareModel *dataModel;

//
@property (nonatomic, strong) HYJSinaWeiBoShareManager *weiBoShareManager;
@property (nonatomic, strong) HYJWeChatShareManager *weChatShareManager;
@property (nonatomic, strong) HYJQQShareManager *qqShareManager;
//@property (nonatomic, strong) HYJSMSShareManager *smsShareManager;

@end

@implementation HYJShareManager


// 初始化HYJShareManager，不要采用该方法，而应该使用sharedInstance
- (instancetype)init {

    self = [super init];
    if (self) {
        [self registerSharedApp];
    }
    return self;
}

+ (HYJShareManager *)sharedInstance {
    
    static HYJShareManager *shareManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[HYJShareManager alloc] init];
    });
    
    return shareManager;
}

// register~
- (void)registerSharedApp {
    //新浪微博
//    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:SinaWeiBoAppKey];
    //向微信注册
    
    [WXApi registerApp:WeChatAppID];
    //qq注册
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:nil];
    tencentOAuth.redirectURI = @"www.qq.com";

}

//
- (void)shareWithDataModel:(HYJShareModel *)shareModel {
    //分享的内容~
    self.dataModel = shareModel;
    //初始化各个shareManager:
    [self initShareManagers];
    
    //获取回调内容~
    [HYJShareUI sharedInstance].delegate = (id<HYJShareUIDelegate>)self;
    //创建分享窗口~
    [[HYJShareUI sharedInstance] createShareWindow];
}

//
- (void)initShareManagers {
    //
    HYJSinaWeiBoShareManager *weiBoShareManager = [[HYJSinaWeiBoShareManager alloc] init];
    weiBoShareManager.delegate = (id<HYJShareManagerDelegate>)self;
    self.weiBoShareManager = weiBoShareManager;
    //
    HYJWeChatShareManager *weChatShareManager = [[HYJWeChatShareManager alloc] init];
    weChatShareManager.delegate = (id<HYJShareManagerDelegate>)self;
    self.weChatShareManager = weChatShareManager;
    //
    HYJQQShareManager *qqShareManager = [[HYJQQShareManager alloc] init];
    qqShareManager.delegate = (id<HYJShareManagerDelegate>)self;
    self.qqShareManager = qqShareManager;
    
    //
//    HYJSMSShareManager *smsShareManager = [[HYJSMSShareManager alloc] init];
//    smsShareManager.delegate = self;
//    self.smsShareManager = smsShareManager;
    
}

- (BOOL)handleOpenURL:(NSURL *)url {
    
    //根据不同的URL的不同的前缀 交由各个SDK处理
    NSString *handle = [url absoluteString];
    if([handle rangeOfString:SinaWeiBoAppKey].location != NSNotFound) {
        
        return [WeiboSDK handleOpenURL:url delegate:(id<WeiboSDKDelegate>)self.weiBoShareManager];
    }else if([handle rangeOfString:WeChatAppID].location != NSNotFound){
        
        return [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)self.weChatShareManager];
    }else if ([handle rangeOfString:QQAppID].location != NSNotFound){
        
        return [QQApiInterface handleOpenURL:url delegate:(id)self.qqShareManager];
    }else{
        return YES;
    }
}

#pragma mark - HYJShareUI Delegate
// shareui delegate 根据不同的平台进行不同的分享请求~
- (void)shareToPlatform:(HYJShareType)shareType {
    //分享窗口删除~
    [[HYJShareUI sharedInstance] cancelAction];
    
    //根据不同的平台走不同的分享方式~
    switch (shareType) {
        case HYJShareTypeSinaWeiBo: //新浪微博
        {
            [self.weiBoShareManager shareWeiBoWithDataModel:self.dataModel];
            break;
        }
        case HYJShareTypeWeixinSession: //微信好友
        case HYJShareTypeWeixinTimeline: //微信朋友圈
        {
            //
            int scene = shareType==HYJShareTypeWeixinSession ? WXSceneSession:WXSceneTimeline;
            [self.weChatShareManager shareWeChatWithDataModel:self.dataModel inScene:scene];
            break;
        }
        case HYJShareTypeQQFriend:
        case HYJShareTypeQQZone:
        {
            [self.qqShareManager shareQQWithDataModel:self.dataModel shareType:shareType];
            
            break;
        }
        case HYJShareTypeSMS:
//            [self.smsShareManager shareSMSWithDataModel:self.dataModel];
            break;
        case HYJShareTypeCopyLink: //复制链接
        {
            //直接做处理
            UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
            pasteBoard.string = self.dataModel.text==nil ? @"":self.dataModel.text;
            //
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [HYJShareUI showToastViewWithContent:@"链接已复制" andRect:CGRectMake((kScreenViewWidth - 200)/2, (kScreenViewHeight - 200)/2, 200, 50) andTime:1.5f andObjectView:window];
            break;
        }
        default:
            NSLog(@"error shareType~");
            break;
    }

}

#pragma mark - HYJShareManagerDelegate
// HYJShareManagerDelegate 根据分享返回的结果进行后续操作
- (void)didReceiveShareResponse:(HYJShareResponse *)response {
    NSLog(@"%@",response);
    //分享数据模型清理~~~
    self.dataModel = nil;
    //~~~弹出提示框~~~
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (response.responseState== HYJShareResponseStateSuccess) {
        [HYJShareUI showToastViewWithContent:@"分享成功" andRect:CGRectMake((kScreenViewWidth - 200)/2, (kScreenViewHeight - 200)/2, 200, 50) andTime:1.5f andObjectView:window];
    }else if (response.responseState== HYJShareResponseStateCancel) {
        [HYJShareUI showToastViewWithContent:@"分享取消" andRect:CGRectMake((kScreenViewWidth - 200)/2, (kScreenViewHeight - 200)/2, 200, 50) andTime:1.5f andObjectView:window];
    }else {
        [HYJShareUI showToastViewWithContent:@"分享失败" andRect:CGRectMake((kScreenViewWidth - 200)/2, (kScreenViewHeight - 200)/2, 200, 50) andTime:1.5f andObjectView:window];
    }
}


@end


#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - HYJSinaWeiBoShareManager

/**新浪微博分享Manager
 *
 * 一个消息结构由三部分组成：文字、图片和多媒体数据。三部分内容中至少有一项不为空，图片和多媒体数据不能共存。
 */

@implementation HYJSinaWeiBoShareManager

- (void)shareWeiBoWithDataModel:(HYJShareModel *)shareModel {
    
    //app 安装验证~
    BOOL isIntalled = [WeiboSDK isWeiboAppInstalled];
    if (!isIntalled) {
        [self performSelector:@selector(showToast:) withObject:@"未安装此应用！" afterDelay:0.2];
        return;
    }
    
    WBMessageObject *message = [WBMessageObject message];
    
    switch (shareModel.modelType) {
        case HYJShareModelText:
            //长度小于140个汉字
            if (shareModel.text.length>=140) {
                shareModel.text = [shareModel.text substringToIndex:139];
            }
            message.text = shareModel.text;
            
            break;
        case HYJShareModelPic:
        {
            HYJShareImageModel *imageModel = (HYJShareImageModel *)shareModel.mediaModel;
            if (imageModel.imageData) {
                //大小不能超过10M
                if (imageModel.imageData.length>10*1024*1024) {
                    UIImage *image = [HYJShareUI compressImage:imageModel.image toMaxFileSize:10*1024*1024];
                    imageModel.imageData = UIImageJPEGRepresentation(image, 0.9);
                }
                
                WBImageObject *imageObj = [WBImageObject object];
                imageObj.imageData = imageModel.imageData;
                message.imageObject = imageObj;
            }
            break;
        }
        case HYJShareModelWebpage:
        {
            HYJShareWebPageModel *webpageModel = (HYJShareWebPageModel *)shareModel.mediaModel;
            if (webpageModel.webpageUrl) {
                WBWebpageObject *webpageObj = [WBWebpageObject object];
                webpageObj.webpageUrl = webpageModel.webpageUrl;
                webpageObj.objectID = TimeStamp;
                webpageObj.title = webpageModel.title;
                webpageObj.description = webpageModel.desc;
                webpageObj.thumbnailData = webpageModel.thumbnailData;
                message.mediaObject = webpageObj;
            }
            break;
        }
        case HYJShareModelVideo:
        {
            HYJShareVideoModel *videoModel = (HYJShareVideoModel *)shareModel.mediaModel;
            if (videoModel.videoUrl) {
                WBVideoObject *videoObj = [WBVideoObject object];
                videoObj.videoUrl = videoModel.videoUrl;
                message.mediaObject = videoObj;
            }
            break;
        }
        default:
            break;
    }
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    [WeiboSDK sendRequest:request];
}

- (void)showToast:(NSString *)message {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [HYJShareUI showToastViewWithContent:message andRect:CGRectMake((kScreenViewWidth - 200)/2, (kScreenViewHeight - 200)/2, 200, 50) andTime:1.5f andObjectView:window];
}


#pragma mark  sina weibo delegate~
/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    //
    HYJShareResponse *shareResponse = [[HYJShareResponse alloc] init];
    if([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) {
        
        WBBaseResponse *res = (WBSendMessageToWeiboResponse *)response;
        if(res.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            shareResponse.responseState = HYJShareResponseStateSuccess;
            shareResponse.responseMsg = @"weibo share success";
            
        }else if(res.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            shareResponse.responseState = HYJShareResponseStateCancel;
            shareResponse.responseMsg = @"weibo share cancel";
        }else {
            NSLog(@"response.statusCode:%ld",(long)res.statusCode);
            shareResponse.responseState = HYJShareResponseStateFail;
            shareResponse.responseMsg = @"weibo share failed";
        }
        //
    }else if([response isKindOfClass:[WBAuthorizeResponse class]]) {
        NSLog(@"%@",response);
    }
    //
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveShareResponse:)]) {
        [self.delegate didReceiveShareResponse:shareResponse];
    }
}


@end

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - HYJWeChatShareManager

@implementation HYJWeChatShareManager

/**
 * 发送消息的类型，包括文本消息和多媒体消息两种，两者只能选择其一，不能同时发送文本和多媒体消息
 */
- (void)shareWeChatWithDataModel:(HYJShareModel *)shareModel
                         inScene:(int)scene
{
    //app安装验证~
    BOOL isIntalled = [WXApi isWXAppInstalled];
    if (!isIntalled) {
        [self performSelector:@selector(showToast:) withObject:@"未安装此应用！" afterDelay:0.2];
        return;
    }
    
    switch (shareModel.modelType) {
        case HYJShareModelText:
        {
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = YES;
            req.text = shareModel.text;
            req.scene = scene;
            [WXApi sendReq:req];
            break;
        }
        case HYJShareModelPic:
        {
            WXMediaMessage *message = [WXMediaMessage message];
            HYJShareImageModel *imageModel = (HYJShareImageModel *)shareModel.mediaModel;
            if (imageModel.imageData) {
                //处理缩略图~长度不能超过10K
                UIImage *thumbImage = imageModel.image;
                if (imageModel.image.size.width>kScreenViewWidth) {
                    thumbImage = [HYJShareUI compressImage:imageModel.image toTargetWidth:kScreenViewWidth];
                    //
                    NSData *thumbData = UIImagePNGRepresentation(thumbImage);
                    if (thumbData.length>10*1024) {
                         thumbImage = [HYJShareUI compressImage:thumbImage toMaxFileSize:10*1024];
                    }
                }
                
                [message setThumbImage:thumbImage];
                //处理原图~大小不能超过10M
                UIImage *primaryImage = imageModel.image;
                if (imageModel.imageData.length>10*1024*1024) {
                    primaryImage = [HYJShareUI compressImage:imageModel.image toMaxFileSize:10*1024*1024];
                    imageModel.imageData = UIImageJPEGRepresentation(primaryImage, 0.9);
                }
                //当前仅为图片~
                WXImageObject *imageObj = [WXImageObject object];
                imageObj.imageData = imageModel.imageData;
                imageObj.imageUrl = imageModel.imageUrl;
                message.mediaObject = imageObj;
                
            }
            //
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = scene;
            [WXApi sendReq:req];
            
            
            break;
        }
        case HYJShareModelWebpage:
        {
            WXMediaMessage *message = [WXMediaMessage message];
            HYJShareWebPageModel *webpageModel = (HYJShareWebPageModel *)shareModel.mediaModel;
            if (webpageModel.webpageUrl) {
                WXWebpageObject *webpageObj = [WXWebpageObject object];
                webpageObj.webpageUrl = webpageModel.webpageUrl;
                message.mediaObject = webpageObj;
                
                message.title = webpageModel.title;
                message.description = webpageModel.desc;
                message.thumbData = webpageModel.thumbnailData;
            }
            //
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = scene;
            [WXApi sendReq:req];

            break;
        }
        case HYJShareModelVideo:
        {
            WXMediaMessage *message = [WXMediaMessage message];
            //视频~
            if ([shareModel.mediaModel isKindOfClass:[HYJShareVideoModel class]]) {
                HYJShareVideoModel *videoModel = (HYJShareVideoModel *)shareModel.mediaModel;
                if (videoModel.videoUrl) {
                    //
                    WXVideoObject *videoObj = [WXVideoObject object];
                    videoObj.videoUrl = videoModel.videoUrl;
                    message.mediaObject = videoObj;
                }
            }
            SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
            req.bText = NO;
            req.message = message;
            req.scene = scene;
            [WXApi sendReq:req];
            
            break;
        }
        default:
            break;
    }

}

- (void)showToast:(NSString *)message {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [HYJShareUI showToastViewWithContent:message andRect:CGRectMake((kScreenViewWidth - 200)/2, (kScreenViewHeight - 200)/2, 200, 50) andTime:1.5f andObjectView:window];
}

#pragma mark  WXApi Delegate
//
-(void) onReq:(BaseReq*)req {

    
}

//
- (void)onResp:(BaseResp *)resp {
    //
    HYJShareResponse *shareResponse = [[HYJShareResponse alloc] init];
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        int responseCode = resp.errCode;
        if (responseCode == WXSuccess) {
            //
            shareResponse.responseState = HYJShareResponseStateSuccess;
            shareResponse.responseMsg = @"wechat share success";
        }else if (responseCode == WXErrCodeUserCancel) {
            //
            shareResponse.responseState = HYJShareResponseStateCancel;
            shareResponse.responseMsg = @"wechat share cancel";
        }else {
            NSLog(@"errCode:%d,errStr:%@",responseCode,resp.errStr);
            shareResponse.responseState = HYJShareResponseStateFail;
            //返回微信的错误提示字符串
            shareResponse.responseMsg = resp.errStr;
        }
    }
    //
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveShareResponse:)]) {
        [self.delegate didReceiveShareResponse:shareResponse];
    }
}

@end

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - HYJQQShareManager

@implementation HYJQQShareManager

/** 分享：qq请求~
 * 分享文字和图片，暂时只支持分享给qq好友，不支持分享到QQ空间~
 */
- (void)shareQQWithDataModel:(HYJShareModel *)shareModel
                   shareType:(HYJShareType)shareType
{

    //app安装验证~
    BOOL isIntalled = [QQApiInterface isQQInstalled];
    if (!isIntalled) {
        [self performSelector:@selector(showToast:) withObject:@"未安装此应用！" afterDelay:0.2];
        return;
    }
    //功能支持验证~
    if (shareType== HYJShareTypeQQZone && (shareModel.modelType==HYJShareModelText ||shareModel.modelType==HYJShareModelPic)) {
        [[HYJShareUI sharedInstance] cancelAction];
        //
        [self performSelector:@selector(showToast:) withObject:@"QQ空间暂不支持文字、图片分享！" afterDelay:0.2];
        return;
    }
    //
    switch (shareModel.modelType) {
        case HYJShareModelText:
        {
            QQApiTextObject *textObj = [QQApiTextObject objectWithText:shareModel.text];
            
            [self reqQQWithObject:textObj shareType:shareType];
            
            break;
        }
        case HYJShareModelPic:
        {
            if ([shareModel.mediaModel isKindOfClass:[HYJShareImageModel class]]) {
                HYJShareImageModel *imageModel = (HYJShareImageModel *)shareModel.mediaModel;
                //缩略图~最大1M字节
                UIImage *thumbImage = imageModel.image;
                if (imageModel.image.size.width>kScreenViewWidth) {
                    thumbImage = [HYJShareUI compressImage:imageModel.image toTargetWidth:kScreenViewWidth];
                    //
                    NSData *thumbData = UIImageJPEGRepresentation(thumbImage,0.1);
                    if (thumbData.length>1024*1024) {
                        thumbImage = [HYJShareUI compressImage:thumbImage toMaxFileSize:1024*1024];
                    }
                }
                NSData *thumbImageData = UIImageJPEGRepresentation(thumbImage, 0.1);
                //处理原图~最大5M字节
                UIImage *primaryImage = imageModel.image;
                if (imageModel.imageData.length>5*1024*1024) {
                    primaryImage = [HYJShareUI compressImage:imageModel.image toMaxFileSize:5*1024*1024];
                }
                NSData *primaryImageData = UIImageJPEGRepresentation(primaryImage, 0.9);
                QQApiImageObject *imgObj = [QQApiImageObject objectWithData:primaryImageData previewImageData:thumbImageData title:@"" description:@""];
                [self reqQQWithObject:imgObj shareType:shareType];
            }
            
            break;
        }
        case HYJShareModelWebpage:
        {
            if ([shareModel.mediaModel isKindOfClass:[HYJShareWebPageModel class]]) {
                HYJShareWebPageModel *webpageModel = (HYJShareWebPageModel *)shareModel.mediaModel;
                if (webpageModel.webpageUrl) {
                    QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:webpageModel.webpageUrl] title:webpageModel.title description:webpageModel.desc previewImageData:webpageModel.thumbnailData];
                    [self reqQQWithObject:newsObj shareType:shareType];
                }
            }
            
            break;
        }
        case HYJShareModelVideo:
        {
            //QQApiVideoObject类型的分享，目前在Android和PC QQ上接收消息时，展现有待完善，待手机QQ版本以后更新支持~目前如果要分享视频，推荐使用 QQApiNewsObject 类型
            if ([shareModel.mediaModel isKindOfClass:[HYJShareVideoModel class]]) {
                HYJShareVideoModel *videoModel = (HYJShareVideoModel *)shareModel.mediaModel;
                QQApiVideoObject *videoObj = [QQApiVideoObject objectWithURL:[NSURL URLWithString:videoModel.videoUrl] title:@"" description:@"" previewImageURL:[NSURL URLWithString:@""]];
                
                [self reqQQWithObject:videoObj shareType:shareType];
            }
            
            break;
        }
        default:
            break;
    }
    
}

- (void)showToast:(NSString *)message {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [HYJShareUI showToastViewWithContent:message andRect:CGRectMake((kScreenViewWidth - 200)/2, (kScreenViewHeight - 200)/2, 200, 50) andTime:1.5f andObjectView:window];
}

- (void)reqQQWithObject:(QQApiObject *)obj shareType:(HYJShareType)shareType {
    //
    QQApiSendResultCode resultCode;
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
    
    if (shareType == HYJShareTypeQQFriend) {
        resultCode = [QQApiInterface sendReq:req];
    }else {
        resultCode = [QQApiInterface SendReqToQZone:req];
    }
    
    NSLog(@"QQApiSendResultCode:%d",resultCode);
}

#pragma mark qq delegate~
- (void)onReq:(QQBaseReq *)req {
    
}


/** 
 * 处理来至QQ的响应
 * 
 * resp.type
     ESHOWMESSAGEFROMQQRESPTYPE = 0, ///< 第三方应用 -> 手Q，第三方应用应答消息展现结果
     EGETMESSAGEFROMQQRESPTYPE = 1,  ///< 第三方应用 -> 手Q，第三方应用回应发往手Q的消息
     ESENDMESSAGETOQQRESPTYPE = 2    ///< 手Q -> 第三方应用，手Q应答处理分享消息的结果
 * resp.result
     @brief 用于请求回应的数据类型。
     <h3>可能错误码及描述如下:</h3>
     <TABLE>
     <TR><TD>error</TD><TD>errorDescription</TD><TD>注释</TD></TR>
     <TR><TD>0</TD><TD>nil</TD><TD>成功</TD></TR>
     <TR><TD>-1</TD><TD>param error</TD><TD>参数错误</TD></TR>
     <TR><TD>-2</TD><TD>group code is invalid</TD><TD>该群不在自己的群列表里面</TD></TR>
     <TR><TD>-3</TD><TD>upload photo failed</TD><TD>上传图片失败</TD></TR>
     <TR><TD>-4</TD><TD>user give up the current operation</TD><TD>用户放弃当前操作</TD></TR>
     <TR><TD>-5</TD><TD>client internal error</TD><TD>客户端内部处理错误</TD></TR>
     </TABLE>
 */
- (void)onResp:(QQBaseResp *)resp {
    
    NSLog(@"resp.type:%d,resp.result:%@,resp.errorDescription:%@",resp.type,resp.result,resp.errorDescription);

    HYJShareResponse *shareResponse = [[HYJShareResponse alloc] init];
    if (resp.type == ESHOWMESSAGEFROMQQREQTYPE) {
        if (resp.result.integerValue == 0) { //成功
            //
            shareResponse.responseState = HYJShareResponseStateSuccess;
            shareResponse.responseMsg = @"qq share success";
        }else if(resp.result.integerValue == -4) { //取消
            //
            shareResponse.responseState = HYJShareResponseStateCancel;
            shareResponse.responseMsg = @"qq share cancel";
        }else { //失败
            NSLog(@"errCode:%@,errStr:%@",resp.result,resp.errorDescription);
            shareResponse.responseState = HYJShareResponseStateFail;
            //返回qq的错误提示字符串
            shareResponse.responseMsg = resp.errorDescription;
        }
    }
    //
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveShareResponse:)]) {
        [self.delegate didReceiveShareResponse:shareResponse];
    }

}

- (void)isOnlineResponse:(NSDictionary *)response {

}

@end


//#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//#pragma mark - HYJSMSShareManager
//
//@implementation HYJSMSShareManager
//
//- (void)shareSMSWithDataModel:(HYJShareModel *)shareModel {
//    
//    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    
//    //Check whether the current device is configured for sending SMS messages
//    if (![self checkDevice:@"iPhone"] || !messageClass || ![messageClass canSendText]) {
//        [HYJShareUI showToastViewWithContent:@"设备不支持发短信功能！" andRect:CGRectMake((kScreenViewWidth - 200)/2, (kScreenViewHeight - 200)/2, 200, 50) andTime:1.5f andObjectView:window];
//        return;
//    }
//    
//    // 设置导航栏的颜色及标题颜色
//    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setTranslucent:NO];
//    [UINavigationBar appearance].titleTextAttributes =@{NSForegroundColorAttributeName:[UIColor blackColor]};
//    //
//    MFMessageComposeViewController *smspicker = [[MFMessageComposeViewController alloc] init];
//    smspicker.messageComposeDelegate = (id<MFMessageComposeViewControllerDelegate>)self;
//    //设置短信分享的内容
//    smspicker.body = shareModel.text;
//
//    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
//    [appdelegate.navigationController presentViewController:smspicker animated:YES completion:nil];
//    
//}
//
//#pragma mark sms delegate~
//- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
//    //
//    AppDelegate *appdelegate = [UIApplication sharedApplication].delegate;
//    [appdelegate.navigationController dismissViewControllerAnimated:YES completion:nil];
//    
//    HYJShareResponse *shareResponse = [[HYJShareResponse alloc] init];
//
//    if (result == MessageComposeResultSent) {
//        //
//        shareResponse.responseState = HYJShareResponseStateSuccess;
//        shareResponse.responseMsg = @"sms share success";
//    }else if (result == MessageComposeResultCancelled) {
//        //
//        shareResponse.responseState = HYJShareResponseStateCancel;
//        shareResponse.responseMsg = @"sms share cancel";
//    }else {
//        NSLog(@"%d",result);
//        shareResponse.responseState = HYJShareResponseStateFail;
//        //返回微信的错误提示字符串
//        shareResponse.responseMsg = @"sms share failed";
//    }
//    //
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveShareResponse:)]) {
//        [self.delegate didReceiveShareResponse:shareResponse];
//    }
//    
//}
//
/////判断是否是iphone~yes:是，no:不是
//-(bool)checkDevice:(NSString*)name {
//    
//    NSString* deviceModel = [UIDevice currentDevice].model;
//    return [deviceModel rangeOfString:name].location != NSNotFound;
//}
//
//@end


#pragma mark - HYJShareResponse
@implementation HYJShareResponse

@end




