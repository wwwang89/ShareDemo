//
//  HYJShareManager.h
//  HYJ
//
//  Created by huyujin on 15-10-26.
//
//  分享~

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <MessageUI/MessageUI.h>

#import "HYJShareContants.h"
#import "HYJShareModel.h"

/**
 * 响应分享的信息~
 */
@interface HYJShareResponse : NSObject

/// 响应状态
@property (nonatomic, assign) HYJResponseState responseState;
/// 响应信息
@property (nonatomic, strong) NSString *responseMsg;

@end


@protocol HYJShareManagerDelegate <NSObject>

- (void)didReceiveShareResponse:(HYJShareResponse *)response;

@end


/**
 *
 */
@interface HYJShareManager : NSObject

// 创建单例HYJShareManager
+ (HYJShareManager *)sharedInstance;

///
- (BOOL)handleOpenURL:(NSURL *)url;

/**
 *	@brief	分享
 *
 *	@param 	shareModel 	分享的数据model
 */
- (void)shareWithDataModel:(HYJShareModel *)shareModel;



@end


/** 新浪微博分享Manager
 *
 * 新浪微博官方文档：https://github.com/sinaweibosdk/weibo_ios_sdk
 * 微博客户端程序和第三方应用之间传递的消息结构
 * 一个消息结构由三部分组成：文字、图片和多媒体数据。三部分内容中至少有一项不为空，图片和多媒体数据不能共存。
 */

@interface HYJSinaWeiBoShareManager : NSObject <WeiboSDKDelegate>

@property (nonatomic,weak) id<HYJShareManagerDelegate> delegate;

- (void)shareWeiBoWithDataModel:(HYJShareModel *)shareModel;

@end


/** 微信分享manager~
 *
 * 微信官方文档：https://open.weixin.qq.com/zh_CN/htmledition/res/dev/document/sdk/ios/annotated.html
 */
@interface HYJWeChatShareManager : NSObject <WXApiDelegate>

@property (nonatomic,weak) id<HYJShareManagerDelegate> delegate;

- (void)shareWeChatWithDataModel:(HYJShareModel *)shareModel
                         inScene:(int)scene;

@end


/** qq分享manager~
 *
 * qq官方文档： http://wiki.connect.qq.com/ios_sdk_api_%E4%BD%BF%E7%94%A8%E8%AF%B4%E6%98%8E#2.2.E5.88.86.E4.BA.AB.E5.88.B0QQ.E7.A9.BA.E9.97.B4
 */

@interface HYJQQShareManager : NSObject <QQApiInterfaceDelegate>

@property (nonatomic,weak) id<HYJShareManagerDelegate> delegate;


- (void)shareQQWithDataModel:(HYJShareModel *)shareModel shareType:(HYJShareType)shareType;

@end


///** 短信分享manager~
// *
// */
//
//@interface HYJSMSShareManager : NSObject <MFMessageComposeViewControllerDelegate>
//
//@property (nonatomic,weak) id<HYJShareManagerDelegate> delegate;
//
//
//- (void)shareSMSWithDataModel:(HYJShareModel *)shareModel;
//
//@end





