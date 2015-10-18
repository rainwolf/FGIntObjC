#import "FGIntXtra.h"


@implementation FGIntXtra




+(NSData *) SHA256HMACForKey: (NSData *) key AndData: (NSData *)data {
    NSMutableData *hmac = [[NSMutableData alloc] initWithLength: CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, [key bytes], [key length], [data bytes], [data length], [hmac mutableBytes]);
    return hmac;
}

+(NSData *) SHA256: (NSData *) plainText {
    NSMutableData *hash = [[NSMutableData alloc] initWithLength: CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([plainText bytes], (unsigned int) [plainText length], [hash mutableBytes]);
    return hash;
}

+(NSData *) SHA512: (NSData *) plainText {
    NSMutableData *hash = [[NSMutableData alloc] initWithLength: CC_SHA512_DIGEST_LENGTH];
    CC_SHA512([plainText bytes], (unsigned int) [plainText length], [hash mutableBytes]);
    return hash;
}



+(void) incrementNSMutableData: (NSMutableData *) data {
    unsigned char *bytes = [data mutableBytes];
    FGIntBase one = 1u;
    for ( FGIntOverflow i = 0; i < [data length]; ++i ) {
        one = one + bytes[i];
        bytes[i] = one;
        one >>= 8;
    }
}

@end