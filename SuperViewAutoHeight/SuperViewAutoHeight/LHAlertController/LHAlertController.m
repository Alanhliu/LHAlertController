//
//  LHAlertController.m
//  SuperViewAutoHeight
//
//  Created by siasun on 2018/3/7.
//  Copyright © 2018年 personal. All rights reserved.
//

#import "LHAlertController.h"

static const CGFloat ALERT_ACTION_HEIGHT = 45.0;
static const CGFloat ALERT_TEXTFIELD_HEIGHT = 30.0;
static const CGFloat ALERT_TEXTVIEW_HEIGHT = 40.0;
#define BORDER_COLOR [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]

@interface LHAlertAction ()

@property (nonatomic, copy) void (^action)(void);

@end

@implementation LHAlertAction

- (instancetype)initWithTitle:(NSString *)title style:(LHAlertActionStyle)style action:(void (^)(void))action
{
    if (self = [super init]) {
        
        self.action = action;
        [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        
        [self setTitle:title forState:UIControlStateNormal];
        [self setBackgroundImage:nil forState:UIControlStateSelected];
        
        if (style == LHAlertActionStyleDefault) {
            [self setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
        } else if (style == LHAlertActionStyleCancel) {
            [self setTitleColor:[UIColor colorWithRed:0 green:122.0/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
            [self.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        } else if (style == LHAlertActionStyleDestructive) {
            [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }
    return self;
}

- (void)click
{
    if (self.action) {
        self.action();
    }
}

- (UIImage *)createImageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end

@interface LHAlertController ()
@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIScrollView *alertScrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *alertTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertMessageLabel;
@property (weak, nonatomic) IBOutlet UIStackView *alertStackView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *alertViewCenterY;

@property (nonatomic, strong) NSMutableArray *alertActions;
@property (nonatomic, strong) NSMutableArray *alertCustomViews;
@property (nonatomic, strong) NSMutableArray *alertCustomViewHeights;

@property (nonatomic, assign) CGFloat originHeight;
@property (nonatomic, assign) CGFloat kHeight;
@property (nonatomic, assign) BOOL keyboardShow;
@end

@implementation LHAlertController

+ (id)alertWithTitle:(NSString *)title message:(NSString *)message
{
    LHAlertController *alertController = [[UIStoryboard storyboardWithName:@"LHAlertController" bundle:nil] instantiateViewControllerWithIdentifier:@"LHAlertController"];
    alertController.alertTitle = title;
    alertController.alertMessage = message;
    
    return alertController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        self.alertActions = [[NSMutableArray alloc] initWithCapacity:2];
        self.alertCustomViews = [[NSMutableArray alloc] init];
        self.alertCustomViewHeights = [[NSMutableArray alloc] init];
        self.originHeight = 0;
        self.keyboardShow = NO;
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.alertTitleLabel.text = self.alertTitle;
    self.alertMessageLabel.text = self.alertMessage;
    
    self.alertView.layer.cornerRadius = 15.0;
    self.alertScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(10,0,0,0);
    
    [self layoutActions];
    [self layoutCustomViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.keyboardShow = YES;
    self.kHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height - self.kHeight - 2*20;
    
    [UIView animateWithDuration:0.25f animations:^{
        
        self.alertViewCenterY.constant = -([UIScreen mainScreen].bounds.size.height -maxHeight)/2 + 20;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self firstResponderScrollVisiblePosition];
    }];
}

- (void)firstResponderScrollVisiblePosition
{
    for (UIView *customView in self.contentView.subviews) {
        if ([customView isFirstResponder]) {
            
            CGFloat maxY = CGRectGetMaxY(customView.frame);
            if (maxY > self.scrollViewHeight.constant) {
                [self.alertScrollView setContentOffset:CGPointMake(0, maxY-self.scrollViewHeight.constant) animated:YES];
            }
            
            break;
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.view endEditing:YES];
    self.keyboardShow = NO;
    [UIView animateWithDuration:0.25f animations:^{
        self.alertViewHeight.constant = self.originHeight;
        self.alertViewCenterY.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)layoutActions
{
    for (LHAlertAction *alertAction in self.alertActions) {
        [self.alertStackView addArrangedSubview:alertAction];
        
        [alertAction addTarget:self action:@selector(dismissAlertController) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ([self.alertStackView.arrangedSubviews count] > 2) {
        self.alertStackView.axis = UILayoutConstraintAxisVertical;
        //draw H line
        [self.alertStackView.arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CALayer *hLineLayer = [CALayer layer];
            hLineLayer.backgroundColor = [BORDER_COLOR CGColor];
            hLineLayer.frame = CGRectMake(0, idx*ALERT_ACTION_HEIGHT, CGRectGetWidth(self.alertStackView.frame), 0.5);
            [self.alertStackView.layer addSublayer:hLineLayer];
        }];
    } else {
        self.alertStackView.axis = UILayoutConstraintAxisHorizontal;
        
        //draw H line
        if (self.alertStackView.arrangedSubviews.count != 0 ) {
            CALayer *hLineLayer = [CALayer layer];
            hLineLayer.backgroundColor = [BORDER_COLOR CGColor];
            hLineLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.alertStackView.frame), 0.5);
            [self.alertStackView.layer addSublayer:hLineLayer];
        }
        //draw V line
        if (self.alertStackView.arrangedSubviews.count == 2 ) {
            CALayer *vLineLayer = [CALayer layer];
            vLineLayer.backgroundColor = [BORDER_COLOR CGColor];
            vLineLayer.frame = CGRectMake(CGRectGetWidth(self.alertStackView.frame)/2, 0, 0.5, ALERT_ACTION_HEIGHT);
            [self.alertStackView.layer addSublayer:vLineLayer];
        }
    }
    
    self.stackViewHeight.constant = [self alertStackViewHeight];
}

- (void)layoutCustomViews
{
    for (NSInteger i = 0; i < self.alertCustomViews.count; i++) {
        UIView *customView = self.alertCustomViews[i];
        NSNumber *customViewHeight = self.alertCustomViewHeights[i];
        
        //取到lastView之后把他的bottom和contentView的bottom之间的约束删掉
        NSArray *lastViewConstraints = self.contentView.constraints;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@",@"customViewBottomLayoutConstraint"];
        NSLayoutConstraint *needDeleteConstraint = [lastViewConstraints filteredArrayUsingPredicate:predicate].firstObject;
        [self.contentView removeConstraint:needDeleteConstraint];
        
        
        UIView *lastView = self.contentView.subviews.lastObject;
        
        [self.contentView addSubview:customView];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:customView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[customView]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(customView)]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[customView(%@)]",customViewHeight] options:0 metrics:nil views:NSDictionaryOfVariableBindings(customView)]];
        //新添加的customView变成了lastView，再增加他的bottom和contentView的bottom之间的约束
        NSLayoutConstraint *customViewBottomLayoutConstraint = [NSLayoutConstraint constraintWithItem:customView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        customViewBottomLayoutConstraint.identifier = @"customViewBottomLayoutConstraint";
        [self.contentView addConstraint:customViewBottomLayoutConstraint];
    }
    [self.contentView setNeedsUpdateConstraints];
    
    for (UIView *customView in self.alertCustomViews) {
        if ([customView isKindOfClass:UITextField.class]) {
            [((UITextField *)customView) becomeFirstResponder];
            break;
        }
        if ([customView isKindOfClass:UITextView.class]) {
            [((UITextView *)customView) becomeFirstResponder];
            break;
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    CGFloat contentViewHeight = size.height;
    
    if (self.originHeight == 0) {
        self.originHeight = contentViewHeight + [self alertStackViewHeight];
    }
    
    self.scrollViewHeight.constant = contentViewHeight;
    self.alertViewHeight.constant = contentViewHeight+[self alertStackViewHeight];
    
    if (self.keyboardShow) {
        CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height - self.kHeight - 2*20;
        if (self.alertViewHeight.constant > maxHeight) {
            self.alertViewHeight.constant = maxHeight;
            self.scrollViewHeight.constant = maxHeight - [self alertStackViewHeight];
        }
    } else {
        CGFloat maxHeight = [UIScreen mainScreen].bounds.size.height -2*20;
        if (contentViewHeight+[self alertStackViewHeight] > maxHeight) {
            self.scrollViewHeight.constant = maxHeight - [self alertStackViewHeight];
            self.alertViewHeight.constant = maxHeight;
        }
    }
}

#pragma mark - add action
- (void)addAction:(LHAlertAction *)alertAction {
    [self.alertActions addObject:alertAction];
}

#pragma mark - add custom view
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField * _Nullable textField))configurationHandler height:(NSNumber *)height
{
    UITextField *textField = [[UITextField alloc] init];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.layer.borderColor = [BORDER_COLOR CGColor];
    textField.layer.borderWidth = 0.5;
    
    if (configurationHandler) {
        configurationHandler(textField);
    }
    [self.alertCustomViews addObject:textField];
    if (!height) {
        height = @(ALERT_TEXTFIELD_HEIGHT);
    }
    [self.alertCustomViewHeights addObject:height];
}

- (void)addTextViewWithConfigurationHandler:(void (^ __nullable)(UITextView * _Nullable textView))configurationHandler height:(NSNumber *)height
{
    UITextView *textView= [[UITextView alloc] init];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    textView.layer.borderColor = [BORDER_COLOR CGColor];
    textView.layer.borderWidth = 0.5;
    
    if (configurationHandler) {
        configurationHandler(textView);
    }
    [self.alertCustomViews addObject:textView];
    if (!height) {
        height = @(ALERT_TEXTVIEW_HEIGHT);
    }
    [self.alertCustomViewHeights addObject:height];
}

- (void)addCustomView:(UIView *)customView height:(NSNumber *)height
{
    if (customView) {
        customView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.alertCustomViews addObject:customView];
        
        NSAssert(height != nil, @"customview's height can't be nil");
        [self.alertCustomViewHeights addObject:height];
    }
}

- (UIView *)viewAtIndex:(NSInteger)index
{
    if (index <= self.alertCustomViews.count - 1) {
        return [self.alertCustomViews objectAtIndex:index];
    } else {
        return nil;
    }
}

- (NSArray *)contentSubViews
{
    return self.alertCustomViews;
}

- (void)dismissAlertController
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (CGFloat)alertStackViewHeight
{
    NSInteger rows = self.alertActions.count > 2 ? self.alertActions.count : 1;
    return rows * ALERT_ACTION_HEIGHT;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
