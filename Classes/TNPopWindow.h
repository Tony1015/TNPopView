//
//  TNPopView.h
//  BlueTooth
//
//  Created by Tony on 2017/5/31.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TNPopViewAnimationFromRight = 1,
    TNPopViewAnimationFromBottom,
    TNPopViewAnimationNull,
} TNPopViewAnimation;

typedef void(^TNPopAnimationCompletionBlock)();


typedef NS_ENUM (NSInteger, TNPopViewStyle) {
    TNPopViewStyleAlert,
    TNPopViewStyleAction,
    TNPopViewStyleNull,
};



@interface TNPopWindow : UIWindow

@property (nonatomic,strong) UIView *contentView;

@property (nonatomic,assign) BOOL clickDismiss;

@property (nonatomic,assign) TNPopViewAnimation animation;

@property (nonatomic, assign) TNPopViewStyle style;


@property (nonatomic,copy) TNPopAnimationCompletionBlock showComletionBlock;

@property (nonatomic,copy) TNPopAnimationCompletionBlock dismissComletionBlock;

+ (instancetype)popViewWithContentView:(UIView *)contentView withClickDismiss:(BOOL)clickDismiss withAnimation:(TNPopViewAnimation)animation;

+ (instancetype)popViewWithContentView:(UIView *)contentView withClickDismiss:(BOOL)clickDismiss;

+ (instancetype)popViewWithContentView:(UIView *)contentView withAnimation:(TNPopViewAnimation)animation;

+ (instancetype)popViewWithContentView:(UIView *)contentView;

+ (instancetype)showPopViewWithContentView:(UIView *)contentView;

+ (instancetype)popView;

- (void)show;

- (void)showWithCompletion:(TNPopAnimationCompletionBlock)block;

- (void)dismiss;

- (void)dismissWithCompletion:(TNPopAnimationCompletionBlock)block;

@end

