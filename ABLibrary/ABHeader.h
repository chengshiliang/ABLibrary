//
//  ABHeader.h
//  ABTest
//
//  Created by HeT on 17/5/10.
//  Copyright © 2017年 chengsl. All rights reserved.
//

#ifndef ABHeader_h
#define ABHeader_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
static NSInteger NoAccessErrorCode = 10010;
static NSString *const kABContactChangeName = @"ABContactChanged";
#define IS_IOS9 [[[UIDevice currentDevice]systemVersion]floatValue]>=9.0
#define IS_IOS8 [[[UIDevice currentDevice]systemVersion]floatValue]>=8.0
#define kABAlertTitle @"title"
#define kABAlertMessage @"message"
#define kABErrorDomain @"ABErrorDomain"
#define ErrorDesript(message,title) [NSError errorWithDomain:@"ABErrorDomain" code:-1 userInfo:@{kABAlertTitle:title,kABAlertMessage:message}]
#endif /* ABHeader_h */
