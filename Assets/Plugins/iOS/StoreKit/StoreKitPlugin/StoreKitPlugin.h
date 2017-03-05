//
//  StoreKitPlugin.h
//  Unity-iPhone
//
//  Created by Lenar Sharipov on 19/02/16.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "NSData+CompatibleBase64.h"
#import "LifeCycleListener.h"

typedef void (^OnDoneBlock)(void);
typedef void (^OnDoneWithProductsBlock)(NSArray<SKProduct *> * __nonnull);
typedef void (^OnErrorBlock)(NSString * __nonnull);

@protocol StoreKitPluginDelegate <NSObject>
@required
- (void)transaction:(nonnull NSString *)transactionId withProduct:(nonnull NSString *)productId purchasedWithReceipt:(nonnull NSString *)receipt;
- (void)transaction:(nonnull NSString *)transactionId withProduct:(nonnull NSString *)productId failedWithError:(nonnull NSString *)error;
@end

@interface StoreKitPlugin: NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, nullable)id<StoreKitPluginDelegate> delegate;

+ (instancetype __nullable)shared;

- (void)validateProductIdentifiers:(nonnull NSArray<NSString *> *)productItentifiers onDone:(nonnull OnDoneWithProductsBlock)onDone onError:(nonnull OnErrorBlock)onError;

- (void)purchaseByProductId:(nonnull NSString *)productId;
- (void)purchase:(nonnull SKProduct *)product;

- (void)finishTransactionById:(nonnull NSString *)transactionId;
- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction;
- (void)triggerUnfinishedTransactions;
@end
