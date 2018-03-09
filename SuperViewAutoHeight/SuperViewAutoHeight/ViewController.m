//
//  ViewController.m
//  SuperViewAutoHeight
//
//  Created by siasun on 2018/3/7.
//  Copyright © 2018年 personal. All rights reserved.
//

#import "ViewController.h"
#import "LHAlertController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)system:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入连接地址" message:@"品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品品" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];

    
    for (int i=0; i<20; i++) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"朋友圈中等文章链接复制到此处分享";
        }];
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)click:(id)sender {
    LHAlertController *alertController = [LHAlertController alertWithTitle:@"输入链接" message:@""];
    
    LHAlertAction *cancelAction = [[LHAlertAction alloc] initWithTitle:@"取消" style:LHAlertActionStyleCancel action:^{
        NSLog(@"取消");
    }];
    
    LHAlertAction *confirmAction = [[LHAlertAction alloc] initWithTitle:@"确认" style:LHAlertActionStyleDefault action:^{
        NSLog(@"确认");
        UIView *v = [alertController viewAtIndex:1];
        UISwitch *sw = [v viewWithTag:123];
        sw.on = YES;
    }];
    
    LHAlertAction *confirmAction2 = [[LHAlertAction alloc] initWithTitle:@"确认2" style:LHAlertActionStyleDestructive action:^{
        NSLog(@"确认");
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [alertController addAction:confirmAction2];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nullable textField) {
//        textField.backgroundColor = [UIColor yellowColor];
    } height:nil];
    
    UIView *customView = [UIView new];
    UISwitch *sw = [[UISwitch alloc] init];
    sw.tag = 123;
    sw.frame = CGRectMake(0, 10, 60, 30);
    [customView addSubview:sw];
    
    [alertController addCustomView:customView height:@60];
    
    for (int i=0; i<15; i++) {
        [alertController addTextViewWithConfigurationHandler:^(UITextView * _Nullable textView) {
//            textView.backgroundColor = [UIColor greenColor];
        } height:nil];
    }
    
    [self presentViewController:alertController animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
