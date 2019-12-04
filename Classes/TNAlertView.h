//
//  TNAlertView.h
//  BaseProject
//
//  Created by Tony on 2017/8/13.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TNAlertInputHandler)(NSString *text);
@class TNAlertViewItem;

@interface TNAlertView : UIView

@property (nonatomic,assign) BOOL clickDismiss;

@property (nonatomic, weak) UITextField *inputView;
@property (nonatomic, assign) BOOL withKeyboard;


+ (instancetype) showWithTitle:(NSString*)title
                       detail:(NSString*)detail
                        items:(NSArray<TNAlertViewItem *> *)items
             inputPlaceholder:(NSString*)inputPlaceholder
                 inputHandler:(TNAlertInputHandler)inputHandler;

+  (instancetype) showWithTitle:(NSString*)title
                        detail:(NSString*)detail
                         items:(NSArray<TNAlertViewItem *> *)items;


- (instancetype) initWithTitle:(NSString *)title
                        detail:(NSString *)detail
                         items:(NSArray<TNAlertViewItem *> *)items
              inputPlaceholder:(NSString*)inputPlaceholder
                  inputHandler:(TNAlertInputHandler)inputHandler;

- (instancetype) initWithTitle:(NSString*)title
                        detail:(NSString*)detail
                         items:(NSArray<TNAlertViewItem *> *)items;

- (instancetype) initWithTitle:(NSString *)title detail:(NSString *)detail items:(NSArray<TNAlertViewItem *> *)items customView:(UIView *)customView;

- (void)show;

- (void)hide;

@end

typedef NS_ENUM (NSInteger, TNAlertViewItemStyle) {
    TNAlertViewItemStyleNormal,
    TNAlertViewItemStyleCancel,
    TNAlertViewItemStyleDestructive,
};


typedef void(^TNAlertViewItemHandler)(TNAlertView *alertView);

@interface TNAlertViewItem : NSObject

@property (copy, nonatomic, readonly) NSString *title;

@property (assign, nonatomic, readonly) TNAlertViewItemStyle style;

@property (nonatomic,copy) TNAlertViewItemHandler handler;



+ (instancetype)itemWithTitle:(NSString *)title style:(TNAlertViewItemStyle)style handler:(TNAlertViewItemHandler)handler;


@end


@interface TNAlertViewConfig : NSObject

+ (TNAlertViewConfig*) globalConfig;

@property (nonatomic, assign) CGFloat width;                // Default is 275.
@property (nonatomic, assign) CGFloat buttonHeight;         // Default is 50.
@property (nonatomic, assign) CGFloat innerMargin;          // Default is 15.
@property (nonatomic, assign) CGFloat cornerRadius;         // Default is 5.

@property (nonatomic, assign) CGFloat titleFontSize;        // Default is 18.
@property (nonatomic, assign) CGFloat detailFontSize;       // Default is 14.
@property (nonatomic, assign) CGFloat buttonFontSize;       // Default is 17.

@property (nonatomic, strong) UIColor *backgroundColor;     // Default is #FFFFFF.
@property (nonatomic, strong) UIColor *titleColor;          // Default is #333333.
@property (nonatomic, strong) UIColor *detailColor;         // Default is #333333.
@property (nonatomic, strong) UIColor *splitColor;          // Default is #CCCCCC.

@property (nonatomic, strong) UIColor *itemNormalColor;     // Default is #FFFFFF. effect with TNItemTypeNormal
@property (nonatomic, strong) UIColor *itemDestructiveColor;  // Default is #E76153. effect with TNItemTypeHighlight
@property (nonatomic, strong) UIColor *itemDestructiveTitleColor;    // Default is #EFEDE7.
@property (nonatomic, strong) UIColor *itemTitleColor;

@end
