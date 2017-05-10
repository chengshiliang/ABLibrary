//
//  ABHandle.h
//  ABTest
//
//  Created by HeT on 17/5/9.
//  Copyright © 2017年 chengsl. All rights reserved.
//

#import "ABHeader.h"

typedef void (^FailureBlock)(NSError *error);
typedef void (^CompletBlock)(id content);
@interface ABHandle : NSObject

@property (nonatomic, assign) BOOL accessRequest;

//请求用户权限
- (void)requestAccessWithFailureBlock:(FailureBlock)failureBlock completBlock:(CompletBlock)compleBlock;

- (void)fetchContactsWithFailureBlock:(FailureBlock)failureBlock completBlock:(CompletBlock)compleBlock;
@end
