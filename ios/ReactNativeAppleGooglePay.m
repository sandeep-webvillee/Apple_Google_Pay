// ReactNativeAppleGooglePay.m

#import "ReactNativeAppleGooglePay.h"


@implementation ReactNativeAppleGooglePay

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)
{
    // TODO: Implement some actually useful functionality
    callback(@[[NSString stringWithFormat: @"numberArgument: %@ stringArgument: %@", numberArgument, stringArgument]]);
}
RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(getTokenReturn)
{
    return [NSString stringWithFormat:@"%s", "Sandeep Singh s"];
}
RCT_REMAP_METHOD(generateDynamicLink,code:(NSString *)code
                 findEventsWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSURL *link = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://www.beeprof.com?invitedBy=%@",code]];
//    NSString *dynamicLinksDomainURIPrefix = @"https://beeprof.page.link";
//    FIRDynamicLinkComponents *linkBuilder = [[FIRDynamicLinkComponents alloc]
//                                             initWithLink:link
//                                                   domainURIPrefix:dynamicLinksDomainURIPrefix];
//    linkBuilder.iOSParameters = [[FIRDynamicLinkIOSParameters alloc]
//                                 initWithBundleID:@"com.beeprof"];
//    linkBuilder.androidParameters = [[FIRDynamicLinkAndroidParameters alloc]
//                                     initWithPackageName:@"com.beeprof"];
//
//    NSLog(@"The long URL is: %@", linkBuilder.url);
//    NSString * urlName =  [NSString stringWithFormat:@"%@",linkBuilder.url];

  if (link) {
    resolve(link);
      NSLog(@"The long URL is: %@", link);
  } else {
      NSError *error = @"Error";
    reject(@"no_events", @"There were no events", error);
  }
}
@end
