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
    return [NSString stringWithFormat:@"%s", "Sandeep Singh"];
}
@end
