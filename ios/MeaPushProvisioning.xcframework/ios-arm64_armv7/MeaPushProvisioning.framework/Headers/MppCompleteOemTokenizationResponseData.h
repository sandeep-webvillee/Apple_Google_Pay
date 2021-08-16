//
//  MppCompleteOemTokenizationResponseData.h
//  MeaPushProvisioning
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MppCompleteOemTokenizationResponseData : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString *encryptedPassData;
@property (nonatomic, copy, readonly, nonnull) NSString *activationData;
@property (nonatomic, copy, readonly, nonnull) NSString *ephemeralPublicKey;

@property (nonatomic, copy, readonly, nullable) PKAddPaymentPassRequest *addPaymentPassRequest;

+ (instancetype)responseDataWithEncryptedPassData:(NSString *_Nonnull)encryptedPassData
                                   activationData:(NSString *_Nonnull)activationData
                               ephemeralPublicKey:(NSString *_Nonnull)ephemeralPublicKey;

+ (instancetype)responseDataWithDictionary:(NSDictionary *_Nonnull)dictionary;
- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
