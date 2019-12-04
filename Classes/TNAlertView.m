//
//  TNAlertView.m
//  BaseProject
//
//  Created by Tony on 2017/8/13.
//  Copyright © 2017年 Tony. All rights reserved.
//

#import "TNAlertView.h"
#import "TNPopWindow.h"
#import "Masonry.h"
#import "TNCategory.h"


@interface TNAlertView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) NSArray *actionItems;

@property (nonatomic, copy) TNAlertInputHandler inputHandler;

@property (nonatomic, strong) TNPopWindow *popView;
@property (nonatomic, strong) UIWindow *window;

@end


@implementation TNAlertView

+ (instancetype)showWithTitle:(NSString*)title
                             detail:(NSString*)detail
                              items:(NSArray<TNAlertViewItem *> *)items
                        inputPlaceholder:(NSString*)inputPlaceholder
                            inputHandler:(TNAlertInputHandler)inputHandler{
    TNAlertView *view = [[TNAlertView alloc]initWithTitle:title detail:detail items:items inputPlaceholder:inputPlaceholder inputHandler:inputHandler];
    [view show];
    return view;
}


+  (instancetype)showWithTitle:(NSString*)title
                        detail:(NSString*)detail
                         items:(NSArray<TNAlertViewItem *> *)items{
    TNAlertView *view = [[TNAlertView alloc]initWithTitle:title detail:detail items:items];
    [view show];
    return view;
}

//- (instancetype) initWithInputTitle:(NSString*)title
//                             detail:(NSString*)detail
//                              items:(NSArray<TNAlertViewItem *> *)items
//                        placeholder:(NSString*)inputPlaceholder
//                            handler:(TNAlertInputHandler)inputHandler{
//
//    return [self initWithTitle:title detail:detail items:items inputPlaceholder:inputPlaceholder inputHandler:inputHandler];
//}

- (instancetype) initWithTitle:(NSString*)title
                        detail:(NSString*)detail
                         items:(NSArray<TNAlertViewItem *> *)items{
    return [self initWithTitle:title detail:detail items:items inputPlaceholder:nil inputHandler:nil];
}

- (instancetype) initWithTitle:(NSString *)title
                       detail:(NSString *)detail
                        items:(NSArray<TNAlertViewItem *> *)items
             inputPlaceholder:(NSString*)inputPlaceholder
                 inputHandler:(TNAlertInputHandler)inputHandler{
    
    TNAlertViewConfig *config = [TNAlertViewConfig globalConfig];
    
    if ( inputHandler )
    {
        self.inputHandler = inputHandler;
        UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, config.width, 40)];
        UITextField *textField = [UITextField new];
        self.inputView = textField;
        [customView addSubview:self.inputView];
        [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(customView);
            make.left.right.equalTo(customView).insets(UIEdgeInsetsMake(0, config.innerMargin, 0, config.innerMargin));
        }];
        self.inputView.backgroundColor = self.backgroundColor;
        self.inputView.layer.borderWidth = (1/[UIScreen mainScreen].scale);
        self.inputView.layer.borderColor = config.splitColor.CGColor;
        self.inputView.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        self.inputView.leftViewMode = UITextFieldViewModeAlways;
        self.inputView.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.inputView.placeholder = inputPlaceholder;
        self.inputView.secureTextEntry = YES;
        self.inputView.returnKeyType = UIReturnKeyDone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyTextChange:) name:UITextFieldTextDidChangeNotification object:nil];
        
        self = [self initWithTitle:title detail:detail items:items customView:customView];
        self.withKeyboard = YES;
        return self;
    }else{
        return [self initWithTitle:title detail:detail items:items customView:nil];
    }
    
}

