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

+(NSString *) dataToHexString: (NSData *) data {
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithFormat:@"%@", data];

    @autoreleasepool{
        NSRange range;
        NSCharacterSet *invertedHexSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"] invertedSet];
        range = [mutableStr rangeOfCharacterFromSet: invertedHexSet];
        while (range.location != NSNotFound) {
            [mutableStr deleteCharactersInRange: range];
            range = [mutableStr rangeOfCharacterFromSet: invertedHexSet];
        }
    }

    return mutableStr;
}

+(NSData *) hexStringToNSData: (NSString *) str {
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithString: str];
    @autoreleasepool{
        NSRange range;
        NSCharacterSet *invertedHexSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"] invertedSet];
        range = [mutableStr rangeOfCharacterFromSet: invertedHexSet];
        while (range.location != NSNotFound) {
            [mutableStr deleteCharactersInRange: range];
            range = [mutableStr rangeOfCharacterFromSet: invertedHexSet];
        }
    }
    NSMutableData *result = [[NSMutableData alloc] initWithLength: [mutableStr length]/2];
    unsigned char* bytes = [result mutableBytes];
    NSData *strData = [mutableStr dataUsingEncoding: NSASCIIStringEncoding];
    const unsigned char* strBytes = [strData bytes];

    for (FGIntOverflow i = 0; i < [mutableStr length]/2; ++i ) {
        unsigned char tmpByte = strBytes[2*i];
        if (tmpByte > 64) {
            tmpByte += 9;
        }
        unsigned char byte = tmpByte << 4;
        tmpByte = strBytes[2*i + 1];
        if (tmpByte > 64) {
            tmpByte += 9;
        }
        bytes[i] = (byte | (tmpByte & 15));
    }
    return result;
}


+(NSString *) dataToBase32String: (NSData *) data {
    unsigned char base32Chars[32] = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','2','3','4','5','6','7'};
    FGIntOverflow length = [data length];
    const unsigned char *bytes = [data bytes];
    FGIntOverflow i = 0;
    FGIntBase tmpBytes = 0;
    unsigned char bits = 0;
    NSMutableData *result = [[NSMutableData alloc] init];
    while (i < length) {
        tmpBytes = (tmpBytes << 8) | bytes[i];
        bits += 8;
        while (bits > 4) {
            bits -= 5;
            [result appendBytes: &base32Chars[(tmpBytes >> bits) & 31] length: 1];
        }
        ++i;
    }
    if (bits > 0) {
        [result appendBytes: &base32Chars[(tmpBytes & (31 >> (5 - bits))) << (5 - bits)] length: 1];
    }
    [result increaseLengthBy: 1];

    NSString *str = [[NSString alloc] initWithData: result encoding: NSASCIIStringEncoding];
    [result release];

    return str;
}

+(NSData *) base32StringToNSData: (NSString *) str {
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithString: str];
    @autoreleasepool{
        NSRange range;
        NSCharacterSet *invertedBase32Set = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"] invertedSet];
        range = [mutableStr rangeOfCharacterFromSet: invertedBase32Set];
        while (range.location != NSNotFound) {
            [mutableStr deleteCharactersInRange: range];
            range = [mutableStr rangeOfCharacterFromSet: invertedBase32Set];
        }
    }
    NSData *strData = [mutableStr dataUsingEncoding: NSASCIIStringEncoding];
    const unsigned char* strBytes = [strData bytes];
    FGIntOverflow strLength = [mutableStr length];
    FGIntOverflow resultLength = strLength * 5 / 8 + ((((strLength*5)%8) == 0)?0:1);
    NSMutableData *result = [[NSMutableData alloc] initWithLength: resultLength];
    unsigned char* bytes = [result mutableBytes];
    FGIntOverflow i = 0, resultIdx = 0;
    FGIntOverflow tmpBytes = 0;
    unsigned char bits = 0;
    while ( i < strLength ) {
        unsigned char tmpByte = strBytes[i];
        if (tmpByte < 56) {
            tmpByte += 41;
        }
        tmpByte -= 1;
        tmpByte &= 31;
        tmpBytes = tmpByte | (tmpBytes << 5);
        ++i;
        bits += 5;
        if ((bits > 7) && (resultIdx < resultLength)) {
            bits -= 8;
            bytes[resultIdx] = tmpBytes >> bits;
            ++resultIdx;
        }
        if ((i == strLength) && (bits > 0) && (resultIdx < resultLength)) {
            tmpBytes = tmpBytes ^ ((tmpBytes >> bits) << bits);
            if (tmpBytes != 0) {
                bytes[resultIdx] = tmpBytes;
                ++resultIdx;
            }
        }
    }
    if (resultIdx < resultLength) {
        [result setLength: resultIdx];
    }

    return result;
}





@end































