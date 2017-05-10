//
//  ABModel.m
//  ABTest
//
//  Created by HeT on 17/5/10.
//  Copyright © 2017年 chengsl. All rights reserved.
//

#import "ABModel.h"

@implementation ABModel
+ (instancetype)initWithContact:(CNContact *)contact{
    if (IS_IOS9) {
        return [[self alloc]initWithContact:contact];
    }
    return nil;
}

+ (instancetype)initWithABAddress:(ABRecordRef)contact{
    if (IS_IOS9) {
        return nil;
    }
    return [[self alloc]initWithABAddress:contact];
}

- (instancetype)initWithABAddress:(ABRecordRef)contact{
    if (self == [super init]) {
        ABMultiValueRef phones = ABRecordCopyValue(contact, kABPersonPhoneProperty);
        NSMutableArray *phonesM = [NSMutableArray array];
        for (CFIndex j=0; ABMultiValueGetCount(phones); j++) {
            NSString *phone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, j);
            [phonesM addObject:phone];
        }
        ABMultiValueRef emails = ABRecordCopyValue(contact, kABPersonEmailProperty);
        NSMutableArray *emailsM = [NSMutableArray array];
        for (CFIndex j=0; ABMultiValueGetCount(emails); j++) {
            NSString *email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emails, j);
            [emailsM addObject:email];
        }
        self.phones = [emailsM copy];
        self.phones = [phonesM copy];
        self.prefixName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonPrefixProperty);
        self.middleName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonMiddleNameProperty);
        self.suffixName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonSuffixProperty);
        self.familyName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonFirstNameProperty);
        self.givenName = (__bridge NSString *)ABRecordCopyValue(contact, kABPersonLastNameProperty);
    }
    return self;
}

- (instancetype)initWithContact:(CNContact *)contact{
    if (self == [super init]) {
        self.givenName = contact.givenName;
        self.familyName = contact.familyName;
        self.prefixName = contact.namePrefix;
        self.suffixName = contact.nameSuffix;
        self.middleName = contact.middleName;
        self.nickName = contact.nickname;
        NSMutableArray *phonesM = [NSMutableArray array];
        for (CNLabeledValue<CNPhoneNumber*> *label in contact.phoneNumbers) {
            CNPhoneNumber *number = label.value;
            [phonesM addObject:number.stringValue];
        }
        self.phones = phonesM.count?[phonesM copy]:nil;
        
        NSMutableArray *emailsM = [NSMutableArray array];
        for (CNLabeledValue<NSString*>*label in contact.emailAddresses) {
            NSString *email = label.value;
            [emailsM addObject:email];
        }
        self.e_mails = emailsM.count?[emailsM copy]:nil;
    }
    return self;
}

-(NSArray *)phoneNums{
    return self.phones;
}
-(NSString *)fullName{
    if (self.familyName.length == 0 && self.givenName.length > 0) {
        return self.givenName;
    }
    if (self.givenName.length == 0 && self.familyName.length > 0) {
        return self.familyName;
    }
    if (self.givenName.length == 0 && self.familyName.length == 0) {
        return @"";
    }
    if (self.givenName.length >0 && self.familyName.length > 0) {
        return [NSString stringWithFormat:@"%@%@",self.familyName,self.givenName];
    }
    return [NSString stringWithFormat:@"%@%@%@",self.prefixName,self.middleName,self.suffixName];
}
-(NSArray *)emails{
    return self.e_mails;
}
@end
