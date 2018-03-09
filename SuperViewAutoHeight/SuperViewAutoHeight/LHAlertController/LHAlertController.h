//
//  LHAlertController.h
//  SuperViewAutoHeight
//
//  Created by siasun on 2018/3/7.
//  Copyright © 2018年 personal. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSUInteger, LHAlertActionStyle) {
    LHAlertActionStyleDefault,
    LHAlertActionStyleCancel,
    LHAlertActionStyleDestructive
};

@interface LHAlertAction : UIButton

- (instancetype)initWithTitle:(NSString *)title style:(LHAlertActionStyle)style action:(void (^)(void))action;

@end

@class UIAlertController;
@interface LHAlertController : UIViewController

@property (nullable, nonatomic, copy) NSString *alertTitle;
@property (nullable, nonatomic, copy) NSString *alertMessage;

+ (instancetype)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;

- (void)addAction:(LHAlertAction *)alertAction;

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler height:(nullable NSNumber *)height;

- (void)addTextViewWithConfigurationHandler:(void (^ __nullable)(UITextView *textView))configurationHandler height:(nullable NSNumber *)height;

- (void)addCustomView:(UIView *)customView height:(NSNumber *)height;

- (UIView *)viewAtIndex:(NSInteger)index;

- (NSArray *)contentSubViews;

NS_ASSUME_NONNULL_END

@end

