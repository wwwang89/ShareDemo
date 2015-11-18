//
//  HYJShareView.m
//  HYJManager
//
//  Created by huyujin on 15/10/26.
//  Copyright © 2015年 HYJ. All rights reserved.
//

#import "HYJShareUI.h"
#import "HYJHelper.h"

#define ShareButtonMargin (kScreenViewWidth-4*kShareButtonWidth)/5

static const NSInteger kDefaultTag = 20151027;
static const NSInteger kCancelButtonTag = 20151026;

static const NSInteger kShareWindowHeight = 300;               // 分享窗口高度~
static const NSInteger kShareTitleLabelHeight = 50;            // 分享标题高度~
static const NSInteger kShareCancelButtonHeight = 50;          //分享取消栏高度~
static const NSInteger kShareButtonWidth = 60;                 // 图标宽度~
static const NSInteger kShareButtonHeight = kShareButtonWidth; // 图标高度~
static const NSInteger kShareIconDescHeight = 20;              // 图标文字高度~
static const NSInteger kShateSeperateLineMargin = 9;


/**
 * 30 + (65+25+5) + 50
 * 40
 * 65+25+5 = 95
 * 10
 * 10
 * 95
 * 50
 */
@interface HYJShareUI()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSDictionary *shareDic;

//
@property (nonatomic, strong) UIView *shareWindowBackView;

@property (nonatomic, strong) UIView *shareWindow;

@property (nonatomic, strong) UIView *shareWindowArea;

// 分享栏View
@property (nonatomic, strong) UIScrollView *shareScrollView;

@property (nonatomic, strong) UIScrollView *secondShareView;

@end

@implementation HYJShareUI

+ (HYJShareUI *)sharedInstance {
    
    static HYJShareUI *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HYJShareUI alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        //初始化字典~
        _shareDic = @{@1:@"新浪微博",@2:@"微信好友",@3:@"朋友圈",@4:@"手机QQ",@5:@"QQ空间",@6:@"短信",@7:@"邮件",@8:@"复制链接"};
    }
    
    return self;
}


- (void)createShareWindowWithFirstShareTypes:(NSArray *)firstShareTypes FirstRowNormalImages:(NSArray *)firstRowNormalImages FirstRowHighlightImages:(NSArray *)firstRowHighlightImages
                            SecondShareTypes:(NSArray *)secondShareTypes SecondRowNormalImages:(NSArray *)secondRowNormalImages SecondRowHighlightImages:(NSArray *)secondRowHighlightImages {
    
    //进入后台，分享栏消除~
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAction) name:@"KApplicationDidEnterBackground" object:nil];
    
    //分享窗口背景view:
    UIView *shareWindowBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenViewWidth, kScreenViewHeight)];
    _shareWindowBackView = shareWindowBackView;
    _shareWindowBackView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
    [[UIApplication sharedApplication].keyWindow addSubview:_shareWindowBackView];
    //
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchView:)];
    [self.shareWindowBackView addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.delegate = self;
    
    //
    UIView *shareWindow = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenViewHeight, kScreenViewWidth, kShareWindowHeight)];
    _shareWindow = shareWindow;
    
    _shareWindow.backgroundColor = [HYJHelper colorWithHexString:@"#f0f0f0"];;
    [_shareWindowBackView addSubview:_shareWindow];
    
    UIView *shareWindowArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.shareWindow.frame.size.width, self.shareWindow.frame.size.height-kShareCancelButtonHeight)];
    _shareWindowArea = shareWindowArea;
    _shareWindowArea.backgroundColor =[HYJHelper colorWithHexString:@"#f0f0f0"];;
    _shareWindowArea.layer.cornerRadius = 2;
    [_shareWindow addSubview:_shareWindowArea];
    
    UILabel *shareTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, _shareWindowArea.frame.size.width, 20)];
    shareTitleLbl.text = @"分享到";
    shareTitleLbl.textColor = [HYJHelper colorWithHexString:@"#333333"];
    shareTitleLbl.textAlignment = NSTextAlignmentCenter;
    shareTitleLbl.font = [UIFont systemFontOfSize:17.0f];
    [_shareWindowArea addSubview:shareTitleLbl];
    //
    [self addFirstScrollViewWithShareTypes:firstShareTypes normalImages:firstRowNormalImages highlightImages:firstRowHighlightImages];
    [self addSecondScrollViewWithShareTypes:secondShareTypes normalImages:secondRowNormalImages highlightImages:secondRowHighlightImages];
    
    //取消button
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat yPosition = self.secondShareView.frame.origin.y+self.secondShareView.frame.size.height+kShateSeperateLineMargin*2;
    cancelBtn.frame = CGRectMake(0, yPosition, _shareWindow.frame.size.width, kShareWindowHeight-yPosition);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[HYJHelper colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [HYJHelper colorWithHexString:@"#ffffff"];
    cancelBtn.layer.cornerRadius = 2;
    [cancelBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.tag = kCancelButtonTag;
    [_shareWindow addSubview:cancelBtn];
    
    //
    [UIView animateWithDuration:0.3 animations:^{
        _shareWindow.frame = CGRectMake(0, kScreenViewHeight-kShareWindowHeight-5, kScreenViewWidth, kShareWindowHeight+5);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            _shareWindow.frame = CGRectMake(0, kScreenViewHeight-kShareWindowHeight, kScreenViewWidth, kShareWindowHeight);
        }];
    }];
    
}


