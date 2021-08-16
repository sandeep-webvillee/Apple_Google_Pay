//
//  MppCardDataParameters.h
//  MeaPushProvisioning
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CardDataType) {
    CardDataTypeSecret = 0,
    CardDataTypeEncryptedPan
};

@interface MppCardDataParameters : NSObject

@property (nonatomic, assign, readonly) CardDataType type;

@property (nonatomic, copy, readonly, nullable) NSString *cardId;
@property (nonatomic, copy, readonly, nullable) NSString *cardSecret;

@property (nonatomic, copy, readonly, nullable) NSString *encryptedCardData;
@property (nonatomic, copy, readonly, nullable) NSString *publicKeyFingerprint;
@property (nonatomic, copy, readonly, nullable) NSString *encryptedKey;
@property (nonatomic, copy, readonly, nullable) NSString *initialVector;

+ (instancetype)cardDataParametersWithCardId:(NSString *_Nonnull)cardId
                                  cardSecret:(NSString *_Nonnull)cardSecret;

+ (instancetype)cardDataParametersWithEncryptedCardData:(NSString *_Nonnull)encryptedCardData
                                   publicKeyFingerprint:(NSString *_Nonnull)publicKeyFingerprint
                                           encryptedKey:(NSString *_Nonnull)encryptedKey
                                          initialVector:(NSString *_Nonnull)initialVector;

- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
