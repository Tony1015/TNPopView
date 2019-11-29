//
//  TNPopView.m
//  BlueTooth
//
//  Created by Tony on 2017/5/31.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "TNPopWindow.h"
#import "TNCategory.h"

#define AnimationDuration 0.25

typedef void(^TNPopViewAnimationBlock)();


@interface TNPopWindow ()<UIGestureRecognizerDelegate>{
}
//@property (nonatomic,strong) UIImageView *coverBlurView;

@property (nonatomic,copy) TNPopViewAnimationBlock showAnimation;

@property (nonatomic,copy) TNPopViewAnimationBlock dismissAnimation;

@property (nonatomic, assign) CGRect destinationRect;


@property (nonatomic, copy) void(^countFrameBlock)(void);


@end

@implementation TNPopWindow

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.windowLevel = UIWindowLevelAlert;
        self.clickDismiss = YES;
        self.rootViewController = [UIViewController new];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickedDismiss:)];
        tap.delegate = self;
        tap.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tap];
        self.animation = TNPopViewAnimationNull;
        self.style = TNPopViewStyleNull;
    }
    return self;
}


+ (instancetype)popViewWithContentView:(UIView *)contentView withClickDismiss:(BOOL)clickDismiss withAnimation:(TNPopViewAnimation)animation{
    TNPopWindow *view = [TNPopWindow popView];
    view.contentView = contentView;
    view.clickDismiss = clickDismiss;
    view.animation = animation;
    return view;
}

+ (instancetype)popViewWithContentView:(UIView *)contentView withClickDismiss:(BOOL)clickDismiss{
    return [self popViewWithContentView:contentView withClickDismiss:clickDismiss withAnimation:TNPopViewAnimationNull];
}

+ (instancetype)popViewWithContentView:(UIView *)contentView withAnimation:(TNPopViewAnimation)animation{
    return [self popViewWithContentView:contentView withClickDismiss:YES withAnimation:animation];
}


+ (instancetype)popViewWithContentView:(UIView *)contentView{
    return [self popViewWithContentView:contentView withClickDismiss:YES withAnimation:TNPopViewAnimationNull];
}

+ (instancetype)showPopViewWithContentView:(UIView *)contentView{
    TNPopWindow *view = [self popViewWithContentView:contentView];
    [view show];
    return view;
}

+ (instancetype)popView{
    TNPopWindow *view = [[TNPopWindow alloc]init];
    view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
    return view;
}

- (void)setContentView:(UIView *)contentView{
    if (_contentView!=contentView) {
        [_contentView removeFromSuperview];
        _contentView = contentView;
//        CGFloat height = contentView.tn_height;
//        CGFloat width = contentView.tn_width;
//        if (height!=0 && width!=0) {
//            [contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.width.mas_equalTo(width);
//                make.height.mas_equalTo(height);
//            }];
//        }
//        [self addSubview:_contentView];
    }
}
- (void)setStyle:(TNPopViewStyle)style{
    _style = style;

    __weak __typeof(self) selfWeak = self;
    self.countFrameBlock = ^{
        __strong __typeof(self) self = selfWeak;
        if (style == TNPopViewStyleAlert) {
            self.contentView.tn_x = ([UIScreen mainScreen].bounds.size.width-self.contentView.tn_width)*0.5;
            self.contentView.tn_y = ([UIScreen mainScreen].bounds.size.height-self.contentView.tn_height)*0.5;
        }else if (style == TNPopViewStyleAction) {
            self.contentView.tn_x = ([UIScreen mainScreen].bounds.size.width-self.contentView.tn_width)*0.5;
            self.contentView.tn_y = [UIScreen mainScreen].bounds.size.height-self.contentView.tn_height-((([UIScreen mainScreen].bounds.size.height == 812.0f) ? YES : NO)?34:0);
        }
    };
}

- (void)setAnimation:(TNPopViewAnimation)animation{
    _animation = animation;
    
    __weak __typeof(self) selfWeak = self;
    if (animation == TNPopViewAnimationFromRight) {
        self.showAnimation = ^{
            __strong __typeof(self) self = selfWeak;
            [self layoutIfNeeded];
            self.countFrameBlock();
            self.destinationRect = self.contentView.frame;
            self.contentView.tn_x = [UIScreen mainScreen].bounds.size.width;
            self.alpha = 0.f;
            [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.alpha = 1.0f;
                self.contentView.frame = self.destinationRect;
            }completion:^(BOOL finished) {
                if (self.showComletionBlock) {
                    self.showComletionBlock();
                }
            }];
        };
        self.dismissAnimation = ^{
            __strong __typeof(self) self = selfWeak;
            [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.contentView.tn_x = [UIScreen mainScreen].bounds.size.width;
                self.alpha = 0.0f;
            }completion:^(BOOL finished) {
                [self dismissComplete];
            }];
        };
    }else if (animation == TNPopViewAnimationFromBottom){
        self.showAnimation = ^{
            __strong __typeof(self) self = selfWeak;
            [self layoutIfNeeded];
            self.countFrameBlock();
            self.destinationRect = self.contentView.frame;
            self.contentView.tn_y = [UIScreen mainScreen].bounds.size.height;
            self.alpha = 0.f;
            [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.contentView.frame = self.destinationRect;
                self.alpha = 1.0f;
            }completion:^(BOOL finished) {
                if (self.showComletionBlock) {
                    self.showComletionBlock();
                }
            }];
        };
        self.dismissAnimation = ^{
            __strong __typeof(self) self = selfWeak;
            [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.contentView.tn_y = [UIScreen mainScreen].bounds.size.height;
                self.alpha = 0.0f;
            }completion:^(BOOL finished) {
                [self dismissComplete];
            }];
        };
    }else if (animation == TNPopViewAnimationNull){
        self.showAnimation = ^{
            __strong __typeof(self) self = selfWeak;
            [self layoutIfNeeded];
            self.countFrameBlock();
            self.alpha = 0.0f;
            self.contentView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0f);
            [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.contentView.layer.transform = CATransform3DIdentity;
                self.alpha = 1.0f;
            }completion:^(BOOL finished) {
                if (self.showComletionBlock) {
                    self.showComletionBlock();
                }
            }];
        };
        self.dismissAnimation = ^{
            __strong __typeof(self) self = selfWeak;
            [UIView animateWithDuration:AnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.alpha = 0.0f;
            }completion:^(BOOL finished) {
                [self dismissComplete];
            }];
        };
    }
}

- (void)dismissComplete{
    if (self.dismissComletionBlock) {
        self.dismissComletionBlock();
    }
    [self.rootViewController.view tn_removeAllSubviews];
    self.hidden = YES;
    [self resignKeyWindow];
    self.contentView = nil;
}


- (void)show{
    [self showWithCompletion:nil];
}

- (void)showWithCompletion:(TNPopAnimationCompletionBlock)block{
    if (block) {
        self.showComletionBlock = block;
    }
    
    [self.rootViewController.view addSubview:self.contentView];
    [self makeKeyAndVisible];
    self.showAnimation();
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return (touch.view == self.rootViewController.view);
}


- (void)clickedDismiss:(UITapGestureRecognizer *)recognizer{
    if (self.clickDismiss) {
        [self dismiss];
    }
}

- (void)dismissWithCompletion:(TNPopAnimationCompletionBlock)block{
    if(block){
        self.dismissComletionBlock = block;
    }
    self.dismissAnimation();
}

- (void)dismiss{
    [self dismissWithCompletion:nil];
}



@end

