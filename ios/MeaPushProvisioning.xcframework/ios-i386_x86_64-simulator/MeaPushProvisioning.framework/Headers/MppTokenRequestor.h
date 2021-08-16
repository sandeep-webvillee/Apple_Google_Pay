//
//  MeaTokenRequestor.h
//  MeaPushProvisioning
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MppTokenRequestor : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *tokenRequestorId;
@property (nonatomic, copy, readonly, nullable) NSString *name;
@property (nonatomic, copy, readonly, nullable) NSString *consumerFacingEntityName;
@property (nonatomic, copy, readonly, nullable) NSString *imageAssetId;
@property (nonatomic, copy, readonly, nullable) NSString *tokenRequestorType;
@property (nonatomic, copy, readonly, nullable) NSString *walletId;

@property (nonatomic, copy, readonly, nullable) NSArray *enabledAccountRanges;
@property (nonatomic, copy, readonly, nullable) NSArray *supportedPushMethods;

@property (nonatomic, assign, readonly) BOOL supportsMultiplePushedCards;

+ (instancetype)tokenRequestorWithDictionary:(NSDictionary *_Nonnull)dictionary;
- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
