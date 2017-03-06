//
//  StoreKitApi.h
//  Unity-iPhone
//
//  Created by Lenar Sharipov on 25/02/16.
//
//

// MARK - Types
typedef struct {
    const char * productId;
    const char * title;
    const char * formatedPrice;
    const char * currency;
    float price;
} ProductInterop;

typedef void (*ProductsErrorCallback)(int, const char *);
typedef void (*ProductsCallback)(int, ProductInterop *, int);
typedef void (*TransactionStatePurchasedCallback)(const char *, const char *, const char *);
typedef void (*TransactionStateErrorCallback)(const char *, const char *, const char *);
