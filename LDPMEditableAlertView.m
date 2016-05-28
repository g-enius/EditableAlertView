//
//  LDPMEditableAlertView.m
//  PreciousMetals
//
//  Created by gaoyu on 15/8/29.
//  Updated by wangchao on 15/10/08
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "LDPMEditableAlertView.h"

static CGFloat const kLDPMEditableAlertViewDefaultButtonHeight       = 44;
static CGFloat const kLDPMEditableAlertViewDefaultTitleHeight        = 44;
static CGFloat const kLDPMEditableAlertViewDefaultButtonSpacerHeight = 0.5;
static CGFloat const kLDPMEditableAlertViewCornerRadius              = 5;
static CGFloat const kLDPMEditableAlertViewAnimationShortDuration    = 0.3;
static CGFloat const kLDPMEditableAlertViewAnimationLongDuration     = 0.4;
static CGFloat const kLDPMEditableAlertViewAlertAnimationDuration    = 0.3;
static CGFloat const kLDPMEditableAlertViewMaskViewAnimationDuration = 0.2;
static CGFloat const kLDPMEditableAlertViewDefaultActionSheetButonSpace = 0.5;//added by wangchao
static CGFloat const kLDPMEditableAlertViewLastActionSheetButonSpace = 10;//added by wangchao
#define kLDPMEditableAlertViewSepLineColor [NPMColor seplineColor]

@interface LDPMEditableAlertView ()

@property(nonatomic,assign) CGFloat buttonHeight;
@property(nonatomic,assign) CGFloat titleHeight;
@property(nonatomic,assign) CGFloat buttonSpacerHeight;
@property(nonatomic,strong) UIView *dialogView;
@property(nonatomic,strong) UILabel *titleLabel;
@property(nonatomic,assign) BOOL isAnimating;

@end

@implementation LDPMEditableAlertView

#pragma mark - init & settings
- (instancetype)initWithTitle:(NSString*)title
                   parentView:(UIView*)parentView
                containerView:(UIView*)containerView
                 buttonTitles:(NSArray*)titlesArray {
    if (self = [super initWithFrame:[UIApplication sharedApplication].delegate.window.bounds]) {
        self.appearType = LDPMConfirmAlertAnimationAlert;
        self.cancelType = LDPMConfirmAlertAnimationMoveOutFromCenter;
        self.doneType = LDPMConfirmAlertAnimationMoveOutFromBottom;
        self.buttonTitles = @[@"取消",@"确定"];
        self.isBackgroundTapCancel = YES;
        _alertTitle = title;
        _parentView = parentView;
        _containerView = containerView;
        if (titlesArray && titlesArray.count > 0) {
            _buttonTitles = titlesArray;
        }
    }
    return self;
}

- (instancetype)initWithTitle:(NSString*)title
                containerView:(UIView*)containerView
                 buttonTitles:(NSArray*)titlesArray {
    return [self initWithTitle:title parentView:nil containerView:containerView buttonTitles:titlesArray];
}

- (id)initWithFrame:(CGRect)frame
{
    frame = [UIApplication sharedApplication].delegate.window.bounds;
    self = [super initWithFrame:frame];
    if (self) {
        self.appearType = LDPMConfirmAlertAnimationAlert;
        self.cancelType = LDPMConfirmAlertAnimationMoveOutFromCenter;
        self.doneType = LDPMConfirmAlertAnimationMoveOutFromBottom;
        self.buttonTitles = @[@"取消",@"确定"];
        self.isBackgroundTapCancel = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isBackgroundTapCancel) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskBackgroundTapped:)];
        tap.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self addGestureRecognizer:tap];
    }
}