- (void)createShareWindow {
    
    NSArray *firstRowHighlightImages = @[@"share_wechat_friends", @"share_wechat_quan", @"share_qq_friends",@"share_qq_zone"];
    NSArray *firstRowNormalImages = @[@"share_wechat_friends", @"share_wechat_quan", @"share_qq_friends",@"share_qq_zone"];
    //
    NSArray *firstShareTypes = @[@2,@3,@4,@5];
    
    NSArray *secondRowHighlightImages = @[@"share_sina_weibo"];
    NSArray *secondRowNormalImages = @[@"share_sina_weibo"];
    NSArray *secondShareTypes = @[@1];
    
    [self createShareWindowWithFirstShareTypes:firstShareTypes FirstRowNormalImages:firstRowNormalImages FirstRowHighlightImages:firstRowHighlightImages
                              SecondShareTypes:secondShareTypes SecondRowNormalImages:secondRowNormalImages SecondRowHighlightImages:secondRowHighlightImages];
    
}

- (void)touchView:(UITapGestureRecognizer *)sender {
    [self cancelAction];
}

// UIGestureRecognizer delegate~
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Disallow recognition of tap gestures in the segmented control.
    if (touch.view != self.shareWindowBackView) {
        return NO;
    }
    return YES;
}

- (void)addFirstScrollViewWithShareTypes:(NSArray *)shareTypes normalImages:(NSArray *)normalImages highlightImages:(NSArray *)highlightImages {
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kShareTitleLabelHeight, self.shareWindowArea.frame.size.width, kShareButtonHeight+kShareIconDescHeight+5)];
    scrollView.delegate = (id<UIScrollViewDelegate>)self;
    scrollView.contentSize = CGSizeMake(self.shareWindowArea.frame.size.width , kShareButtonHeight + kShareIconDescHeight);
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    self.shareScrollView = scrollView;
    [self.shareWindowArea addSubview:self.shareScrollView];
    
    CGFloat buttonX;
    for (int i = 0; i < shareTypes.count; i++) {
        
        if (i < 4) {
            buttonX = ShareButtonMargin + kShareButtonWidth * i + ShareButtonMargin * i;
        } else {
            buttonX = ShareButtonMargin * 3 + kShareButtonWidth * i + ShareButtonMargin * (i - 1);
        }
        //
        NSString *name = self.shareDic[shareTypes[i]];
        [self addButtonWithFrame:CGRectMake(buttonX, 0, kShareButtonWidth, kShareButtonHeight+kShareIconDescHeight + 6) normalStateImageName:normalImages[i] highLightImageName:highlightImages[i] imageSize:CGSizeMake(kShareButtonWidth, kShareButtonWidth) title:name titleFontSize:12.0f titleColorStr:@"#333333" textAndImageDistance:6 tarGet:self action:@selector(buttonAction:) inSuperView:self.shareScrollView withTag:kDefaultTag+[shareTypes[i] integerValue]];
    }
    
}

- (void)addSecondScrollViewWithShareTypes:(NSArray *)shareTypes normalImages:(NSArray *)normalImages highlightImages:(NSArray *)highlightImages {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.shareScrollView.frame.origin.y+self.shareScrollView.frame.size.height+kShateSeperateLineMargin*2, self.shareWindowArea.frame.size.width, kShareButtonHeight+kShareIconDescHeight+5)];
    scrollView.delegate = (id<UIScrollViewDelegate>)self;
    scrollView.contentSize = CGSizeMake(self.shareWindowArea.frame.size.width, kShareButtonHeight + kShareIconDescHeight);
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    //
    self.secondShareView = scrollView;
    [self.shareWindowArea addSubview:self.secondShareView];
    
    CGFloat buttonX;
    for (int i = 0; i < shareTypes.count; i++) {
        
        if (i < 4) {
            buttonX = ShareButtonMargin + kShareButtonWidth * i + ShareButtonMargin * i;
        } else {
            buttonX = ShareButtonMargin * 3 + kShareButtonWidth * i + ShareButtonMargin * (i - 1);
        }
        //
        NSString *name = self.shareDic[shareTypes[i]];
        [self addButtonWithFrame:CGRectMake(buttonX, 0, kShareButtonWidth, kShareButtonHeight+kShareIconDescHeight + 6) normalStateImageName:normalImages[i] highLightImageName:highlightImages[i] imageSize:CGSizeMake(kShareButtonWidth, kShareButtonWidth) title:name titleFontSize:13.0f titleColorStr:@"#333333" textAndImageDistance:6 tarGet:self action:@selector(buttonAction:) inSuperView:self.secondShareView withTag:kDefaultTag+[shareTypes[i] integerValue]];
    }
    
}

