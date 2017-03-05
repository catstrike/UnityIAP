//
//  PluginUtility.h
//  Pirates
//
//  Created by Lenar Sharipov on 19/02/16.
//
//

#import <UIKit/UIKit.h>

NSString * __nonnull formatPrice(NSDecimalNumber * __nonnull price, NSLocale * __nonnull priceLocale);
NSString * __nonnull toNSString(const char * __nonnull string);
NSArray<NSString *> * __nonnull stringArrayToNSArray(const char * __nonnull * __nonnull arrayOfStrings, int count);
char * __nonnull makeStringCopy(NSString * __nonnull string);
char * __nonnull makeCStringCopy(const char * __nonnull string);
