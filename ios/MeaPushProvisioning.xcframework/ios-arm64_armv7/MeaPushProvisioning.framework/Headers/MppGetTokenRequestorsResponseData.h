//
//  MppGetTokenRequestorsResponseData.h
//  MeaPushProvisioning
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MppTokenRequestor.h"

NS_ASSUME_NONNULL_BEGIN

@interface MppGetTokenRequestorsResponseData : NSObject

@property (nonatomic, copy, readonly, nonnull) NSArray *tokenRequestors;

+ (instancetype)responseDataWithDictionary:(NSDictionary *_Nonnull)dictionary;
- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
