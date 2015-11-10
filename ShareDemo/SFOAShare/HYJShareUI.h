//
//  HYJShareUI.h
//  HYJManager
//
//  Created by huyujin on 15/10/26.
//  Copyright © 2015年 HYJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HYJShareContants.h"

//
@protocol HYJShareUIDelegate <NSObject>

- (void)shareToPlatform:(HYJShareType)shareType;

@end


@interface HYJShareUI :NSObject

@property (nonatomic, weak) id<HYJShareUIDelegate> delegate;

+ (HYJShareUI *)sharedInstance;

/** 自定义二栏分享窗口~
 * firstShareTypes:对应于 <code>HYJShareType</code>中的索引值~
 * firstRowNormalImages：正常情况下图标图片名(NSString) 
 * firstRowHighlightImages:高亮情况下图标图片名(NSString)
 * 
 * 该方法的应用可以参考 <code>createShareWindow</code> 的实现
 */
- (void)createShareWindowWithFirstShareTypes:(NSArray *)firstShareTypes FirstRowNormalImages:(NSArray *)firstRowNormalImages FirstRowHighlightImages:(NSArray *)firstRowHighlightImages
                            SecondShareTypes:(NSArray *)secondShareTypes SecondRowNormalImages:(NSArray *)secondRowNormalImages SecondRowHighlightImages:(NSArray *)secondRowHighlightImages;

/**
 * 创建默认分享窗口~
 */
- (void)createShareWindow;

- (void)cancelAction;

//
+ (UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)defineWidth;
//
+ (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize;

//
+ (void)showToastViewWithContent:(NSString *)content andRect:(CGRect)rect andTime:(float)time andObjectView:(UIView *)parentView;

@end
