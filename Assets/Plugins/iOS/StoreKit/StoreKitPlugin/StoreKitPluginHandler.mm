//
//  StoreKitPluginHandler.m
//  Unity-iPhone
//
//  Created by Lenar Sharipov on 25/02/16.
//
//

#import "StoreKitPluginHandler.h"
#import "PluginUtility.h"

@implementation StoreKitPluginHandler {
    TransactionStatePurchasedCallback _purchasedCallback;
    TransactionStateErrorCallback _errorCallback;
    TransactionStateCanceledCallback _canceledCallback;
}

#pragma mark - LifeCycle
- (nullable instancetype)initWithPurchasedCallback:(nullable TransactionStatePurchasedCallback)purchasedCallback
                                  andErrorCallback:(nullable TransactionStateErrorCallback)errorCallback
                               andCanceledCallback:(nullable TransactionStateCanceledCallback)canceledCallback
{
    if (self = [super init]) {
        _purchasedCallback = purchasedCallback;
        _errorCallback = errorCallback;
        _canceledCallback = canceledCallback;
    }
    
    return self;
}

+ (nullable instancetype)withPurchasedCallback:(nullable TransactionStatePurchasedCallback)purchasedCallback
                              andErrorCallback:(nullable TransactionStateErrorCallback)errorCallback
                           andCanceledCallback:(nullable TransactionStateCanceledCallback)canceledCallback
{
    return [[StoreKitPluginHandler alloc] initWithPurchasedCallback:purchasedCallback
                                                   andErrorCallback:errorCallback
                                                andCanceledCallback:canceledCallback];
}

#pragma mark - StoreKitPluginDelegate
- (void)transaction:(nonnull NSString *)transactionId withProduct:(nonnull NSString *)productId purchasedWithReceipt:(nonnull NSString *)receipt {
    if (_purchasedCallback == NULL) {
        return;
    }
    
    const char * transactionIdCString = makeStringCopy(transactionId);
    const char * productIdCString = makeStringCopy(productId);
    const char * receiptCString = makeStringCopy(receipt);
    
    _purchasedCallback(transactionIdCString, productIdCString, receiptCString);
    
    free((void *)transactionIdCString);
    free((void *)productIdCString);
    free((void *)receiptCString);
}

- (void)transaction:(nonnull NSString *)transactionId withProduct:(nonnull NSString *)productId failedWithError:(nonnull NSString *)error {
    if (_errorCallback == NULL) {
        return;
    }
    
    const char * transactionIdCString = makeStringCopy(transactionId);
    const char * productIdCString = makeStringCopy(productId);
    const char * errorCString = makeStringCopy(error);
    
    _errorCallback(transactionIdCString, productIdCString, errorCString);
    
    free((void *)transactionIdCString);
    free((void *)productIdCString);
    free((void *)errorCString);
}

- (void)transactionCanceled:(nonnull NSString *)transactionId withProduct:(nonnull NSString *)productId {
    if (_errorCallback == NULL) {
        return;
    }
    
    const char * transactionIdCString = makeStringCopy(transactionId);
    const char * productIdCString = makeStringCopy(productId);
    
    _canceledCallback(transactionIdCString, productIdCString);
    
    free((void *)transactionIdCString);
    free((void *)productIdCString);
}

@end
