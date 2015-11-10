//
//  HYJHelper.h
//  ShareDemo
//
//  Created by huyujin on 15/11/10.
//  Copyright © 2015年 huyujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SF_COLOR(RED, GREEN, BLUE, ALPHA)	[UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:ALPHA]

@interface HYJHelper : NSObject

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

@end
