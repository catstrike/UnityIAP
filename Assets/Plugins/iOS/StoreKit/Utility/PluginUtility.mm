//
//  PluginUtility.mm
//  Pirates
//
//  Created by Lenar Sharipov on 19/02/16.
//
//

#import "PluginUtility.h"

NSString * __nonnull formatPrice(NSDecimalNumber * __nonnull price, NSLocale * __nonnull priceLocale) {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:priceLocale];

    return [numberFormatter stringFromNumber:price];
}

NSString * __nonnull toNSString(const char * __nonnull string) {
    if (string != NULL) {
        return [NSString stringWithUTF8String: string];
    } else {
        return [NSString stringWithUTF8String: ""];
    }
}

NSArray<NSString *> * __nonnull stringArrayToNSArray(const char * __nonnull * __nonnull arrayOfStrings, int count) {
    NSMutableArray<NSString *> * result = [NSMutableArray arrayWithCapacity:count];

    for (int i = 0; i < count; i += 1) {
        [result addObject:toNSString(arrayOfStrings[i])];
    }

    return result;
}

char * __nonnull makeStringCopy(NSString * __nonnull string) {
    return makeCStringCopy([string UTF8String]);
}

char * __nonnull makeCStringCopy(const char * __nonnull string) {
    char *res = (char *)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}