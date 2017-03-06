//
//  StoreKitApi.mm
//  Pirates
//
//  Created by Lenar Sharipov on 19/02/16.
//
//
#import "StoreKitPlugin.h"
#import "PluginUtility.h"
#import "StoreKitApi.h"
#import "StoreKitPluginHandler.h"


extern "C" {
    // MARK: - Global state
    TransactionStatePurchasedCallback _purchasedCallback = NULL;
    TransactionStateErrorCallback _errorCallback = NULL;

    // MARK: - Internal methods
    void logProducts(NSArray<SKProduct *> *products) {
        for (SKProduct * product in products) {
            NSLog(@"%@: %@", product.localizedTitle, formatPrice(product.price, product.priceLocale));
        }
    }

    ProductInterop *productArrayToProductInteropArray(NSArray<SKProduct *> *products) {
        int count = (int)products.count;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        ProductInterop *result = (ProductInterop *)calloc(count + 1, sizeof(ProductInterop));
        
        for (int i = 0; i < count; i += 1) {
            ProductInterop *productInterop = &result[i];
            SKProduct * product = [products objectAtIndex:i];
            
            [formatter setLocale:product.priceLocale];
            
            productInterop->productId = makeStringCopy(product.productIdentifier);
            productInterop->title = makeStringCopy(product.localizedTitle);
            productInterop->formatedPrice = makeStringCopy(formatPrice(product.price, product.priceLocale));
            productInterop->currency = makeStringCopy([formatter currencyCode]);
            productInterop->price = product.price.floatValue;
        }
        
        return result;
    }

    void destroyProductInteropArray(ProductInterop *productInteropArray, int count) {
        
        for (int i = 0; i < count; i += 1) {
            ProductInterop *productInterop = &productInteropArray[i];
            
            free((void *)productInterop->productId);
            free((void *)productInterop->title);
            free((void *)productInterop->formatedPrice);
            free((void *)productInterop->currency);
        }
        
        free((void *)productInteropArray);
    }


    // MARK: - Public Methods
    void storeKit_validateProductIdentifiers(int tag, const char **ids, int count, ProductsCallback onDone, ProductsErrorCallback onError) {
        NSLog(@"Requesting products!");

        StoreKitPlugin *plugin = [StoreKitPlugin shared];

        NSArray<NSString *> * arrayOfIds = stringArrayToNSArray(ids, count);

        [plugin validateProductIdentifiers:arrayOfIds onDone:^(NSArray<SKProduct *> *products){
            int itemsCount = (int)products.count;
            
            ProductInterop *productInteropArray = productArrayToProductInteropArray(products);
            
            // Callback
            onDone(tag, productInteropArray, itemsCount);
            
            destroyProductInteropArray(productInteropArray, itemsCount);
            
            NSLog(@"Done!");
        } onError:^(NSString * error) {
            NSLog(@"Error: %@", error);
            const char * errorCString = makeStringCopy(error);
            onError(tag, errorCString);
            free((void *) errorCString);
        }];
    }
    
    void storeKit_purchase(const char *productId) {
        StoreKitPlugin * plugin = [StoreKitPlugin shared];
        [plugin purchaseByProductId:toNSString(productId)];
    }
    
    void storeKit_finishTransaction(const char *transactionId) {
        StoreKitPlugin * plugin = [StoreKitPlugin shared];
        [plugin finishTransactionById:toNSString(transactionId)];
    }
    
    void storeKit_setTransactionStatePurchasedCallback(TransactionStatePurchasedCallback callback) {
        _purchasedCallback = callback;
        
        StoreKitPlugin * plugin = [StoreKitPlugin shared];
        plugin.delegate = [StoreKitPluginHandler withPurchasedCallback:_purchasedCallback andErrorCallback:_errorCallback];
    }
    
    void storeKit_setTransactionStateErrorCallback(TransactionStateErrorCallback callback) {
        _errorCallback = callback;
        
        StoreKitPlugin * plugin = [StoreKitPlugin shared];
        plugin.delegate = [StoreKitPluginHandler withPurchasedCallback:_purchasedCallback andErrorCallback:_errorCallback];
    }
    
    void storeKit_triggerUnfinishedTransactions() {
        [[StoreKitPlugin shared] triggerUnfinishedTransactions];
    }
}
