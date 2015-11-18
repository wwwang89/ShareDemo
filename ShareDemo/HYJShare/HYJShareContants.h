//
//  HYJShareContants.h
//  HYJManager
//
//  Created by huyujin on 15/10/29.
//  Copyright © 2015年 HYJ. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kScreenViewHeight                           [UIScreen mainScreen].bounds.size.height
#define kScreenViewWidth                            [UIScreen mainScreen].bounds.size.width

/** 新浪~
 *
 */
#define SinaWeiBoAppKey         @"2045436852"

/** 微信
 *
 */
#define WeChatAppID             @"wxd930ea5d5a258f4f"

/** qq~
 *
 */
#define QQAppID                 @"222222"


typedef NS_ENUM(NSUInteger, HYJShareType) {
    HYJShareTypeDefault = 0,           /**< 默认  */
    HYJShareTypeSinaWeiBo = 1,         /**< 新浪微博 */
    HYJShareTypeWeixinSession = 2,     /**< 微信好友 */
    HYJShareTypeWeixinTimeline = 3,    /**< 微信朋友圈 */
    HYJShareTypeQQFriend = 4,          /**< QQ好友 */
    HYJShareTypeQQZone = 5,            /**< QQ空间 */
    HYJShareTypeSMS = 6,               /**< 短信 */
    HYJShareTypeMail = 7,              /**< 邮件 */
    HYJShareTypeCopyLink = 8           /**< 复制链接 */
};

typedef NS_ENUM(NSUInteger, HYJResponseState) {
    HYJShareResponseStateSuccess = 1, /**< 成功 */
    HYJShareResponseStateFail = 2,    /**< 失败 */
    HYJShareResponseStateCancel = 3   /**< 取消 */
};


typedef NS_ENUM(NSUInteger, HYJShareModelType) {
    HYJShareModelText = 1,        /**< 纯文字 */
    HYJShareModelPic = 2,         /**< 图片 */
    HYJShareModelWebpage = 3,     /**< 网页 */
    HYJShareModelVideo = 4        /**< 视频 */
};




