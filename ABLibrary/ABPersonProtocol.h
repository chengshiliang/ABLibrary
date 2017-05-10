//
//  ABPersonProtocol.h
//  ABTest
//
//  Created by HeT on 17/5/10.
//  Copyright © 2017年 chengsl. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ABPersonProtocol <NSObject>
- (NSString *)fullName;
- (NSArray *)phoneNums;
- (NSArray *)emails;
@end
