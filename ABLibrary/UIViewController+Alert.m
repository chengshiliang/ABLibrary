//
//  UIViewController+Alert.m
//  ABTest
//
//  Created by HeT on 17/5/10.
//  Copyright © 2017年 chengsl. All rights reserved.
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)
- (void)showErrorWith:(NSError *)error{
    NSDictionary *dict = error.userInfo;
    if (IS_IOS8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:dict[kABAlertTitle] message:dict[kABAlertMessage] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alert addAction:confirm];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:dict[kABAlertTitle] message:dict[kABAlertMessage] delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
        [alert show];
    }
}
@end
