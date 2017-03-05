//
//  StoreKitPluginHandler.h
//  Unity-iPhone
//
//  Created by Lenar Sharipov on 25/02/16.
//
//

#import <Foundation/Foundation.h>
#import "StoreKitPlugin.h"
#import "StoreKitApi.h"

@interface StoreKitPluginHandler : NSObject<StoreKitPluginDelegate>

- (nullable instancetype)initWithPurchasedCallback:(nullable TransactionStatePurchasedCallback)purchasedCallback andErrorCallback:(nullable TransactionStateErrorCallback)errorCallback;
+ (nullable instancetype)withPurchasedCallback:(nullable TransactionStatePurchasedCallback)purchasedCallback andErrorCallback:(nullable TransactionStateErrorCallback)errorCallback;

@end
