//
//  NSData+CompatibleBase64.m
//  Unity-iPhone
//
//  Created by Lenar Sharipov on 25/02/16.
//
//

#import "NSData+CompatibleBase64.h"

@implementation NSData(CompatibleBase64)

- (NSString *)anySdkBase64Encoded {
    if ([self respondsToSelector:@selector(base64EncodedStringWithOptions:)]) {
        return [self base64EncodedStringWithOptions:0];
    }
    
    return [self base64Encoding];
}

- (NSString *)toHex {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer) {
        return [NSString string];
    }
    
    NSUInteger dataLength  = [self length];
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    
    return [NSString stringWithString:hexString];
}

@end
