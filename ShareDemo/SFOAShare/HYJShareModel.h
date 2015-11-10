//
//  HYJShareModel.h
//  HYJManager
//
//  Created by huyujin on 15/10/26.
//  Copyright © 2015年 HYJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HYJShareContants.h"

@class HYJShareMediaModel;


/**
 一个消息结构由三部分组成：文字、图片和多媒体数据~
 
 */
@interface HYJShareModel : NSObject

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) HYJShareMediaModel *mediaModel;

@property (nonatomic, assign) HYJShareModelType modelType; //分享的类型

@end


/**
 消息中包含的多媒体数据对象类
 多媒体数据对象，可以为video，webpage等。
 */
@interface HYJShareMediaModel: NSObject

/** 多媒体内容标题 */
@property (nonatomic, strong) NSString *title;

/** 多媒体内容描述 */
@property (nonatomic, strong) NSString *desc;

/** 多媒体内容缩略图 */
@property (nonatomic, strong) NSData *thumbnailData;

@end


/**
 消息中包含的图片数据对象
 */
@interface HYJShareImageModel : HYJShareMediaModel

/**图片真实数据内容 */
@property (nonatomic, strong) NSData *imageData;

/** 图片url */
@property (nonatomic, strong) NSString  *imageUrl;

/** */
@property (nonatomic,strong) UIImage *image;

@end



/**
 *  
 */
@interface HYJShareVideoModel: HYJShareMediaModel

/** 视频网页的url地址 */
@property (nonatomic, strong) NSString *videoUrl;
/** 视频lowband网页的url地址 */
@property (nonatomic, strong) NSString *videoLowBandUrl;

@end

/**
 消息中包含的网页数据对象
 */
@interface HYJShareWebPageModel : HYJShareMediaModel
/** 网页的url地址 */
@property (nonatomic, strong) NSString *webpageUrl;

@end