- (instancetype) initWithTitle:(NSString *)title detail:(NSString *)detail items:(NSArray<TNAlertViewItem *> *)items customView:(UIView *)customView{
    if (self = [super init]) {
        self.clickDismiss = YES;
        
        self.actionItems = items;
        
        
        TNAlertViewConfig *config = [TNAlertViewConfig globalConfig];
        
        self.layer.cornerRadius = config.cornerRadius;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = (1/[UIScreen mainScreen].scale);
        self.layer.borderColor = config.splitColor.CGColor;
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(config.width);
        }];
        
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];
        
        MASViewAttribute *lastAttribute = self.mas_top;
        if ( title.length > 0 )
        {
            self.titleLabel = [UILabel new];
            [self addSubview:self.titleLabel];
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastAttribute).offset(config.innerMargin);
                make.left.right.equalTo(self).insets(UIEdgeInsetsMake(0, config.innerMargin, 0, config.innerMargin));
            }];
            self.titleLabel.textColor = config.titleColor;
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.font = [UIFont boldSystemFontOfSize:config.titleFontSize];
            self.titleLabel.numberOfLines = 0;
            self.titleLabel.backgroundColor = self.backgroundColor;
            self.titleLabel.text = title;
            
            lastAttribute = self.titleLabel.mas_bottom;
        }
        
        if ( detail.length > 0 )
        {
            self.detailLabel = [UILabel new];
            [self addSubview:self.detailLabel];
            [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastAttribute).offset(config.innerMargin);
                make.left.right.equalTo(self).insets(UIEdgeInsetsMake(0, config.innerMargin, 0, config.innerMargin));
            }];
            self.detailLabel.textColor = config.detailColor;
            self.detailLabel.textAlignment = NSTextAlignmentLeft;
            self.detailLabel.font = [UIFont systemFontOfSize:config.detailFontSize];
            self.detailLabel.numberOfLines = 0;
            self.detailLabel.backgroundColor = self.backgroundColor;
            self.detailLabel.text = detail;
            
            lastAttribute = self.detailLabel.mas_bottom;
        }
        
        if ( customView )
        {
            if (customView.tn_width>config.width) {
                [self mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(customView.tn_width);
                }];
            }
            [self addSubview:customView];
            [customView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastAttribute).offset(10);
                make.centerX.equalTo(self);
                make.height.mas_equalTo(customView.tn_height);
                make.width.mas_equalTo(customView.tn_width);
            }];
            lastAttribute = customView.mas_bottom;
        }
        
        self.buttonView = [UIView new];
        [self addSubview:self.buttonView];
        [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastAttribute).offset(config.innerMargin);
            make.left.right.equalTo(self);
        }];
        
        __block UIButton *firstButton = nil;
        __block UIButton *lastButton = nil;
        for ( NSInteger i = 0 ; i < items.count; ++i )
        {
            TNAlertViewItem *item = items[i];
            UIButton *btn = [UIButton new];
            [btn addTarget:self action:@selector(actionButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonView addSubview:btn];
            btn.tag = i;
            
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                
                if ( items.count <= 2 )
                {
                    make.top.bottom.equalTo(self.buttonView);
                    make.height.mas_equalTo(config.buttonHeight);
                    
                    if (!firstButton)
                    {
                        firstButton = btn;
                        make.left.equalTo(self.buttonView.mas_left).offset(-(1/[UIScreen mainScreen].scale));
                    }
                    else
                    {
                        make.left.equalTo(lastButton.mas_right).offset(-(1/[UIScreen mainScreen].scale));
                        make.width.equalTo(firstButton);
                    }
                }
                else
                {
                    make.left.right.equalTo(self.buttonView);
                    make.height.mas_equalTo(config.buttonHeight);
                    
                    if ( !firstButton )
                    {
                        firstButton = btn;
                        make.top.equalTo(self.buttonView.mas_top).offset(-(1/[UIScreen mainScreen].scale));
                    }
                    else
                    {
                        make.top.equalTo(lastButton.mas_bottom).offset(-(1/[UIScreen mainScreen].scale));
                        make.width.equalTo(firstButton);
                    }
                }
                lastButton = btn;
            }];
            
            [btn setTitle:item.title forState:UIControlStateNormal];
            
            switch (item.style) {
                case TNAlertViewItemStyleNormal:
                    [btn setTitleColor:config.itemTitleColor forState:UIControlStateNormal];
                    [btn setBackgroundImage:[UIImage tn_creatImageWithColor:config.itemNormalColor] forState:UIControlStateNormal];
//                    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
                    break;
                case TNAlertViewItemStyleCancel:
                    [btn setTitleColor:config.itemTitleColor forState:UIControlStateNormal];
                    [btn setBackgroundImage:[UIImage tn_creatImageWithColor:config.itemNormalColor] forState:UIControlStateNormal];
//                    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                    break;
                case TNAlertViewItemStyleDestructive:
                    [btn setTitleColor:config.itemDestructiveTitleColor forState:UIControlStateNormal];
                    [btn setBackgroundImage:[UIImage tn_creatImageWithColor:config.itemDestructiveColor] forState:UIControlStateNormal];
//                    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
                    break;
                    
                default:
                    break;
            }
