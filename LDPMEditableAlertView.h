//
//  LDPMEditableAlertView.h
//  PreciousMetals
//
//  Created by gaoyu on 15/8/29.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LDPMEditableAlertView;

typedef void (^LDPMEditableAlertDismissBlock)(LDPMEditableAlertView *alertView, NSUInteger buttonIndex);

typedef NS_ENUM(NSInteger, LDPMConfirmAlertAnimationType) {
    LDPMConfirmAlertAnimationNone,                      //无
    LDPMConfirmAlertAnimationAlert,                     //同alertView
    LDPMConfirmAlertAnimationSheet,                     //底部弹出
    LDPMConfirmAlertAnimationMoveInFromTop,             //从顶部移入
    LDPMConfirmAlertAnimationMoveOutFromTop,            //从顶部移除
    LDPMConfirmAlertAnimationMoveOutFromBottom,         //从底部移除
    LDPMConfirmAlertAnimationMoveInFromCenter,          //从中心展开
    LDPMConfirmAlertAnimationMoveOutFromCenter,         //从中心消失
};

@interface LDPMEditableAlertView : UIView

@property(nonatomic,strong) UIView *parentView;
@property(nonatomic,strong) UIView *containerView;
@property(nonatomic,strong) UIColor *confirmButtonColor;
@property(nonatomic,strong) UIColor *confirmButtonTextColor;
@property(nonatomic,strong) NSArray *buttonTitles;
@property(nonatomic,copy) NSString *alertTitle;

@property(nonatomic,assign) LDPMConfirmAlertAnimationType appearType;
@property(nonatomic,assign) LDPMConfirmAlertAnimationType cancelType;
@property(nonatomic,assign) LDPMConfirmAlertAnimationType doneType;
@property(nonatomic,assign) BOOL isBackgroundTapCancel;

@property(nonatomic,copy) LDPMEditableAlertDismissBlock dismissBlock;

- (instancetype)initWithTitle:(NSString*)title
                   parentView:(UIView*)parentView
                containerView:(UIView*)containerView
                 buttonTitles:(NSArray*)titlesArray;
- (instancetype)initWithTitle:(NSString*)title
                containerView:(UIView*)containerView
                 buttonTitles:(NSArray*)titlesArray;
- (void)show;

// for subclass only
- (UIView *)createDialogView;

@end