#pragma mark - gesture
- (void)maskBackgroundTapped:(UITapGestureRecognizer *)tap {
    if (!self.isAnimating) {
        UIButton *button = [[UIButton alloc] init];
        button.tag = [self cancelButtonIndex];
        [self LDPMEditableAlertViewdialogButtonTouchUpInside:button];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;
{
    if([touch.view isDescendantOfView:self.dialogView])
    {
        return NO;
    }
    return YES;
}

#pragma mark - ui setter
- (void)setContainerView:(UIView *)containerView {
    if (self.containerView) {
        [self.containerView removeFromSuperview];
    }
    _containerView = containerView;
}

#pragma mark - display methods
- (void)show
{
    self.dialogView = [self createDialogView];
    //edit by wangchao 移到createDialogView里
    //self.dialogView.backgroundColor = [UIColor whiteColor];
    
// 注掉无用代码
//    self.dialogView.layer.shouldRasterize = YES;
//    self.dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
//    self.layer.shouldRasterize = YES;
//    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    [self addSubview:self.dialogView];
    
    if (self.parentView != NULL) {
        [self.parentView addSubview:self];
    } else {
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        switch (interfaceOrientation) {
            case UIInterfaceOrientationLandscapeLeft:
                self.transform = CGAffineTransformMakeRotation(M_PI * 270.0 / 180.0);
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.transform = CGAffineTransformMakeRotation(M_PI * 90.0 / 180.0);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                self.transform = CGAffineTransformMakeRotation(M_PI * 180.0 / 180.0);
                break;
            default:
                break;
        }
        
        [self setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }
    
    switch (self.appearType) {
        case LDPMConfirmAlertAnimationAlert:
        {
            [self beginAlertAnimationWithCompletion:nil];
            break;
        }
        case LDPMConfirmAlertAnimationSheet:
        case LDPMConfirmAlertAnimationMoveInFromTop:
        {
            [self beginStraightLineMoveAnimaiton:self.appearType completion:nil];
            break;
        }
        case LDPMConfirmAlertAnimationMoveInFromCenter:
        {
            [self beginScaleAnimation:self.appearType completion:nil];
            break;
        }
        default:
        {
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
            break;
        }
    }
}

#pragma mark - construct view methods
- (UIView *)createDialogView
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    if (!self.containerView) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.titleHeight , 300, 150)];
    }
    
    if (self.alertTitle && ![self.alertTitle isEqualToString:@""]) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.titleHeight-30, dialogSize.width, 30)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        self.titleLabel.text = self.alertTitle;
        self.titleLabel.textColor = [UIColor colorWithRGB:0x000000];
    }
    
    self.containerView.origin = CGPointMake(0, self.titleHeight);
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];

    
    //added by wangchao
    if (self.appearType == LDPMConfirmAlertAnimationSheet) {
        dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) - 11, dialogSize.width, dialogSize.height)];
        dialogContainer.backgroundColor = [UIColor colorWithRGBA:0x00000000];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = dialogContainer.bounds;
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(kLDPMEditableAlertViewCornerRadius, kLDPMEditableAlertViewCornerRadius)].CGPath;
        dialogContainer.layer.mask = maskLayer;
        
    } else {
        dialogContainer.backgroundColor = [UIColor whiteColor];
        CGFloat cornerRadius = kLDPMEditableAlertViewCornerRadius;
        dialogContainer.layer.cornerRadius = cornerRadius;
    }

    
    [dialogContainer addSubview:self.containerView];
    [dialogContainer addSubview:self.titleLabel];
    [self addButtonsToView:dialogContainer];
    
    return dialogContainer;
}

