//
//  ABModel.h
//  ABTest
//
//  Created by HeT on 17/5/10.
//  Copyright © 2017年 chengsl. All rights reserved.
//

#import "ABPersonProtocol.h"
#import "ABHeader.h"

@interface ABModel : NSObject<ABPersonProtocol>
@property (nonatomic, copy) NSArray *phones;
@property (nonatomic, copy) NSString *givenName;
@property (nonatomic, copy) NSString *familyName;
@property (nonatomic, copy) NSString *prefixName;
@property (nonatomic, copy) NSString *middleName;
@property (nonatomic, copy) NSString *suffixName;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSArray *e_mails;
+ (instancetype)initWithContact:(CNContact *)contact;
+ (instancetype)initWithABAddress:(ABRecordRef)contact;
@end
