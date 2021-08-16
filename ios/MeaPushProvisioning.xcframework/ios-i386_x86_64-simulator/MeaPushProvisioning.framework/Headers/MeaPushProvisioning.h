//
//  MeaPushProvisioning.h
//  MeaPushProvisioning
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

#import <MeaPushProvisioning/MppCardDataParameters.h>
#import <MeaPushProvisioning/MppCompleteOemTokenizationData.h>
#import <MeaPushProvisioning/MppCompleteOemTokenizationResponseData.h>
#import <MeaPushProvisioning/MppInitializeOemTokenizationResponseData.h>
#import <MeaPushProvisioning/MppGetTokenRequestorsResponseData.h>
#import <MeaPushProvisioning/MppGetTokenizationReceiptResponseData.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeaPushProvisioning : NSObject

+ (NSString *_Nonnull)paymentAppInstanceId;

+ (void)getTokenRequestors:(NSArray *_Nonnull)accountRanges
         completionHandler:(void (^)(MppGetTokenRequestorsResponseData *_Nullable tokenRequestors, NSError *_Nullable error))completionHandler;

+ (void)getTokenizationReceipt:(NSString *_Nonnull)tokenRequestorId
                      cardData:(MppCardDataParameters *_Nonnull)cardDataParameters
             completionHandler:(void (^)(MppGetTokenizationReceiptResponseData *_Nullable data, NSError *_Nullable error))completionHandler;

+ (void)initializeOemTokenization:(MppCardDataParameters *_Nonnull)cardDataParameters
                completionHandler:(void (^)(MppInitializeOemTokenizationResponseData *_Nullable data, NSError *_Nullable error))completionHandler;

+ (void)completeOemTokenization:(MppCompleteOemTokenizationData *_Nonnull)tokenizationData
                completionHandler:(void (^)(MppCompleteOemTokenizationResponseData *_Nullable data, NSError *_Nullable error))completionHandler;

+ (BOOL)canAddPaymentPassWithPrimaryAccountIdentifier:(NSString *_Nonnull)primaryAccountIdentifier;
+ (BOOL)paymentPassExistsWithPrimaryAccountIdentifier:(NSString *_Nonnull)primaryAccountIdentifier;
+ (BOOL)remotePaymentPassExistsWithPrimaryAccountIdentifier:(NSString *_Nonnull)primaryAccountIdentifier;

+ (NSString *)versionCode;
+ (NSString *)versionName;
+ (void)setDebugLoggingEnabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END