- (void)addButtonsToView:(UIView *)container
{
    if (!self.buttonTitles) {
        return;
    }
    NSInteger titleCount = self.buttonTitles.count;
    
    for (int i = 0; i < [self.buttonTitles count]; i++) {
        UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [createButton addTarget:self action:@selector(LDPMEditableAlertViewdialogButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [createButton setTag:i];
        [createButton setTitle:[self.buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        UIColor *titleColor = titleCount > 1 ? [NPMColor grayTextColor] : [NPMColor lightBlackTextColor];
        [createButton setTitleColor:titleColor forState:UIControlStateNormal];
        [createButton setTitleColor:[titleColor copyWithAlpha:0.5f] forState:UIControlStateHighlighted];
        [createButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        
        //edit by wangchao
        if (self.appearType == LDPMConfirmAlertAnimationSheet) {
            CGFloat buttonWidth = container.bounds.size.width;
            CGFloat buttonY = 0;
            if (i == self.buttonTitles.count - 1) {
                buttonY = CGRectGetMaxY(self.containerView.bounds) + i * self.buttonHeight + (i + 1) * kLDPMEditableAlertViewDefaultActionSheetButonSpace + kLDPMEditableAlertViewLastActionSheetButonSpace;
                createButton.layer.cornerRadius = kLDPMEditableAlertViewCornerRadius;
                createButton.frame = CGRectMake(0, buttonY, buttonWidth, self.buttonHeight);
                
            } else {
                buttonY = CGRectGetMaxY(self.containerView.bounds) + i * self.buttonHeight + (i + 1) * kLDPMEditableAlertViewDefaultActionSheetButonSpace;
                createButton.frame = CGRectMake(0, buttonY, buttonWidth, self.buttonHeight);
                if (i == self.confirmButtonIndex) {
                    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                    maskLayer.frame = createButton.bounds;
                    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:createButton.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(kLDPMEditableAlertViewCornerRadius, kLDPMEditableAlertViewCornerRadius)].CGPath;
                    createButton.layer.mask = maskLayer;
                    [createButton setTitleColor:self.confirmButtonColor forState:UIControlStateNormal];
                    [createButton setTitleColor:[self.confirmButtonColor copyWithAlpha:0.5f] forState:UIControlStateHighlighted];
                }
            }
            createButton.backgroundColor = [UIColor whiteColor];
            
        } else if (titleCount <= 2) {
            CGFloat buttonWidth = container.bounds.size.width / [self.buttonTitles count];
            [createButton setFrame:CGRectMake(i * buttonWidth, container.bounds.size.height - self.buttonHeight, buttonWidth, self.buttonHeight)];
            if (i != [self.buttonTitles count] - 1) {
                UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake((i + 1) * buttonWidth, container.bounds.size.height - self.buttonHeight, kLDPMEditableAlertViewDefaultButtonSpacerHeight, self.buttonHeight)];
                [sepLine setBackgroundColor:kLDPMEditableAlertViewSepLineColor];
                [container addSubview:sepLine];
            } else {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, container.bounds.size.height - self.buttonHeight - self.buttonSpacerHeight, container.bounds.size.width, self.buttonSpacerHeight)];
                lineView.backgroundColor = kLDPMEditableAlertViewSepLineColor;
                [container addSubview:lineView];
            }
        } else {
            CGFloat buttonWidth = container.bounds.size.width;
            [createButton setFrame:CGRectMake(0, container.bounds.size.height - (titleCount - i) * (self.buttonHeight + self.buttonSpacerHeight) + self.buttonSpacerHeight, buttonWidth, self.buttonHeight)];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, container.bounds.size.height - (titleCount - i) * (self.buttonHeight + self.buttonSpacerHeight), container.bounds.size.width, self.buttonSpacerHeight)];
            lineView.backgroundColor = kLDPMEditableAlertViewSepLineColor;
            [container addSubview:lineView];
        }
        
        if (createButton.origin.x == 0 && createButton.origin.y + createButton.height == container.height) {
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = createButton.bounds;
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:createButton.bounds byRoundingCorners:    UIRectCornerBottomLeft cornerRadii:CGSizeMake(kLDPMEditableAlertViewCornerRadius, kLDPMEditableAlertViewCornerRadius)].CGPath;
            createButton.layer.mask = maskLayer;
        }
        
        if ((createButton.origin.x + createButton.width) == container.width && createButton.origin.y + self.buttonHeight == container.height) {
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = createButton.bounds;
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:createButton.bounds byRoundingCorners:    UIRectCornerBottomRight cornerRadii:CGSizeMake(kLDPMEditableAlertViewCornerRadius, kLDPMEditableAlertViewCornerRadius)].CGPath;
            createButton.layer.mask = maskLayer;
        }
        
        if (i == [self confirmButtonIndex] && self.appearType != LDPMConfirmAlertAnimationSheet) {
            if (self.confirmButtonColor || self.confirmButtonTextColor) {
                if (self.confirmButtonColor) {
                    [createButton setBackgroundColor:self.confirmButtonColor];
                }
                [createButton setTitleColor:self.confirmButtonTextColor?:[NPMColor whiteTextColor] forState:UIControlStateNormal];
                [createButton setTitleColor:[self.confirmButtonTextColor?:[NPMColor whiteTextColor] copyWithAlpha:0.5f] forState:UIControlStateHighlighted];
            }
        }
        
        [container addSubview:createButton];
    }
}

