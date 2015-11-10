//
//  SouFunShareContants.h
//  SouFunManager
//
//  Created by huyujin on 15/10/29.
//  Copyright © 2015年 SouFun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kScreenViewHeight                           [UIScreen mainScreen].bounds.size.height
#define kScreenViewWidth                            [UIScreen mainScreen].bounds.size.width

/** 新浪~
 App Key：1946642536
 App Secret：9d9a84f89922427d95c7239f8c69c2a8
 */
#define SinaWeiBoAppKey         @"1946642536"

/** 微信
 AppID：wx89f8c82f07f15063
 AppSecret：d4624c36b6795d1d99dcf0547af5443d
 */
#define WeChatAppID             @"wx89f8c82f07f15063"

/** qq~
 APP ID:1104934496
 APP KEY:iLK8C2E6SzpW7ZGj
 */
#define QQAppID                 @"1104934496"


typedef NS_ENUM(NSUInteger, SouFunShareType) {
    SFShareTypeDefault = 0,           /**< 默认  */
    SFShareTypeSinaWeiBo = 1,         /**< 新浪微博 */
    SFShareTypeWeixinSession = 2,     /**< 微信好友 */
    SFShareTypeWeixinTimeline = 3,    /**< 微信朋友圈 */
    SFShareTypeQQFriend = 4,          /**< QQ好友 */
    SFShareTypeQQZone = 5,            /**< QQ空间 */
    SFShareTypeSMS = 6,               /**< 短信 */
    SFShareTypeMail = 7,              /**< 邮件 */
    SFShareTypeCopyLink = 8           /**< 复制链接 */
};

typedef NS_ENUM(NSUInteger, SouFunResponseState) {
    SFShareResponseStateSuccess = 1, /**< 成功 */
    SFShareResponseStateFail = 2,    /**< 失败 */
    SFShareResponseStateCancel = 3   /**< 取消 */
};


typedef NS_ENUM(NSUInteger, SouFunShareModelType) {
    SFShareModelText = 1,        /**< 纯文字 */
    SFShareModelPic = 2,         /**< 图片 */
    SFShareModelWebpage = 3,     /**< 网页 */
    SFShareModelVideo = 4        /**< 视频 */
};




