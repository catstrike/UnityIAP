//
//  StoreKitPlugin.mm
//  Pirates
//
//  Created by Lenar Sharipov on 19/02/16.
//
//

#import "StoreKitPlugin.h"
#import "PluginUtility.h"

@interface RequestCallback: NSObject

@property (nonatomic, strong, nullable)OnDoneWithProductsBlock onDoneWithProducts;
@property (nonatomic, strong, nullable)OnErrorBlock onError;

@end

@implementation RequestCallback

- (instancetype)initWithDoneWithProducts:(OnDoneWithProductsBlock)onDoneWithProducts andErrorBlock:(OnErrorBlock)onError {
    if (self = [super init]) {
        self.onDoneWithProducts = onDoneWithProducts;
        self.onError = onError;
    }

    return self;
}

+ (instancetype)withDoneWithProducts:(OnDoneWithProductsBlock)onDoneWithProducts andErrorBlock:(OnErrorBlock)onError {
    return [[RequestCallback alloc] initWithDoneWithProducts:onDoneWithProducts andErrorBlock:onError];
}

@end

@implementation StoreKitPlugin {
    NSMapTable<SKRequest *, RequestCallback *> * __nonnull _requestMap;
    NSDictionary<NSString *, SKProduct *> * __nonnull _products;
}

+ (instancetype)shared {
    static StoreKitPlugin *sharedGameKitHelper;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[StoreKitPlugin alloc] init];
    });

    return sharedGameKitHelper;
}

#pragma mark - LifeCycle
- (instancetype)init {
    if (self = [super init]) {
        _requestMap = [NSMapTable<SKRequest *, RequestCallback *> strongToStrongObjectsMapTable];
        _products = [[NSDictionary alloc] init];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }

    return self;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Actions
- (void)validateProductIdentifiers:(nonnull NSArray<NSString *> *)productItentifiers
                            onDone:(nonnull OnDoneWithProductsBlock)onDone
                           onError:(nonnull OnErrorBlock)onError {
    
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productItentifiers]];
    
    RequestCallback * callback = [RequestCallback withDoneWithProducts:onDone andErrorBlock:onError];
    [self pushCallback:callback forRequest:productsRequest];

    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)purchaseByProductId:(nonnull NSString *)productId {
    SKProduct * product = [_products objectForKey:productId];
    
    if (product == NULL) {
        NSLog(@"[StoreKitPlugin] product with id '%@' doesn't exist or you didn't request the product via 'validateProductIdentifiers' method!", productId);
        return;
    }
    
    [self purchase:product];
}

- (void)purchase:(nonnull SKProduct *)product {
    if (![SKPaymentQueue canMakePayments]) {
        // error
        return;
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)finishTransactionById:(nonnull NSString *)transactionId {
    NSArray<SKPaymentTransaction *> *transactions = [[SKPaymentQueue defaultQueue] transactions];
    
    for (SKPaymentTransaction * transaction in transactions) {
        if ([transaction.transactionIdentifier isEqualToString:transactionId]) {
            [self finishTransaction:transaction];
            break;
        }
    }
}

- (void)finishTransaction:(nonnull SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)triggerUnfinishedTransactions {
    NSArray<SKPaymentTransaction *> * transactions = [SKPaymentQueue defaultQueue].transactions;
    
    for (SKPaymentTransaction * transaction in transactions) {
        if (transaction.transactionState != transaction.transactionState) {
            continue;
        }
        
        [self.delegate transaction:transaction.transactionIdentifier
                       withProduct:transaction.payment.productIdentifier
              purchasedWithReceipt:[transaction.transactionReceipt anySdkBase64Encoded]];
        
    }
}

#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
                [self.delegate transaction:transaction.transactionIdentifier
                               withProduct:transaction.payment.productIdentifier
                      purchasedWithReceipt:[transaction.transactionReceipt anySdkBase64Encoded]];
                
                // Should finish transaction
                break;
            case SKPaymentTransactionStateFailed: {
                NSString *error = (transaction.error) ? [transaction.error description] : @"";
                
                [self.delegate transaction:transaction.transactionIdentifier
                               withProduct:transaction.payment.productIdentifier
                           failedWithError:error];
                // Should finish transaction
                break;
            }
            case SKPaymentTransactionStateRestored:
                // Should finish transaction
                break;
            case SKPaymentTransactionStateDeferred:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"restoreCompletedTransactionsFailedWithError ");
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSArray<SKPaymentTransaction *> * transactions = queue.transactions;
    
    for (SKPaymentTransaction * transaction in transactions) {
        NSLog(@"Transaction state: %li", (long)transaction.transactionState);
    }
    
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished ");
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSMutableDictionary * products = [NSMutableDictionary dictionaryWithDictionary:_products];
    
    for (SKProduct * product in response.products) {
        [products setValue:product forKey:product.productIdentifier];
    }
    
    _products = products;
    
    RequestCallback * callback = [self popCallbackForRequest:request];
    callback.onDoneWithProducts(response.products);
}

#pragma mark - SKRequestDelegate
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    RequestCallback * callback = [self popCallbackForRequest:request];
    callback.onError(error.description);
}

#pragma mark - Request management
- (void)pushCallback:(RequestCallback *)callback forRequest:(SKRequest *)request {
    [_requestMap setObject:callback forKey:request];
}

- (RequestCallback *)popCallbackForRequest:(SKRequest *)request {
    RequestCallback * callback = [_requestMap objectForKey:request];
    [_requestMap removeObjectForKey:request];

    return callback;
}

@end