- (CGSize)countDialogSize
{
    if (self.buttonTitles && [self.buttonTitles count] > 0) {
        self.buttonHeight       = kLDPMEditableAlertViewDefaultButtonHeight;
        self.buttonSpacerHeight = kLDPMEditableAlertViewDefaultButtonSpacerHeight;
    } else {
        self.buttonHeight = 0;
        self.buttonSpacerHeight = 0;
    }
    if (self.alertTitle && ![self.alertTitle isEqualToString:@""]) {
        self.titleHeight = kLDPMEditableAlertViewDefaultTitleHeight + kLDPMEditableAlertViewDefaultButtonSpacerHeight;
    } else {
        self.titleHeight = 0;
    }
    
    CGFloat buttonHeights = 0;
    NSInteger titlesCount = self.buttonTitles.count;
    //added by wangchao
    if (self.appearType == LDPMConfirmAlertAnimationSheet) {
        for (int i = 0 ; i < titlesCount; i ++) {
            buttonHeights += (self.buttonHeight + kLDPMEditableAlertViewDefaultActionSheetButonSpace);
        }
        buttonHeights += kLDPMEditableAlertViewLastActionSheetButonSpace;
    } else if (titlesCount <= 2) {
        buttonHeights += (self.buttonHeight + self.buttonSpacerHeight);
    } else {
        for (int i = 0 ; i < titlesCount; i ++) {
            buttonHeights += (self.buttonHeight + self.buttonSpacerHeight);
        }
    }
    CGFloat dialogWidth = self.containerView.frame.size.width;
    CGFloat dialogHeight = self.containerView.frame.size.height + buttonHeights + self.titleHeight;
    
    return CGSizeMake(dialogWidth, dialogHeight);
}

- (CGSize)countScreenSize
{
    if (self.parentView) {
        CALayer *layer = self.parentView.layer.presentationLayer;
        if (layer) {
            return layer.bounds.size;
        } else {
            return self.parentView.size;
        }
    } else {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            CGFloat tmp = screenWidth;
            screenWidth = screenHeight;
            screenHeight = tmp;
        }
        
        return CGSizeMake(screenWidth, screenHeight);
    }
}

#pragma mark - button action methods
- (void)LDPMEditableAlertViewdialogButtonTouchUpInside:(id)sender {
    if (!self.isAnimating) {
        NSInteger index = ((UIButton*)sender).tag;
        LDPMConfirmAlertAnimationType type = LDPMConfirmAlertAnimationNone;
        if (index == [self cancelButtonIndex]) {
            type = self.cancelType;
        } else if (index == [self confirmButtonIndex]) {
            type = self.doneType;
        }
        
        switch (type) {
            case LDPMConfirmAlertAnimationMoveOutFromCenter:
            {
                [self beginScaleAnimation:type completion:^(BOOL finished) {
                    if (self.dismissBlock != NULL) {
                        self.dismissBlock(self, (int)[sender tag]);
                    }
                }];
            }
                break;
                
            default:
            {
                [self beginStraightLineMoveAnimaiton:type completion:^(BOOL finished) {
                    if (self.dismissBlock != NULL) {
                        self.dismissBlock(self, (int)[sender tag]);
                    }
                }];
            }
                break;
        }
    }
}

- (NSInteger)confirmButtonIndex
{
    //added by wangchao
    if (self.appearType == LDPMConfirmAlertAnimationSheet && self.buttonHeight > 1) {
        return self.buttonTitles.count - 2;
    } else if (self.buttonTitles.count > 2) {
        return 0;
    } else if (self.buttonTitles.count == 2) {
        return 1;
    } else {
        return -1;
    }
}

- (NSInteger)cancelButtonIndex
{
    if (self.appearType == LDPMConfirmAlertAnimationSheet) {
        return self.buttonTitles.count - 1;
    } else if (self.buttonTitles.count > 2) {
        return self.buttonTitles.count - 1;
    } else if (self.buttonTitles.count <= 2 && self.buttonTitles.count > 0) {
        return 0;
    } else {
        return -1;
    }
}

#pragma mark - appear and disappear animation
- (void)beginAlertAnimationWithCompletion:(void (^)(BOOL finished))completion {
    CGAffineTransform startTransform,endTransform;
    CGFloat startAlpha,endAlpha;
    
    endTransform = CGAffineTransformMakeScale(1, 1);
    startTransform = CGAffineTransformMakeScale(0.69, 0.69);
    startAlpha = 0.5;
    endAlpha = 1.;
    
    self.dialogView.transform = startTransform;
    self.dialogView.alpha = startAlpha;
    
    @weakify(self)
    //dispatch_after 0s 为了避免与界面“键盘收起”等动画直接冲突，下一个runloop执行本动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kLDPMEditableAlertViewAlertAnimationDuration
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:50.
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             @strongify(self)
                             self.dialogView.transform = endTransform;
                             self.dialogView.alpha = endAlpha;
                         }
                         completion:^(BOOL finished){
                             if (completion) {
                                 completion(finished);
                             }
                             self.dialogView.alpha = 1.;
                         }];
        [self maskViewAnimationWithAppearType:YES];
    });
}

