//
//  MppInitializeOemTokenizationResponseData.h
//  MeaPushProvisioning
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MppInitializeOemTokenizationResponseData : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString *tokenizationReceipt;
@property (nonatomic, copy, readonly, nonnull) NSString *primaryAccountSuffix;
@property (nonatomic, copy, readonly, nonnull) NSString *networkName;
@property (nonatomic, copy, readonly, nullable) NSString *cardholderName;
@property (nonatomic, copy, readonly, nullable) NSString *localizedDescription;
@property (nonatomic, copy, readonly, nullable) NSString *primaryAccountIdentifier;
@property (nonatomic, assign, readonly) NSUInteger validFor;

@property (nonatomic, copy, readonly, nullable) PKAddPaymentPassRequestConfiguration *addPaymentPassRequestConfiguration;
@property (nonatomic, copy, readonly, nonnull) PKEncryptionScheme encryptionScheme;
@property (nonatomic, copy, readonly, nonnull) PKPaymentNetwork paymentNetwork;

+ (instancetype)responseDataWithTokenizationReceipt:(NSString *_Nonnull)tokenizationReceipt
                               primaryAccountSuffix:(NSString *_Nonnull)primaryAccountSuffix
                                        networkName:(NSString *_Nonnull)networkName
                                     cardholderName:(NSString *_Nullable)cardholderName
                               localizedDescription:(NSString *_Nullable)localizedDescription
                           primaryAccountIdentifier:(NSString *_Nullable)primaryAccountIdentifier
                                           validFor:(NSUInteger)validFor;

+ (instancetype)responseDataWithDictionary:(NSDictionary *_Nonnull)dictionary;
- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
