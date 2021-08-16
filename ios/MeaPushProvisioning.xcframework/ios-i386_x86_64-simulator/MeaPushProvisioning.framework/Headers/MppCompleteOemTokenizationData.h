//
//  MppCompleteOemTokenizationData.h
//  MeaPushProvisioning
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MppCompleteOemTokenizationData : NSObject

@property (nonatomic, copy, readonly, nonnull) NSString *tokenizationReceipt;
@property (nonatomic, copy, readonly, nonnull) NSArray<NSData *> *certificates;
@property (nonatomic, copy, readonly, nonnull) NSData *nonce;
@property (nonatomic, copy, readonly, nonnull) NSData *nonceSignature;

+ (instancetype)tokenizationDataWithTokenizationReceipt:(NSString *_Nonnull)tokenizationReceipt
                                           certificates:(NSArray<NSData *> *_Nonnull)certificates
                                                  nonce:(NSData *_Nonnull)nonce
                                         nonceSignature:(NSData *_Nonnull)nonceSignature;

- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