///button事件~
- (void)buttonAction:(UIButton *)sender {
    
    NSInteger index = sender.tag - kDefaultTag;
    if (index>0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(shareToPlatform:)]) {
            [self.delegate shareToPlatform:index];
        }
    }else {
        [self cancelAction];
    }
}

- (void)cancelAction {
    
    _shareWindowBackView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.2 animations:^{
        _shareWindowBackView.frame = CGRectMake(5, kScreenViewHeight, kScreenViewWidth-10, kShareWindowHeight);
    } completion:^(BOOL finished) {
        [_shareWindowBackView removeFromSuperview];
    }];
}

//
- (void)addButtonWithFrame: (CGRect) frame normalStateImageName: (NSString *) normalImageName highLightImageName: (NSString *) hightLightImageName imageSize: (CGSize) imageSize title: (NSString *) title titleFontSize:(CGFloat) fontSize titleColorStr: (NSString *) titleSizeColorStr textAndImageDistance: (CGFloat) distance tarGet: (id)target action: (SEL) action inSuperView: (UIView *) superView withTag: (NSInteger) tag
{
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[self getImageWithTotleSize:frame.size fromImageName:normalImageName imageSize:imageSize andText:title fontSize:fontSize andTextColorString:titleSizeColorStr textAndImageDistance: distance] forState:UIControlStateNormal];
    [shareButton setImage:[self getImageWithTotleSize:frame.size fromImageName:hightLightImageName imageSize:imageSize andText:title fontSize:fontSize andTextColorString:titleSizeColorStr textAndImageDistance: distance] forState:UIControlStateHighlighted];
    shareButton.frame = frame;
    [shareButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:shareButton];
    [shareButton setTag:tag];
}

- (UIImage *)getImageWithTotleSize: (CGSize) totalSize fromImageName: (NSString *)imageName imageSize: (CGSize) size andText: (NSString *) text fontSize: (CGFloat) fontSize andTextColorString: (NSString *) colorStr textAndImageDistance: (CGFloat) distance
{
    UIView * aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, totalSize.width, totalSize.height)];
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((totalSize.width-size.width)/2.0, (totalSize.height-size.height-fontSize-distance)/2.0 , size.width, size.height)];
    [imageView setImage:[UIImage imageNamed:imageName]];
    [aView addSubview:imageView];
    
    UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.frame.origin.y + size.height +distance, totalSize.width, fontSize)];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    [textLabel setText:text];
    [textLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [textLabel setTextColor:[HYJHelper colorWithHexString:colorStr]];
    [aView addSubview:textLabel];
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    
    UIGraphicsBeginImageContextWithOptions(totalSize, NO, 0.0);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//
+ (UIImage *)compressImage:(UIImage *)sourceImage toTargetWidth:(CGFloat)defineWidth {
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = (targetWidth / width) * height;
    
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [sourceImage drawInRect:CGRectMake(0,0,targetWidth, targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

//在某个view上面加一个toast提示
+ (void)showToastViewWithContent:(NSString *)content andRect:(CGRect)rect andTime:(float)time andObjectView:(UIView *)parentView {
    if ([parentView viewWithTag:1234554321]) {
        UIView * tView = [parentView viewWithTag:1234554321];
        [tView removeFromSuperview];
    }
    
    UIImageView * toastView = [[UIImageView alloc] initWithFrame:rect];
    
    NSString *imageName = [NSString stringWithFormat:@"toastBackImage.png"];
    
    if ([[[UIDevice currentDevice]systemVersion ] floatValue]>=7.0) {
        imageName = [NSString stringWithFormat:@"toastBackImage_ios7.png"];
    }
    
    
    if ([UIImage imageNamed:imageName]) {
        [toastView setImage:[[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    }else{
        [toastView setBackgroundColor:[UIColor blackColor]];
    }
    
    [toastView.layer setCornerRadius:5.0f];
    [toastView.layer setMasksToBounds:YES];
    [toastView setAlpha:1.0f];
    [toastView setTag:1234554321];
    [parentView addSubview:toastView];
    
    
    CGSize labelSize = [content sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize: CGSizeMake( rect.size.width ,MAXFLOAT) lineBreakMode: NSLineBreakByWordWrapping];
    //UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, rect.size.width-20, labelSize.height)];
    //UILabel * contentLabel = [[UILabel alloc] initWithFrame:toastView.bounds];
    if (labelSize.height > rect.size.height) {
        [toastView setFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, labelSize.height)];
    }
    UILabel * contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, toastView.frame.size.width - 20, toastView.frame.size.height)];
    [contentLabel setText:content];
    [contentLabel setTextColor:[UIColor whiteColor]];
    [contentLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [contentLabel setTextAlignment:NSTextAlignmentCenter];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    [contentLabel setNumberOfLines:0];
    [contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [toastView addSubview:contentLabel];
    
    if (time>0.01) {
        [self performSelector:@selector(removeToastViewFromParentView:) withObject:parentView afterDelay:time];
    }
    
}

///
+ (void)removeToastViewFromParentView:(id)sender
{
    UIView * parentView = (UIView *)sender;
    UIView * toastView = [parentView viewWithTag:1234554321];
    [toastView removeFromSuperview];
    toastView = nil;
    
}




@end


