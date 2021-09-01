//
//  MTReachabilityManager.h
//  EcreationsApp
//
//  Created by Developer on 29/03/14.
//  Copyright (c) 2014 ecreations. All rights reserved.
//

@class Reachability;

#import <Foundation/Foundation.h>


@interface MTReachabilityManager : NSObject

@property (strong, nonatomic) Reachability *reachability;

#pragma mark -
#pragma mark Shared Manager
+ (MTReachabilityManager *)sharedManager;

#pragma mark -
#pragma mark Class Methods
+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end