//            btn.layer.borderWidth = (1/[UIScreen mainScreen].scale);
//            btn.layer.borderColor = config.splitColor.CGColor;
            btn.titleLabel.font = [UIFont systemFontOfSize:(config.buttonFontSize)];
            
            
        }
        
        [lastButton mas_updateConstraints:^(MASConstraintMaker *make) {
            
            if ( items.count <= 2 )
            {
                make.right.equalTo(self.buttonView.mas_right).offset((1/[UIScreen mainScreen].scale));
            }
            else
            {
                make.bottom.equalTo(self.buttonView.mas_bottom).offset((1/[UIScreen mainScreen].scale));
            }
            
        }];
        
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.equalTo(self.buttonView.mas_bottom);
            
        }];
        
    }
    return self;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}


- (void)actionButton:(UIButton*)btn
{
    TNAlertViewItem *item = self.actionItems[btn.tag];
    
    
    if ( self.withKeyboard && (btn.tag==1) )
    {
        if ( self.inputView.text.length > 0 )
        {
            [self hide];
        }
    }
    else
    {
        [self hide];
    }
    
    if (self.inputHandler && item.style!= TNAlertViewItemStyleCancel)
    {
        self.inputHandler(self.inputView.text);
    }
    else
    {
        if (item.handler)
        {
            item.handler(self);
        }
    }
}

- (void)notifyTextChange:(NSNotification *)n
{
    if ( n.object != self.inputView )
    {
        return;
    }
    
    UITextField *textField = self.inputView;
    
    NSString *toBeString = textField.text;
    
    UITextRange *selectedRange = [textField markedTextRange];
    //获取高亮部分
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    
}

- (void)showKeyboard
{
    [self.inputView becomeFirstResponder];
}

- (void)hideKeyboard
{
    [self.inputView resignFirstResponder];
}

- (void)hide{
    [self.popView dismiss];
    if (self.withKeyboard) {
        [self hideKeyboard];
    }
}

- (TNPopWindow *)popView{
    if (!_popView) {
        _popView = [TNPopWindow popViewWithContentView:self];
        _popView.clickDismiss = self.clickDismiss;
        _popView.style = TNPopViewStyleAlert;
    }
    return _popView;
}

- (void)show{
    [self.popView showWithCompletion:^{
        if (self.withKeyboard) {
            [self showKeyboard];
        }
    }];
    
    
}

@end





@interface TNAlertViewItem ()

@property (copy, nonatomic) NSString *title;
@property (nonatomic, assign) TNAlertViewItemStyle style;


@end

@implementation TNAlertViewItem

+ (instancetype)itemWithTitle:(NSString *)title style:(TNAlertViewItemStyle)style handler:(TNAlertViewItemHandler)handler{
    TNAlertViewItem *item = [[TNAlertViewItem alloc]init];
    item.title = title;
    item.style = style;
    item.handler = handler;
    return item;
}


@end



@interface TNAlertViewConfig()

@end

@implementation TNAlertViewConfig

+ (TNAlertViewConfig *)globalConfig
{
    static TNAlertViewConfig *config;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        config = [TNAlertViewConfig new];
        
    });
    
    return config;
}

- (instancetype)init
{
    self = [super init];
    
    if ( self )
    {
        self.width          = 275.0f;
        self.buttonHeight   = 50.0f;
        self.innerMargin    = 15.0f;
        self.cornerRadius   = 5.0f;
        
        self.titleFontSize  = 18.0f;
        self.detailFontSize = 14.0f;
        self.buttonFontSize = 17.0f;
        
        self.backgroundColor    = [UIColor tn_colorWithHex:(0xFFFFFFFF)];
        self.titleColor         = [UIColor tn_colorWithHex:(0x333333FF)];
        self.detailColor        = [UIColor tn_colorWithHex:(0x333333FF)];
        self.splitColor         = [UIColor tn_colorWithHex:(0xCCCCCCFF)];
        
        self.itemNormalColor    = [UIColor tn_colorWithHex:(0xE4E4E4FF)];
        self.itemDestructiveColor = [UIColor tn_colorWithHex:(0xF87EB7FF)];
        self.itemTitleColor   = [UIColor tn_colorWithHex:(0x999999FF)];
        self.itemDestructiveTitleColor     = [UIColor tn_colorWithHex:(0xFFFFFFFF)];
        
    }
    
    return self;
}

@end

