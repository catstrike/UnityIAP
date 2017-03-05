//
//  NSData+CompatibleBase64.h
//  Unity-iPhone
//
//  Created by Lenar Sharipov on 25/02/16.
//
//

#import <Foundation/Foundation.h>

@interface NSData(CompatibleBase64)

- (NSString *)anySdkBase64Encoded;
- (NSString *)toHex;

@end
