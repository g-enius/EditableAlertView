//
//  LDPMLiveRoomAlertView.m
//  PreciousMetals
//
//  Created by wangchao on 1/15/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import "LDPMLiveRoomAlertView.h"
#import "UIImage+LDPMLive.h"

@implementation LDPMLiveRoomAlertView

- (instancetype)initWithMessage:(NSString *)message buttonTitle:(NSString *)buttonTitle parentView:(UIView *)parentView
{
    NSAssert(message, @"弹窗内容不能为空!");
    UIView *containerView = [self setContainerViewWithMessage:message];
    if (buttonTitle) {
        self = [super initWithTitle:nil parentView:parentView containerView:containerView buttonTitles:@[@"取消", buttonTitle]];
    } else {
        self = [super initWithTitle:nil containerView:containerView buttonTitles:@[@"确定"]];
    }
    if (self) {
        self.appearType = LDPMConfirmAlertAnimationAlert;
        self.cancelType = LDPMConfirmAlertAnimationNone;
        self.doneType = LDPMConfirmAlertAnimationNone;
    }
    return self;
}

- (UIView *)createDialogView
{
    UIView *dialogView = [super createDialogView];
    dialogView.backgroundColor = [UIColor clearColor];
    for (UIView *aView in dialogView.subviews) {
        if ([aView isKindOfClass:[UIButton class]]) {
            aView.backgroundColor = [UIColor whiteColor];
            if (aView.tag == 1) {
                UIButton *confirmButton = (UIButton *)aView;
                [confirmButton setTitleColor:[UIColor colorWithRGB:0x007aff] forState:UIControlStateNormal];
                UIView *sepline = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, confirmButton.height)];
                sepline.backgroundColor = [NPMColor seplineColor];
                [confirmButton addSubview:sepline];
            }
        }
    }
    
    return dialogView;
}

- (UIView *)setContainerViewWithMessage:(NSString *)message
{
    CGFloat width = 247.;
    CGFloat height = 157.;
    CGFloat radius = 87.;
    CGFloat cornerRadius = 5.0;
    CGFloat clearHeight = 31.;
    
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    containerView.backgroundColor = [UIColor clearColor];

    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, clearHeight, width, height - clearHeight)];
    downView.backgroundColor = [UIColor whiteColor];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = downView.bounds;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:downView.bounds byRoundingCorners: UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)].CGPath;
    downView.layer.mask = maskLayer;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 57, width - 20, 60)];
    label.numberOfLines = 3;
    label.textColor = [NPMColor grayTextColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = message;
    label.textAlignment = NSTextAlignmentCenter;
    [downView addSubview:label];
    [containerView addSubview:downView];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((width - radius) / 2, 0, radius, radius)];
    imageView.image = [UIImage imageNamed:@"LiveRoom_AlertLogo.jpg"];
    [containerView addSubview:imageView];
    return containerView;
}

@end
