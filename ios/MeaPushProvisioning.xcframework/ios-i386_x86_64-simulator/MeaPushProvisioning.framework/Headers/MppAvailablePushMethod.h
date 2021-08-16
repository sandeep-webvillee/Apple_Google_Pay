//
//  MppAvailablePushMethod.h
//  MeaPushProvisioning
//
//  Copyright © 2019 MeaWallet AS. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MppAvailablePushMethod : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *type;
@property (nonatomic, copy, readonly, nullable) NSString *uri;

+ (instancetype)availablePushMethodWithDictionary:(NSDictionary *_Nonnull)dictionary;
- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END
