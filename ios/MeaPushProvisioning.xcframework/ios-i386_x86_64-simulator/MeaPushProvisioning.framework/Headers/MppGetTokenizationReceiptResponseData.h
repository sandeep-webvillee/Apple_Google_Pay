//
//  MppGetTokenizationReceiptResponseData.h
//  MeaPushProvisioning
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MeaPushProvisioning/MppAvailablePushMethod.h>

NS_ASSUME_NONNULL_BEGIN

@interface MppGetTokenizationReceiptResponseData : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString *receipt;
@property (nonatomic, copy, readonly, nonnull) NSArray<MppAvailablePushMethod *> *availablePushMethods;
@property (nonatomic, copy, readonly, nonnull) NSString *lastFourDigits;
@property (nonatomic, copy, readonly, nonnull) NSString *paymentNetwork;

+ (instancetype)responseDataWithDictionary:(NSDictionary *_Nonnull)dictionary;
- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