- (void)beginScaleAnimation:(LDPMConfirmAlertAnimationType)type completion:(void (^)(BOOL finished))completion {
    CGAffineTransform startTransform,endTransform;
    CGFloat startAlpha,endAlpha;
    
    switch (type) {
        case LDPMConfirmAlertAnimationMoveInFromCenter:
        {
            endTransform = CGAffineTransformMakeScale(1, 1);
            startTransform = CGAffineTransformMakeScale(0.01, 0.01);
            startAlpha = 0.5;
            endAlpha = 1.;
            [self maskViewAnimationWithAppearType:YES];
            break;
        }
        case LDPMConfirmAlertAnimationMoveOutFromCenter:
        {
            //用（0，0），会看不到动画执行。
            endTransform = CGAffineTransformMakeScale(0.3, 0.3);
            startTransform = CGAffineTransformIdentity;
            startAlpha = 1.;
            endAlpha = 0.01;
            [self maskViewAnimationWithAppearType:NO];
            break;
        }
        default:
        {
            completion(YES);
            return;
        }
    }
    
    self.dialogView.transform = startTransform;
    self.dialogView.alpha = startAlpha;
    @weakify(self)
    [UIView animateWithDuration:kLDPMEditableAlertViewAnimationShortDuration delay:0.0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         @strongify(self)
                         self.dialogView.transform = endTransform;
                         self.dialogView.alpha = endAlpha;
                     }
                     completion:^(BOOL finished){
                         if (completion) {
                             completion(finished);
                         }
                         self.dialogView.alpha = 1.;
                     }];
}
    
- (void)beginStraightLineMoveAnimaiton:(LDPMConfirmAlertAnimationType)type completion:(void (^)(BOOL finished))completion{
    CGPoint endPoint,startPoint;
    switch (type) {
        case LDPMConfirmAlertAnimationSheet:
        {
            endPoint = self.dialogView.layer.position;
            startPoint = CGPointMake(self.dialogView.layer.position.x, CGRectGetHeight(self.bounds) + CGRectGetHeight(self.dialogView.bounds));
            [self maskViewAnimationWithAppearType:YES];
            break;
        }
        case LDPMConfirmAlertAnimationMoveInFromTop:
        {
            endPoint = self.dialogView.layer.position;
            startPoint = CGPointMake(self.dialogView.layer.position.x, - CGRectGetHeight(self.dialogView.bounds)/2.0f);
            [self maskViewAnimationWithAppearType:YES];
            break;
        }
        case LDPMConfirmAlertAnimationMoveOutFromBottom:
        {
            endPoint = CGPointMake(self.dialogView.layer.position.x, CGRectGetHeight(self.bounds) + CGRectGetHeight(self.dialogView.bounds));
            startPoint = self.dialogView.layer.position;
            break;
        }
        case LDPMConfirmAlertAnimationMoveOutFromTop:
        {
            endPoint = CGPointMake(self.dialogView.layer.position.x, - CGRectGetHeight(self.dialogView.bounds)/2.0f);
            startPoint = self.dialogView.layer.position;
            break;
        }
        default:
        {
            completion(YES);
            return;
        }
    }
    self.dialogView.layer.position = startPoint;
    @weakify(self)
    [UIView animateWithDuration:kLDPMEditableAlertViewAnimationLongDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         @strongify(self)
                         self.dialogView.layer.position = endPoint;
                     }
                     completion:completion
     ];
}

- (void)maskViewAnimationWithAppearType:(BOOL)appear {
    CGFloat endAlpha = 0.0;
    CGFloat startAlpha = 0.0;
    if (appear) {
        startAlpha = 0.0;
        endAlpha = 0.4;
    } else {
        startAlpha = 0.4;
        endAlpha = 0.0;
    }
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:startAlpha];
    [UIView animateWithDuration:kLDPMEditableAlertViewMaskViewAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:endAlpha];
                     }
                     completion:NULL
     ];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
    self.isAnimating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.isAnimating = NO;
}

@end
