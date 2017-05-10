//
//  ABHandle.m
//  ABTest
//
//  Created by HeT on 17/5/9.
//  Copyright © 2017年 chengsl. All rights reserved.
//

#import "ABHandle.h"
#import "ABModel.h"

@interface ABHandle()
@property (nonatomic, copy) NSArray *failBlocks;
@property (nonatomic, copy) NSArray *compleBlocks;
@end
@implementation ABHandle
- (instancetype)init{
    if (self == [super init]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(contactStoreChanged:) name:CNContactStoreDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)contactStoreChanged:(NSNotification *)noti{
    NSLog(@"notify-----\n%@",noti);
    [[NSNotificationCenter defaultCenter]postNotificationName:kABContactChangeName object:nil];
}
//请求用户权限
- (void)requestAccessWithFailureBlock:(FailureBlock)failureBlock completBlock:(CompletBlock)compleBlock{
    [self setCompletBlock:compleBlock failBlock:failureBlock];
    if (IS_IOS9) {
        __weak ABHandle *weakSelf = self;
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusAuthorized) {
            self.accessRequest = YES;
            [self authSuccess:@"已经获取用户权限"];
        } else if (status == CNAuthorizationStatusNotDetermined) {
            CNContactStore *store = [[CNContactStore alloc]init];
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong ABHandle *strongSelf = weakSelf;
                    if (granted) {
                        strongSelf.accessRequest = YES;
                        [strongSelf authSuccess:@"已经获取用户权限"];
                    } else {
                        strongSelf.accessRequest = NO;
                        if (error) {
                            [strongSelf alertWithContent:[NSString stringWithFormat:@"%@%@",@"获取用户权限失败",error.userInfo.description] title:@"提示"];
                        } else {
                            [strongSelf alertWithContent:@"未开通通讯录权限" title:@"提示"];
                        }
                    }
                });
            }];
        } else {
            self.accessRequest = NO;
            [self alertWithContent:@"未开通通讯录权限" title:@"提示"];
        }
    } else {
        __weak ABHandle *weakSelf = self;
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusAuthorized) {
            self.accessRequest = YES;
            [self authSuccess:@"已经获取用户权限"];
        } else if (status == kABAuthorizationStatusNotDetermined) {
            __strong ABHandle *strongSelf = weakSelf;
            ABAddressBookRef ab = ABAddressBookCreate();
            ABAddressBookRequestAccessWithCompletion(ab, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    strongSelf.accessRequest = YES;
                    [strongSelf authSuccess:@"已经获取用户权限"];
                } else {
                    strongSelf.accessRequest = NO;
                    if (error) {
                        CFDictionaryRef dictRef = CFErrorCopyUserInfo(error);
                        [strongSelf alertWithContent:[NSString stringWithFormat:@"%@%@",@"获取用户权限失败",((__bridge NSDictionary *)dictRef).description] title:@"提示"];
                    } else {
                        [strongSelf alertWithContent:@"未开通通讯录权限" title:@"提示"];
                    }
                }
                });
            });
        } else {
            self.accessRequest = NO;
            [self alertWithContent:@"未开通通讯录权限" title:@"提示"];
        }
    }
}

- (void)fetchContactsWithFailureBlock:(FailureBlock)failureBlock completBlock:(CompletBlock)compleBlock{
    if (![self getAuthStatusWithFailureBlock:failureBlock completBlock:compleBlock]) {
        return;
    }
    [self setCompletBlock:compleBlock failBlock:failureBlock];
    if (IS_IOS9) {
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc]initWithKeysToFetch:@[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactPhoneNumbersKey,CNContactEmailAddressesKey]];
        CNContactStore *store = [[CNContactStore alloc]init];
        NSError *error = nil;
        NSMutableArray *contactsM = [NSMutableArray array];
        __weak ABHandle *weakSelf = self;
        [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            if (error) {
                [weakSelf alertWithContent:@"获取联系人失败" title:@"提示"];
            } else {
                ABModel *model = [ABModel initWithContact:contact];
                [contactsM addObject:model];
            }
        }];
        if (!error) {
            [self fetchContactComplet:[contactsM copy]];
        }
    } else {
        ABAddressBookRef ab = ABAddressBookCreate();
        CFArrayRef contacts = (ABAddressBookCopyArrayOfAllPeople(ab));
        CFIndex contactCount = ABAddressBookGetPersonCount(ab);
        NSMutableArray *contactsM = [NSMutableArray array];
        for (CFIndex i=0; i<contactCount; i++) {
            ABRecordRef contact = CFArrayGetValueAtIndex(contacts, i);
            ABModel *model = [ABModel initWithABAddress:contact];
            [contactsM addObject:model];
        }
        [self fetchContactComplet:[contactsM copy]];
    }
}

- (BOOL)getAuthStatusWithFailureBlock:(FailureBlock)failureBlock completBlock:(CompletBlock)compleBlock{
    if (IS_IOS9) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusAuthorized) {
            return YES;
        }
    } else {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusAuthorized) {
            return YES;
        }
    }
    failureBlock(ErrorDesript(@"未开通通讯录权限", @"提示"));
    return NO;
}

- (void)setCompletBlock:(CompletBlock)completBlock failBlock:(FailureBlock)failBlock{
    if (completBlock) {
        NSMutableArray *compleBlockM = [NSMutableArray arrayWithArray:self.compleBlocks];
        [compleBlockM addObject:completBlock];
        self.compleBlocks = [compleBlockM copy];
    }
    if (failBlock) {
        NSMutableArray *failBlockM = [NSMutableArray arrayWithArray:self.failBlocks];
        [failBlockM addObject:failBlock];
        self.failBlocks = [failBlockM copy];
    }
}

- (void)alertWithContent:(NSString *)content title:(NSString *)title{
    if (self.failBlocks.count) {
        FailureBlock failBlock = self.failBlocks.lastObject;
        failBlock(ErrorDesript( content, title));
        [self clearFailBlock];
    }
}

- (void)authSuccess:(NSString *)content{
    if (self.compleBlocks.count) {
        CompletBlock compleBlock = self.compleBlocks.lastObject;
        compleBlock(content);
        [self clearCompleBlock];
    }
}

- (void)fetchContactComplet:(NSArray *)contacts{
    if (self.compleBlocks.count) {
        CompletBlock compleBlock = self.compleBlocks.lastObject;
        compleBlock(contacts);
        [self clearCompleBlock];
    }
}

- (void)clearBlock{
    [self clearFailBlock];
    [self clearCompleBlock];
}

- (void)clearFailBlock{
    NSMutableArray *failBlockM = [NSMutableArray arrayWithArray:self.failBlocks];
    [failBlockM removeLastObject];
    self.failBlocks = [failBlockM copy];
}

- (void)clearCompleBlock{
    NSMutableArray *compleBlockM = [NSMutableArray arrayWithArray:self.compleBlocks];
    [compleBlockM removeLastObject];
    self.compleBlocks = [compleBlockM copy];
}
@end
