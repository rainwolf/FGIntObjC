/*
License, info, etc
------------------
This implementation is made by me, Walied Othman, to contact me mail to rainwolf@submanifold.be, always mention wether it's about 
FGInt for Objective-C, preferably in the subject line. My source code is free, but only to other free software, 
it's a two-way street, if you use my code in an application from which you won't make any money of (e.g. software for the good of 
mankind) then go right ahead, I do demand acknowledgement for my work.  However, if you're using my code in a commercial application, 
an application from which you'll make money, then yes, I charge a license-fee, as described in the license agreement for commercial 
use, see the textfile in this zip-file.
If you're going to use these implementations, let me know, so I can put up a link on my page if desired, I 'm always curious as to 
see where my spawn ends up in.  If any algorithm is patented in your country, you should acquire a license before using it.  Modified 
versions of this software must contain an acknowledgement of the original author (=me).

This implementation is available at 
http://www.submanifold.be

copyright 2012, Walied Othman
This header may not be removed.
*/

#import "FGIntCryptography.h"
#import <Security/SecRandom.h>
#import "FGIntXtra.h"



@implementation FGIntRSA
@synthesize modulus;
@synthesize publicExponent;
@synthesize privateKey;
@synthesize pFGInt;
@synthesize qFGInt;
@synthesize pInvertedModQ;

-(id) init {
    if (self = [super init]) {
        modulus = nil;
        publicExponent = nil;
        privateKey = nil;
        pFGInt = nil;
        qFGInt = nil;
        pInvertedModQ = nil;
    }
    return self;
}


-(id) mutableCopyWithZone: (NSZone *) zone {
    FGIntRSA *newKeys = [[FGIntRSA allocWithZone: zone] init];
    if (modulus) {
        [newKeys setModulus: [modulus mutableCopy]];
    }
    if (publicExponent) {
        [newKeys setPublicExponent: [publicExponent mutableCopy]];
    }
    if (privateKey) {
        [newKeys setPrivateKey: [privateKey mutableCopy]];
    }
    if (pFGInt) {
        [newKeys setPFGInt: [pFGInt mutableCopy]];
    }
    if (qFGInt) {
        [newKeys setQFGInt: [qFGInt mutableCopy]];
    }
    if (pInvertedModQ) {
        [newKeys setPInvertedModQ: [pInvertedModQ mutableCopy]];
    }
    return newKeys;
}


-(id) initWithBitLength: (FGIntOverflow) bitLength {
    if (self = [super init]) {
        FGIntOverflow halfBitLength = (bitLength / 2) + (bitLength % 2);
        FGInt *tmpFGInt;

        __block FGInt *tmpP = [[FGInt alloc] initWithRandomNumberOfBitSize: halfBitLength];
        halfBitLength = bitLength - halfBitLength; 
        __block FGInt *tmpQ = [[FGInt alloc] initWithRandomNumberOfBitSize: halfBitLength];

        dispatch_group_t d_group = dispatch_group_create();
        dispatch_queue_t bg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_group_async(d_group, bg_queue, ^{
            [tmpP findLargerPrime];
        });
        dispatch_group_async(d_group, bg_queue, ^{
            [tmpQ findLargerPrime];
        });
        dispatch_group_wait(d_group, DISPATCH_TIME_FOREVER);
        dispatch_release(d_group);
        pFGInt = tmpP;
        qFGInt = tmpQ;


        if ([FGInt compareAbsoluteValueOf: qFGInt with: pFGInt] == smaller) {
            tmpFGInt = qFGInt;
            qFGInt = pFGInt;
            pFGInt = tmpFGInt;
        }

        modulus = [FGInt multiply: pFGInt and: qFGInt];
        pInvertedModQ = [FGInt invert: pFGInt moduloPrime: qFGInt];
            
        publicExponent = [[FGInt alloc] initWithFGIntBase: 65537];
        [pFGInt decrement];
        [qFGInt decrement];
        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *two = [[FGInt alloc] initWithFGIntBase: 2];
        // FGInt *phi = [FGInt multiply: pFGInt and: qFGInt], *gcd = [FGInt binaryGCD: publicExponent and: phi];
        FGInt *phi = [FGInt multiply: pFGInt and: qFGInt], *gcd = [FGInt gcd: publicExponent and: phi];
        while ([FGInt compareAbsoluteValueOf: gcd with: one] != equal) {
            [publicExponent addWith: two];
            [gcd release];
            gcd = [FGInt gcd: publicExponent and: phi];
        }
        [one release];
        [two release];
        
        privateKey = [FGInt modularInverse: publicExponent mod: phi];
        [gcd release];
        [phi release];
        
        [pFGInt increment];
        [qFGInt increment];
    }
    return self;
}


-(id) initWithNSData: (NSData *) dataSeed {
    if (!dataSeed) {
        NSLog(@"No dataSeed available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if ([dataSeed length] == 0) {
        NSLog(@"dataSeed is empty for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (self = [super init]) {
        FGInt *tmpFGInt;
        FGIntOverflow seedLength = [dataSeed length];
        pFGInt = [[FGInt alloc] initWithNSData: [dataSeed subdataWithRange: NSMakeRange(0, seedLength/2)]];
        qFGInt = [[FGInt alloc] initWithNSData: [dataSeed subdataWithRange: NSMakeRange(seedLength/2, seedLength - seedLength/2)]];
        
        // if ((seedLength % 2) == 0) {
        //     firstBit = 1 << 31;
        //     firstNumberBase = 4294967295;
        //     numberBase = [[pFGInt number] lastObject];
        //     [numberBase setDigit: ([numberBase digit] & firstNumberBase) | firstBit];
        //     numberBase = [[qFGInt number] lastObject];
        //     [numberBase setDigit: ([numberBase digit] & firstNumberBase) | firstBit];
        // } else {
        //     ++seedLength;
        //     firstBit = 1 << 15;
        //     firstNumberBase = 4294967295 >> 16;
        //     numberBase = [[[qFGInt number] lastObject] mutableCopy];
        //     [[pFGInt number] addObject: numberBase];
        //     [numberBase release];
        //     numberBase = [[pFGInt number] lastObject];
        //     [numberBase setDigit: ([numberBase digit] >> 16) | firstBit];
        //     numberBase = [[qFGInt number] lastObject];
        //     [numberBase setDigit: ([numberBase digit] & firstNumberBase) | firstBit];
        // }

        [pFGInt findLargerPrime];
        [qFGInt findLargerPrime];
        
        if ([FGInt compareAbsoluteValueOf: qFGInt with: pFGInt] == smaller) {
            tmpFGInt = qFGInt;
            qFGInt = pFGInt;
            pFGInt = tmpFGInt;
        }

        pInvertedModQ = [FGInt invert: pFGInt moduloPrime: qFGInt];        
        modulus = [FGInt multiply: pFGInt and: qFGInt];
            
        publicExponent = [[FGInt alloc] initWithFGIntBase: 65537];
        
        [pFGInt decrement];
        [qFGInt decrement];
        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *two = [[FGInt alloc] initWithFGIntBase: 2];
        FGInt *phi = [FGInt multiply: pFGInt and: qFGInt], *gcd = [FGInt gcd: publicExponent and: phi];
        while ([FGInt compareAbsoluteValueOf: gcd with: one] != equal) {
            [publicExponent addWith: two];
            [gcd release];
            gcd = [FGInt gcd: publicExponent and: phi];
        }
        [one release];
        [two release];
        
        privateKey = [FGInt modularInverse: publicExponent mod: phi];
        [gcd release];
        [phi release];
        
//        privateKeyP = [FGInt modularInverse: publicExponent mod: pFGInt];
//        privateKeyQ = [FGInt modularInverse: publicExponent mod: qFGInt];
    
        [pFGInt increment];
        [qFGInt increment];

//        privateKey = nil;
    }
    return self;
}

-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData {
    NSData *tmpData;
    unsigned char aBuffer[[publicKeyNSData length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    modulus = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    publicExponent = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
}


-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString {
    NSData *publicKeyNSData = [FGInt convertBase64ToNSData: publicKeyBase64NSString];
    [self setPublicKeyWithNSData: publicKeyNSData];
    [publicKeyNSData release];    
}


-(NSData *) publicKeyToNSData {
    if (!modulus) {
        NSLog(@"No modulus available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!publicExponent) {
        NSLog(@"No publicExponent available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSMutableData *publicKeyData = [[NSMutableData alloc] init];
    NSData *tmpData;
    
    tmpData = [modulus toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [publicExponent toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];
        
    return publicKeyData;
}


-(NSString *) publicKeyToBase64NSString {
    if (!modulus) {
        NSLog(@"No modulus available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!publicExponent) {
        NSLog(@"No publicExponent available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *publicKeyData = [self publicKeyToNSData];
    NSString *publicKeyBase64NSString = [FGInt convertNSDataToBase64: publicKeyData];
    [publicKeyData release];
    return publicKeyBase64NSString;    
}


-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData {
    NSData *tmpData;
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    unsigned char aBuffer[[secretKeyNSData length]];

    if ([secretKeyNSData length] < rangeStart + 2) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8)); 
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([secretKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    privateKey = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart, 2);
    if ([secretKeyNSData length] < rangeStart + 2) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8)); 
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([secretKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    pFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart, 2);
    if ([secretKeyNSData length] < rangeStart + 2) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8)); 
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([secretKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    qFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart, 2);
    if ([secretKeyNSData length] < rangeStart + 2) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8)); 
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([secretKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    pInvertedModQ = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
}


-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString {
    NSData *secretKeyNSData = [FGInt convertBase64ToNSData: secretKeyBase64NSString];
    [self setSecretKeyWithNSData: secretKeyNSData];
    [secretKeyNSData release];
}


-(NSData *) secretKeyToNSData {
    if (!privateKey) {
        NSLog(@"No privateKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!pFGInt) {
        NSLog(@"No pFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!qFGInt) {
        NSLog(@"No qFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!pInvertedModQ) {
        NSLog(@"No pInvertedModQ available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSMutableData *secretKeyData = [[NSMutableData alloc] init];
    NSData *tmpData;
    
    tmpData = [privateKey toMPINSData];
    [secretKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [pFGInt toMPINSData];
    [secretKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [qFGInt toMPINSData];
    [secretKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [pInvertedModQ toMPINSData];
    [secretKeyData appendData: tmpData];
    [tmpData release];

    return secretKeyData;
}


-(NSString *) secretKeyToBase64NSString {
    if (!privateKey) {
        NSLog(@"No privateKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!pFGInt) {
        NSLog(@"No pFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!qFGInt) {
        NSLog(@"No qFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!pInvertedModQ) {
        NSLog(@"No pInvertedModQ available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [self secretKeyToNSData];
    NSString *secretKeyBase64NSString = [FGInt convertNSDataToBase64: secretKeyData];
    [secretKeyData release];
    return secretKeyBase64NSString;    
}


-(void) dealloc {
    if (modulus != nil) {
        [modulus release];
    }
    if (publicExponent != nil) {
        [publicExponent release];
    }
    if (privateKey != nil) {
        [privateKey release];
    }
    if (pFGInt != nil) {
        [pFGInt release];
    }
    if (qFGInt != nil) {
        [qFGInt release];
    }
    if (pInvertedModQ != nil) {
        [pInvertedModQ release];
    }
    [super dealloc];
}   

-(NSData *) encryptNSString: (NSString *) plainText {
    if (!modulus) {
        NSLog(@"No modulus available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!publicExponent) {
        NSLog(@"No publicExponent available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
            
    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding]; 
        NSData *encryptedData = [self encryptNSData: plainTextData];
    //    [plainTextData release];
        return encryptedData;
    }
}

-(NSData *) encryptNSData: (NSData *) plainText {
    FGInt *dataFGInt, *encryptedFGInt;

    if (!modulus) {
        NSLog(@"No modulus available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!publicExponent) {
        NSLog(@"No publicExponent available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    dataFGInt = [[FGInt alloc] initWithNSData: plainText];
    if ([FGInt compareAbsoluteValueOf: dataFGInt with: modulus] != smaller) {
        NSLog(@"plainText (%lu bytes) is too big for %s at line %d, decryption will lead to data loss", [plainText length], __PRETTY_FUNCTION__, __LINE__);
        [dataFGInt release];
        return nil;
    }
        
    encryptedFGInt = [FGInt raise: dataFGInt toThePower: publicExponent montgomeryMod: modulus];
    [dataFGInt release];
    NSData *encryptedData = [encryptedFGInt toNSData];
    [encryptedFGInt release];
    return encryptedData;
}

-(NSData *) decryptNSData: (NSData *) cipherText {
    if (!cipherText) {
        NSLog(@"No cipherText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    FGInt *cipherFGInt, *decryptedFGInt;
    if (pInvertedModQ) {
        if (!privateKey) {
            NSLog(@"No privateKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }
        if (!pFGInt) {
            NSLog(@"No pFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }
        if (!qFGInt) {
            NSLog(@"No qFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }

        cipherFGInt = [[FGInt alloc] initWithNSData: cipherText];
        FGInt *decryptedModQ, *decryptedModP, *tmpFGInt, *privateKeyP, *privateKeyQ;
        
        [pFGInt decrement];
        privateKeyP = [FGInt mod: privateKey by: pFGInt];
        [pFGInt increment];
        decryptedModP = [FGInt raise: cipherFGInt toThePower: privateKeyP montgomeryMod: pFGInt];
        [qFGInt decrement];
        privateKeyQ = [FGInt mod: privateKey by: qFGInt];
        [qFGInt increment];
        decryptedModQ = [FGInt raise: cipherFGInt toThePower: privateKeyQ montgomeryMod: qFGInt];
        [privateKeyP release];
        [privateKeyQ release];
        
        tmpFGInt = [FGInt subtract: decryptedModQ and: decryptedModP];
        decryptedFGInt = [FGInt multiply: tmpFGInt and: pInvertedModQ];
        [tmpFGInt release];
        tmpFGInt = [FGInt mod: decryptedFGInt by: qFGInt];
        [decryptedFGInt release];
        decryptedFGInt = [FGInt multiply: tmpFGInt and: pFGInt];
        [tmpFGInt release];
        [decryptedFGInt addWith: decryptedModP];
            
        [decryptedModP release];
        [decryptedModQ release];            
    } else {
        if (!modulus) {
            NSLog(@"No modulus available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }
        if (!privateKey) {
            NSLog(@"No privateKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }

        cipherFGInt = [[FGInt alloc] initWithNSData: cipherText];
        decryptedFGInt = [FGInt raise: cipherFGInt toThePower: privateKey montgomeryMod: modulus];
    }
    [cipherFGInt release];
    NSData *decryptedData = [decryptedFGInt toNSData];
    [decryptedFGInt release];
    return decryptedData;
}

-(NSData *) signNSString: (NSString *) plainText {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData];
        return signedData;
    }
}


-(NSData *) signNSData: (NSData *) plainText {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    return [self decryptNSData: plainText];
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    NSData *verificationData = [self encryptNSData: signature];
    BOOL signatureCheck;
    FGIntIndex difference = [verificationData length] - [plainText length];
    if (([plainText length] < [verificationData length]) && (difference < 4)) {
        NSMutableData *plainTextMutableData = [plainText mutableCopy];
        [plainTextMutableData increaseLengthBy: difference];
        signatureCheck = [verificationData isEqualToData: plainTextMutableData];
        [plainTextMutableData release];
    } else {
        signatureCheck = [verificationData isEqualToData: plainText];
    }
    [verificationData release];
    return signatureCheck;
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        return [self verifySignature: signature ofPlainTextNSData: plainTextData];
    }
}


@end

























@implementation FGIntElGamal
@synthesize primeFGInt;
@synthesize secretKey;
@synthesize gFGInt;
@synthesize yFGInt;


-(id) init {
    if (self = [super init]) {
        primeFGInt = nil;
        gFGInt = nil;
        secretKey = nil;
        yFGInt = nil;
    }
    return self;
}


-(void) setGFGIntAndComputeY: (FGInt *) newG {
    if (secretKey) {
        if (primeFGInt) {
            if (gFGInt) {
                [gFGInt release];
            }
            gFGInt = newG;
            if (yFGInt) {
                [yFGInt release];
            }
            yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: primeFGInt];
        } else {
            NSLog(@"primeFGInt is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"secretKey is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}

-(void) setSecretKeyAndComputeY: (FGInt *) newSecretKey {
    if (gFGInt) {
        if (primeFGInt) {
            if (secretKey) {
                [secretKey release];
            }
            secretKey = newSecretKey;
            if (yFGInt) {
                [yFGInt release];
            }
            yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: primeFGInt];
        } else {
            NSLog(@"primeFGInt is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"gFGInt is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}


-(id) copyWithZone: (NSZone *) zone {
    FGIntElGamal *newKeys = [[FGIntElGamal allocWithZone: zone] init];
    if (primeFGInt) {
        [newKeys setPrimeFGInt: [primeFGInt mutableCopy]];
    }
    if (gFGInt) {
        [newKeys setGFGInt: [gFGInt mutableCopy]];
    }
    if (secretKey) {
        [newKeys setSecretKey: [secretKey mutableCopy]];
    }
    if (yFGInt) {
        [newKeys setYFGInt: [yFGInt mutableCopy]];
    }
    return newKeys;
}


-(id) initWithBitLength: (FGIntOverflow) bitLength {
    if (self = [super init]) {
        FGIntOverflow byteLength, qBitLength = 0, secretKeyLength;
        FGInt *tmpFGInt, *qFGInt;

        if (bitLength > 7936) qBitLength = (bitLength * 512) / 15424;
        if (bitLength <= 7936) qBitLength = (bitLength * 384) / 7936;
        if (bitLength <= 5312) qBitLength = (bitLength * 320) / 5312;
        if (bitLength <= 3248) qBitLength = (bitLength * 256) / 3248;
        if (bitLength <= 2432) qBitLength = (bitLength * 224) / 2432;
        if (bitLength <= 1248) qBitLength = (bitLength * 160) / 1248;
        if (bitLength <= 816) qBitLength = (bitLength * 128) / 816;
        if (bitLength <= 640) qBitLength = (bitLength * 112) / 640;
        if (bitLength <= 480) qBitLength = (bitLength * 96) / 480;
        byteLength = (qBitLength / 8) + (((qBitLength % 8) == 0) ? 0 : 1);
        qFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: qBitLength];
        [qFGInt findLargerPrime];

        primeFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        [primeFGInt findLargerDSAPrimeWith: qFGInt];

        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        secretKeyLength = qBitLength;
        byteLength = (secretKeyLength / 8) + (((secretKeyLength % 8) == 0) ? 0 : 1);
        do {
            tmpFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: secretKeyLength];
            secretKey = [FGInt mod: tmpFGInt by: qFGInt];
            [tmpFGInt release];
        } while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal));
        [zero release]; 
            
        gFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        gFGInt = [FGInt longDivisionModBis: gFGInt by: primeFGInt];

        FGInt *phi;
        tmpFGInt = [primeFGInt mutableCopy];
        [tmpFGInt decrement];
        NSDictionary *tmpDiv = [FGInt divide: tmpFGInt by: qFGInt];
        [qFGInt release];
        phi = [[tmpDiv objectForKey: quotientKey] retain];
        [tmpDiv release];
        do {
            [gFGInt increment];
            [tmpFGInt release];
            tmpFGInt = [FGInt raise: gFGInt toThePower: phi montgomeryMod: primeFGInt];
        } while ([FGInt compareAbsoluteValueOf: tmpFGInt with: one] == equal);
        [tmpFGInt release];
        [one release];
        [phi release];
        
        yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: primeFGInt];
    }
    return self;
}


-(id) initWithNSData: (NSData *) secretKeyData {
    if (!secretKeyData) {
        NSLog(@"No secretKeyData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if ([secretKeyData length] == 0) {
        NSLog(@"secretKeyData is empty for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (self = [super init]) {
        FGIntOverflow bitLength = 0, byteLength, secretKeyLength = [secretKeyData length]*8, qBitLength = secretKeyLength;
        FGInt *tmpFGInt, *qFGInt;

//        if (bitLength > 7936) qBitLength = (bitLength * 512) / 15424;
//        if (bitLength <= 7936) qBitLength = (bitLength * 384) / 7936;
//        if (bitLength <= 5312) qBitLength = (bitLength * 320) / 5312;
//        if (bitLength <= 3248) qBitLength = (bitLength * 256) / 3248;
//        if (bitLength <= 2432) qBitLength = (bitLength * 224) / 2432;
//        if (bitLength <= 1248) qBitLength = (bitLength * 160) / 1248;
//        if (bitLength <= 816) qBitLength = (bitLength * 128) / 816;
//        if (bitLength <= 640) qBitLength = (bitLength * 112) / 640;
//        if (bitLength <= 480) qBitLength = (bitLength * 96) / 480;

        if (qBitLength > 384) bitLength = (qBitLength * 15424) / 512;
        if (qBitLength <= 384) bitLength = (qBitLength * 7936) / 384;
        if (qBitLength <= 320) bitLength = (qBitLength * 5312) / 320;
        if (qBitLength <= 256) bitLength = (qBitLength * 3248) / 256;
        if (qBitLength <= 224) bitLength = (qBitLength * 2432) / 224;
        if (qBitLength <= 160) bitLength = (qBitLength * 1248) / 160;
        if (qBitLength <= 128) bitLength = (qBitLength * 816) / 128;
        if (qBitLength <= 112) bitLength = (qBitLength * 640) / 112;
        if (qBitLength <= 96) bitLength = (qBitLength * 480) / 96;
        qFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: qBitLength];
        [qFGInt findLargerPrime];

        primeFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        [primeFGInt findLargerDSAPrimeWith: qFGInt];
    
        tmpFGInt = [[FGInt alloc] initWithNSData: secretKeyData];
        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        secretKey = [FGInt mod: tmpFGInt by: qFGInt];
        while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal)) {
            [tmpFGInt increment];
            [secretKey release];
            secretKey = [FGInt mod: tmpFGInt by: qFGInt];
        } 
        [tmpFGInt release];
        [zero release]; 

        byteLength = (bitLength / 8) + (((bitLength % 8) == 0) ? 0 : 1);
        if (byteLength > 0) {
            --byteLength;
        }
        gFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];

        FGInt *phi;
        tmpFGInt = [primeFGInt mutableCopy];
        [tmpFGInt decrement];
        NSDictionary *tmpDiv = [FGInt divide: tmpFGInt by: qFGInt];
        [qFGInt release];
        phi = [[tmpDiv objectForKey: quotientKey] retain];
        [tmpDiv release];
        do {
            [gFGInt increment];
            [tmpFGInt release];
            tmpFGInt = [FGInt raise: gFGInt toThePower: phi montgomeryMod: primeFGInt];
        } while ([FGInt compareAbsoluteValueOf: tmpFGInt with: one] == equal);
        [tmpFGInt release];
        [one release];
        [phi release];
        
        yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: primeFGInt];
    }
    return self;
}

-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData {
    NSData *tmpData;
    unsigned char aBuffer[[publicKeyNSData length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    primeFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    gFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    yFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
}


-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString {
    NSData *publicKeyNSData = [FGInt convertBase64ToNSData: publicKeyBase64NSString];
    [self setPublicKeyWithNSData: publicKeyNSData];
    [publicKeyNSData release];    
}


-(NSData *) publicKeyToNSData {
    if (!primeFGInt) {
        NSLog(@"No primeFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yFGInt) {
        NSLog(@"No yFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSMutableData *publicKeyData = [[NSMutableData alloc] init];
    NSData *tmpData;
    
    tmpData = [primeFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [gFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];
        
    tmpData = [yFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];
        
    return publicKeyData;
}


-(NSString *) publicKeyToBase64NSString {
    NSData *publicKeyData = [self publicKeyToNSData];
    NSString *publicKeyBase64NSString = [FGInt convertNSDataToBase64: publicKeyData];
    [publicKeyData release];
    return publicKeyBase64NSString;    
}


-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData {
    NSData *tmpData;
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    unsigned char aBuffer[[secretKeyNSData length]];

    if ([secretKeyNSData length] < rangeStart + 2) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8)); 
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([secretKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    secretKey = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
}


-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString {
    NSData *secretKeyNSData = [FGInt convertBase64ToNSData: secretKeyBase64NSString];
    [self setSecretKeyWithNSData: secretKeyNSData];
    [secretKeyNSData release];
}


-(NSData *) secretKeyToNSData {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [secretKey toMPINSData];
    return secretKeyData;
}


-(NSString *) secretKeyToBase64NSString {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [self secretKeyToNSData];
    NSString *secretKeyBase64NSString = [FGInt convertNSDataToBase64: secretKeyData];
    [secretKeyData release];
    return secretKeyBase64NSString;    
}


-(void) dealloc {
    if (primeFGInt != nil) {
        [primeFGInt release];
    }
    if (secretKey != nil) {
        [secretKey release];
    }
    if (gFGInt != nil) {
        [gFGInt release];
    }
    if (yFGInt != nil) {
        [yFGInt release];
    }
    [super dealloc];
}

-(NSData *) encryptNSString: (NSString *) plainText {
    if (!primeFGInt) {
        NSLog(@"No primeFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yFGInt) {
        NSLog(@"No yFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
        
    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding]; 
        NSData *encryptedData = [self encryptNSData: plainTextData];
        //    [plainTextData release];
        return encryptedData;
    }
}

-(NSData *) encryptNSData: (NSData *) plainText {
    if (!primeFGInt) {
        NSLog(@"No primeFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yFGInt) {
        NSLog(@"No yFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
        
    FGIntOverflow bitLength = [primeFGInt bitSize], kLength = 0;
    if (([plainText length] * 8) >= bitLength) {
        NSLog(@"plainText is too big for %s at line %d, decryption will lead to data loss", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
        
    FGInt *dataFGInt = [[FGInt alloc] initWithNSData: plainText], *encryptedFGInt, *kFGInt, *hFGInt, *yKFGInt, *tmpFGInt;

    if (bitLength > 7936) kLength = (bitLength * 512) / 15424;
    if (bitLength <= 7936) kLength = (bitLength * 384) / 7936;
    if (bitLength <= 5312) kLength = (bitLength * 320) / 5312;
    if (bitLength <= 3248) kLength = (bitLength * 256) / 3248;
    if (bitLength <= 2432) kLength = (bitLength * 224) / 2432;
    if (bitLength <= 1248) kLength = (bitLength * 160) / 1248;
    if (bitLength <= 816) kLength = (bitLength * 128) / 816;
    if (bitLength <= 640) kLength = (bitLength * 112) / 640;
    if (bitLength <= 480) kLength = (bitLength * 96) / 480;
    kFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: kLength];
        
    hFGInt = [FGInt raise: gFGInt toThePower: kFGInt montgomeryMod: primeFGInt];
    yKFGInt = [FGInt raise: yFGInt toThePower: kFGInt montgomeryMod: primeFGInt];
    [kFGInt release];
    tmpFGInt = [FGInt multiply: dataFGInt and: yKFGInt];
    [yKFGInt release];
    encryptedFGInt = [FGInt mod: tmpFGInt by: primeFGInt];
    [tmpFGInt release];
    [dataFGInt release];

    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    NSData *mpiData;
        
    mpiData = [hFGInt toMPINSData];
    [encryptedData appendData: mpiData];
    [mpiData release];

    mpiData = [encryptedFGInt toMPINSData];
    [encryptedData appendData: mpiData];
    [mpiData release];

    [hFGInt release];
    [encryptedFGInt release];
    return encryptedData;
}

-(NSData *) decryptNSData: (NSData *) cipherText {
    if (!cipherText) {
        NSLog(@"No cipherText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!primeFGInt) {
        NSLog(@"No primeFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    FGInt *cipherFGInt, *decryptedFGInt, *tmpFGInt, *hFGInt, *gKFGInt;
            
    NSData *tmpData;
    unsigned char aBuffer[[cipherText length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([cipherText length] < rangeStart + 2) {
        NSLog(@"cipherText is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [cipherText getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([cipherText length] < rangeStart + keyLength) {
        NSLog(@"cipherText is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    [cipherText getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    gKFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([cipherText length] < rangeStart + 2) {
        NSLog(@"cipherText is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    [cipherText getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([cipherText length] < rangeStart + keyLength) {
        NSLog(@"cipherText is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    [cipherText getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    cipherFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    
    tmpFGInt = [FGInt raise: gKFGInt toThePower: secretKey montgomeryMod: primeFGInt];
    [gKFGInt release];
    hFGInt = [FGInt invert: tmpFGInt moduloPrime: primeFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: hFGInt and: cipherFGInt];
    decryptedFGInt = [FGInt mod: tmpFGInt by: primeFGInt];
    [tmpFGInt release];
    [hFGInt release];
        
    [cipherFGInt release];
    NSData *decryptedData = [decryptedFGInt toNSData];
    [decryptedFGInt release];
    return decryptedData;
}


-(NSData *) signNSString: (NSString *) plainText {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData];
        return signedData;
    }
}


-(NSData *) signNSString: (NSString *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData withRandomNSData: kData];
        return signedData;
    }
}



-(NSData *) signNSData: (NSData *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!primeFGInt) {
        NSLog(@"No primeFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!kData) {
        NSLog(@"No kData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    FGInt *rFGInt, *sFGInt;
    BOOL noLuck;
    FGIntOverflow length;
    FGIntBase* numberArray;
    do {
        FGInt *dataFGInt = [[FGInt alloc] initWithNSData: plainText], *kFGInt, *hFGInt, *tmpFGInt, *kInvertedFGInt;
        FGIntBase j, firstBit;
        kFGInt = [[FGInt alloc] initWithNSData: kData];
        firstBit = (1u << 31);
        numberArray = [[kFGInt number] mutableBytes];
        length = [[kFGInt number] length]/4;
        j = numberArray[length - 1];
        j = j | firstBit;
        numberArray[length - 1] = j;
        
        FGInt *phi = [primeFGInt mutableCopy];
        [phi decrement];
        // gcd = [FGInt binaryGCD: kFGInt and: phi];
        // while ([FGInt compareAbsoluteValueOf: gcd with: one] != equal) {
        //     [gcd release];
        //     [kFGInt increment];
        //     gcd = [FGInt binaryGCD: kFGInt and: phi];
        // }
        // [gcd release];
        // [one release];
        kInvertedFGInt = [FGInt shiftEuclideanInvert: kFGInt mod: phi];
        FGInt *zero = [[FGInt alloc] initAsZero];
        while ([FGInt compareAbsoluteValueOf: kInvertedFGInt with: zero] == equal) {
            [kInvertedFGInt release];
            [kFGInt increment];
            kInvertedFGInt = [FGInt shiftEuclideanInvert: kFGInt mod: phi];
        }
        rFGInt = [FGInt raise: gFGInt toThePower: kFGInt montgomeryMod: primeFGInt];
        // kInvertedFGInt = [FGInt shiftEuclideanInvert: kFGInt mod: phi];
        [kFGInt release];
        tmpFGInt = [FGInt multiply: rFGInt and: secretKey];
        hFGInt = [FGInt subtract: dataFGInt and: tmpFGInt];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: hFGInt and: kInvertedFGInt];
        [kInvertedFGInt release];
        [hFGInt release];
        sFGInt = [FGInt mod: tmpFGInt by: phi];
        [phi release];
        [tmpFGInt release];
        [dataFGInt release];
        
        // FGInt *zero = [[FGInt alloc] initWithFGIntBase: 0];
        noLuck = ([FGInt compareAbsoluteValueOf: zero with: sFGInt] == equal);
        if (noLuck) {
            [rFGInt release];
            [sFGInt release];
        }
        [zero release];
    } while (noLuck);

    NSMutableData *signatureData = [[NSMutableData alloc] init];
    NSData *mpiData = [rFGInt toMPINSData];
    [rFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    mpiData = [sFGInt toMPINSData];
    [sFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    return signatureData;
}

-(NSData *) signNSData: (NSData *) plainText {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!primeFGInt) {
        NSLog(@"No primeFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    FGIntOverflow bitLength = [primeFGInt bitSize], kLength = 0, byteLength;
    NSMutableData *kData;
    if (bitLength > 7936) kLength = (bitLength * 512) / 15424;
    if (bitLength <= 7936) kLength = (bitLength * 384) / 7936;
    if (bitLength <= 5312) kLength = (bitLength * 320) / 5312;
    if (bitLength <= 3248) kLength = (bitLength * 256) / 3248;
    if (bitLength <= 2432) kLength = (bitLength * 224) / 2432;
    if (bitLength <= 1248) kLength = (bitLength * 160) / 1248;
    if (bitLength <= 816) kLength = (bitLength * 128) / 816;
    if (bitLength <= 640) kLength = (bitLength * 112) / 640;
    if (bitLength <= 480) kLength = (bitLength * 96) / 480;
    byteLength = (kLength / 8) + (((kLength % 8) == 0) ? 0 : 1);
    kData = [[NSMutableData alloc] initWithLength: byteLength];
    int result = SecRandomCopyBytes(kSecRandomDefault, byteLength, kData.mutableBytes);

    NSData *signatureData = [self signNSData: plainText withRandomNSData: kData];
    [kData release];

    return signatureData;
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!primeFGInt) {
        NSLog(@"No primeFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!yFGInt) {
        NSLog(@"No yFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    NSData *tmpData;
    unsigned char aBuffer[[signature length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([signature length] < rangeStart + 2) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *rFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;
    
//    NSLog(@"kitty here");
    if ([FGInt compareAbsoluteValueOf: rFGInt with: primeFGInt] != smaller) {
        [rFGInt release];
        return NO;
    }

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([signature length] < rangeStart + 2) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *sFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];

    BOOL signatureCheck = YES;
    [primeFGInt decrement];
    if ([FGInt compareAbsoluteValueOf: sFGInt with: primeFGInt] != smaller) {
        [rFGInt release];
        [sFGInt release];
        signatureCheck = NO;
    }
    [primeFGInt increment];
    if (!signatureCheck) {
        return signatureCheck;
    }

    FGInt *plainTextFGInt = [[FGInt alloc] initWithNSData: plainText], 
        *gPlainTextFGInt = [FGInt raise: gFGInt toThePower: plainTextFGInt montgomeryMod: primeFGInt],
        *yRFGInt = [FGInt raise: yFGInt toThePower: rFGInt montgomeryMod: primeFGInt],
        *rSFGInt = [FGInt raise: rFGInt toThePower: sFGInt montgomeryMod: primeFGInt], 
        *tmpFGInt = [FGInt multiply: yRFGInt and: rSFGInt], 
        *yRSFGInt = [FGInt mod: tmpFGInt by: primeFGInt];

    signatureCheck = ([FGInt compareAbsoluteValueOf: gPlainTextFGInt with: yRSFGInt] == equal);

    [rFGInt release];
    [sFGInt release];
    [plainTextFGInt release];
    [gPlainTextFGInt release];
    [yRFGInt release];
    [rSFGInt release];
    [tmpFGInt release];
    [yRSFGInt release];

    return signatureCheck;
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    @autoreleasepool{
        return [self verifySignature: signature ofPlainTextNSData: [plainText dataUsingEncoding:NSUTF8StringEncoding]];;
    }
}


@end




















@implementation FGIntDSA
@synthesize pFGInt;
@synthesize qFGInt;
@synthesize secretKey;
@synthesize gFGInt;
@synthesize yFGInt;


-(id) init {
    if (self = [super init]) {
        pFGInt = nil;
        qFGInt = nil;
        gFGInt = nil;
        secretKey = nil;
        yFGInt = nil;
    }
    return self;
}


-(void) setGFGIntAndComputeY: (FGInt *) newG {
    if (secretKey) {
        if (pFGInt) {
            if (gFGInt) {
                [gFGInt release];
            }
            gFGInt = newG;
            if (yFGInt) {
                [yFGInt release];
            }
            yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: pFGInt];
        } else {
            NSLog(@"pFGInt is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"secretKey is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}

-(void) setSecretKeyAndComputeY: (FGInt *) newSecretKey {
    if (gFGInt) {
        if (pFGInt) {
            if (secretKey) {
                [secretKey release];
            }
            secretKey = newSecretKey;
            if (yFGInt) {
                [yFGInt release];
            }
            yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: pFGInt];
        } else {
            NSLog(@"pFGInt is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"gFGInt is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}


-(id) copyWithZone: (NSZone *) zone {
    FGIntDSA *newKeys = [[FGIntDSA allocWithZone: zone] init];
    if (pFGInt) {
        [newKeys setPFGInt: [pFGInt mutableCopy]];
    }
    if (qFGInt) {
        [newKeys setQFGInt: [qFGInt mutableCopy]];
    }
    if (gFGInt) {
        [newKeys setGFGInt: [gFGInt mutableCopy]];
    }
    if (secretKey) {
        [newKeys setSecretKey: [secretKey mutableCopy]];
    }
    if (yFGInt) {
        [newKeys setYFGInt: [yFGInt mutableCopy]];
    }
    return newKeys;
}


-(id) initWithBitLength: (FGIntOverflow) bitLength {
    if (self = [super init]) {
        FGIntOverflow qBitLength = 0, secretKeyLength;
        FGInt *tmpFGInt;


        if (bitLength > 7936) qBitLength = (bitLength * 512) / 15424;
        if (bitLength <= 7936) qBitLength = (bitLength * 384) / 7936;
        if (bitLength <= 5312) qBitLength = (bitLength * 320) / 5312;
        if (bitLength <= 3248) qBitLength = (bitLength * 256) / 3248;
        if (bitLength <= 2432) qBitLength = (bitLength * 224) / 2432;
        if (bitLength <= 1248) qBitLength = (bitLength * 160) / 1248;
        if (bitLength <= 816) qBitLength = (bitLength * 128) / 816;
        if (bitLength <= 640) qBitLength = (bitLength * 112) / 640;
        if (bitLength <= 480) qBitLength = (bitLength * 96) / 480;
        qFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: qBitLength];
        [qFGInt findLargerPrime];

        pFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        [pFGInt findLargerDSAPrimeWith: qFGInt];

        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        secretKeyLength = qBitLength;
        do {
            tmpFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: secretKeyLength];
            secretKey = [FGInt mod: tmpFGInt by: qFGInt];
            [tmpFGInt release];
        } while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal));
        [zero release]; 

        FGInt *hFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        hFGInt = [FGInt longDivisionModBis: hFGInt by: pFGInt];

        FGInt *phi;
        tmpFGInt = [pFGInt mutableCopy];
        [tmpFGInt decrement];
        NSDictionary *tmpDiv = [FGInt divide: tmpFGInt by: qFGInt];
        [tmpFGInt release];
        phi = [[tmpDiv objectForKey: quotientKey] retain];
        [tmpDiv release];
        gFGInt = [FGInt raise: hFGInt toThePower: phi montgomeryMod: pFGInt];
        while ([FGInt compareAbsoluteValueOf: gFGInt with: one] == equal) {
            [hFGInt increment];
            [gFGInt release];
            gFGInt = [FGInt raise: hFGInt toThePower: phi montgomeryMod: pFGInt];
        } 
        [hFGInt release];
        [one release];
        [phi release];
        
        yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: pFGInt];
    }
    return self;
}


-(id) initWithNSData: (NSData *) secretKeyData {
    if (!secretKeyData) {
        NSLog(@"No secretKeyData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if ([secretKeyData length] == 0) {
        NSLog(@"secretKeyData is empty for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (self = [super init]) {
        FGIntOverflow bitLength = 0, secretKeyLength = [secretKeyData length]*8, qBitLength = secretKeyLength;
        FGInt *tmpFGInt;

        if (qBitLength > 384) bitLength = (qBitLength * 15424) / 512;
        if (qBitLength <= 384) bitLength = (qBitLength * 7936) / 384;
        if (qBitLength <= 320) bitLength = (qBitLength * 5312) / 320;
        if (qBitLength <= 256) bitLength = (qBitLength * 3248) / 256;
        if (qBitLength <= 224) bitLength = (qBitLength * 2432) / 224;
        if (qBitLength <= 160) bitLength = (qBitLength * 1248) / 160;
        if (qBitLength <= 128) bitLength = (qBitLength * 816) / 128;
        if (qBitLength <= 112) bitLength = (qBitLength * 640) / 112;
        if (qBitLength <= 96) bitLength = (qBitLength * 480) / 96;
        qFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: qBitLength];
        [qFGInt findLargerPrime];

        pFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        [pFGInt findLargerDSAPrimeWith: qFGInt];
    
        tmpFGInt = [[FGInt alloc] initWithNSData: secretKeyData];
        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        secretKey = [FGInt mod: tmpFGInt by: qFGInt];
        while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal)) {
            [tmpFGInt increment];
            [secretKey release];
            secretKey = [FGInt mod: tmpFGInt by: qFGInt];
        } 
        [tmpFGInt release];
        [zero release]; 

        FGInt *hFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        hFGInt = [FGInt longDivisionModBis: hFGInt by: pFGInt];

        FGInt *phi;
        tmpFGInt = [pFGInt mutableCopy];
        [tmpFGInt decrement];
        NSDictionary *tmpDiv = [FGInt divide: tmpFGInt by: qFGInt];
        [tmpFGInt release];
        phi = [[tmpDiv objectForKey: quotientKey] retain];
        [tmpDiv release];
        gFGInt = [FGInt raise: hFGInt toThePower: phi montgomeryMod: pFGInt];
        while ([FGInt compareAbsoluteValueOf: gFGInt with: one] == equal) {
            [hFGInt increment];
            [gFGInt release];
            gFGInt = [FGInt raise: hFGInt toThePower: phi montgomeryMod: pFGInt];
        } 
        [hFGInt release];
        [one release];
        [phi release];
        
        yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: pFGInt];
    }
    return self;
}

-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData {
    NSData *tmpData;
    unsigned char aBuffer[[publicKeyNSData length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    pFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    qFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    gFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    yFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
}


-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString {
    NSData *publicKeyNSData = [FGInt convertBase64ToNSData: publicKeyBase64NSString];
    [self setPublicKeyWithNSData: publicKeyNSData];
    [publicKeyNSData release];    
}


-(NSData *) publicKeyToNSData {
    if (!pFGInt) {
        NSLog(@"No pFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!qFGInt) {
        NSLog(@"No qFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yFGInt) {
        NSLog(@"No yFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSMutableData *publicKeyData = [[NSMutableData alloc] init];
    NSData *tmpData;
    
    tmpData = [pFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [qFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [gFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];
        
    tmpData = [yFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];
        
    return publicKeyData;
}


-(NSString *) publicKeyToBase64NSString {
    NSData *publicKeyData = [self publicKeyToNSData];
    NSString *publicKeyBase64NSString = [FGInt convertNSDataToBase64: publicKeyData];
    [publicKeyData release];
    return publicKeyBase64NSString;    
}


-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData {
    if ([secretKeyNSData length] < 2) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    secretKey = [[FGInt alloc] initWithMPINSData: secretKeyNSData];
}


-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString {
    NSData *secretKeyNSData = [FGInt convertBase64ToNSData: secretKeyBase64NSString];
    [self setSecretKeyWithNSData: secretKeyNSData];
    [secretKeyNSData release];
}


-(NSData *) secretKeyToNSData {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [secretKey toMPINSData];
    return secretKeyData;
}


-(NSString *) secretKeyToBase64NSString {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [self secretKeyToNSData];
    NSString *secretKeyBase64NSString = [FGInt convertNSDataToBase64: secretKeyData];
    [secretKeyData release];
    return secretKeyBase64NSString;    
}


-(void) dealloc {
    if (pFGInt != nil) {
        [pFGInt release];
    }
    if (qFGInt != nil) {
        [qFGInt release];
    }
    if (secretKey != nil) {
        [secretKey release];
    }
    if (gFGInt != nil) {
        [gFGInt release];
    }
    if (yFGInt != nil) {
        [yFGInt release];
    }
    [super dealloc];
}



-(NSData *) signNSString: (NSString *) plainText {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData];
        return signedData;
    }
}


-(NSData *) signNSString: (NSString *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData withRandomNSData: kData];
        return signedData;
    }
}


-(NSData *) signNSData: (NSData *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!pFGInt) {
        NSLog(@"No pFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!kData) {
        NSLog(@"No kData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    FGIntOverflow byteLength = [qFGInt byteSize];
    FGIntBase firstBit, j;
    if ([plainText length] < byteLength) {
        NSLog(@"plainText is too small for %s at line %d, make sure it contains more than %llu bytes", __PRETTY_FUNCTION__, __LINE__, byteLength);
        return nil;
    }

    FGInt *kFGInt;
    FGIntOverflow length;
    FGIntBase* numberArray;
    kFGInt = [[FGInt alloc] initWithNSData: kData];
    firstBit = (1u << 31);
    numberArray = [[kFGInt number] mutableBytes];
    length = [[kFGInt number] length]/4;
    j = numberArray[length - 1];
    j = j | firstBit;
    numberArray[length - 1] = j;

    FGInt *rFGInt = nil, *sFGInt;
    BOOL noLuck;
    do {
        FGInt *hFGInt, *tmpFGInt, *kInvertedFGInt, *zero = [[FGInt alloc] initWithFGIntBase: 0];
        noLuck = YES;
        while (noLuck) {
            tmpFGInt = [FGInt raise: gFGInt toThePower: kFGInt montgomeryMod: pFGInt];
            rFGInt = [FGInt mod: tmpFGInt by: qFGInt];
            [tmpFGInt release];
            noLuck = ([FGInt compareAbsoluteValueOf: zero with: rFGInt] == equal);
            if (noLuck) {
                [rFGInt release];
                [kFGInt increment];
            }
        }
            
        FGInt *dataFGInt = [[FGInt alloc] initWithNSData: plainText];
        kInvertedFGInt = [FGInt invert: kFGInt moduloPrime: qFGInt];
        [kFGInt release];
        tmpFGInt = [FGInt multiply: rFGInt and: secretKey];
        hFGInt = [FGInt add: dataFGInt and: tmpFGInt];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: hFGInt and: kInvertedFGInt];
        [kInvertedFGInt release];
        [hFGInt release];
        sFGInt = [FGInt mod: tmpFGInt by: qFGInt];
        [tmpFGInt release];
        [dataFGInt release];
        
        noLuck = ([FGInt compareAbsoluteValueOf: zero with: sFGInt] == equal);
        if (noLuck) {
            [rFGInt release];
            [sFGInt release];
            [kFGInt increment];
        }
        [zero release];
    } while (noLuck);

    NSMutableData *signatureData = [[NSMutableData alloc] init];
    NSData *mpiData = [rFGInt toMPINSData];
    [rFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    mpiData = [sFGInt toMPINSData];
    [sFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    return signatureData;
}

-(NSData *) signNSData: (NSData *) plainText {
    FGIntOverflow byteLength = [[secretKey number] length];
    NSMutableData *kData;
    kData = [[NSMutableData alloc] initWithLength: byteLength];
    int result = SecRandomCopyBytes(kSecRandomDefault, byteLength, kData.mutableBytes);

    NSData *signatureData = [self signNSData: plainText withRandomNSData: kData];
    [kData release];

    return signatureData;
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!pFGInt) {
        NSLog(@"No pFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!qFGInt) {
        NSLog(@"No qFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!yFGInt) {
        NSLog(@"No yFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    NSData *tmpData;
    unsigned char aBuffer[[signature length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([signature length] < rangeStart + 2) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *rFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;
    
    if ([FGInt compareAbsoluteValueOf: rFGInt with: pFGInt] != smaller) {
        [rFGInt release];
        return NO;
    }

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([signature length] < rangeStart + 2) {
        [rFGInt release];
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        [rFGInt release];
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *sFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];

    BOOL signatureCheck = YES;
    if ([FGInt compareAbsoluteValueOf: sFGInt with: qFGInt] != smaller) {
        [rFGInt release];
        [sFGInt release];
        signatureCheck = NO;
    }
    if (!signatureCheck)
        return signatureCheck;

    signatureCheck = YES;
    if ([FGInt compareAbsoluteValueOf: rFGInt with: qFGInt] != smaller) {
        [rFGInt release];
        [sFGInt release];
        signatureCheck = NO;
    }
    if (!signatureCheck)
        return signatureCheck;

    FGInt *plainTextFGInt = [[FGInt alloc] initWithNSData: plainText], 
        *wFGInt = [FGInt invert: sFGInt moduloPrime: qFGInt];
    [sFGInt release];
    FGInt *tmpFGInt = [FGInt multiply: wFGInt and: plainTextFGInt];
    FGInt *u1FGInt = [FGInt mod: tmpFGInt by: qFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: wFGInt and: rFGInt];
    [wFGInt release];
    FGInt *u2FGInt = [FGInt mod: tmpFGInt by: qFGInt];
    [tmpFGInt release];
    FGInt *tmpFGInt1 = [FGInt raise: gFGInt toThePower: u1FGInt montgomeryMod: pFGInt],
        *tmpFGInt2 = [FGInt raise: yFGInt toThePower: u2FGInt montgomeryMod: pFGInt];
    [u1FGInt release];
    [u2FGInt release];
    tmpFGInt = [FGInt multiply: tmpFGInt1 and: tmpFGInt2];
    [tmpFGInt1 release];
    [tmpFGInt2 release];
    tmpFGInt1 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    FGInt *vFGInt = [FGInt mod: tmpFGInt1 by: qFGInt];
    [tmpFGInt1 release];

    signatureCheck = ([FGInt compareAbsoluteValueOf: rFGInt with: vFGInt] == equal);

    [rFGInt release];
    [vFGInt release];

    return signatureCheck;
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    @autoreleasepool{
        return [self verifySignature: signature ofPlainTextNSData: [plainText dataUsingEncoding:NSUTF8StringEncoding]];;
    }
}


@end


























@implementation FGIntGOSTDSA
@synthesize pFGInt;
@synthesize qFGInt;
@synthesize secretKey;
@synthesize gFGInt;
@synthesize yFGInt;


-(id) init {
    if (self = [super init]) {
        pFGInt = nil;
        qFGInt = nil;
        gFGInt = nil;
        secretKey = nil;
        yFGInt = nil;
    }
    return self;
}


-(void) setGFGIntAndComputeY: (FGInt *) newG {
    if (secretKey) {
        if (pFGInt) {
            if (gFGInt) {
                [gFGInt release];
            }
            gFGInt = newG;
            if (yFGInt) {
                [yFGInt release];
            }
            yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: pFGInt];
        } else {
            NSLog(@"pFGInt is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"secretKey is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}

-(void) setSecretKeyAndComputeY: (FGInt *) newSecretKey {
    if (gFGInt) {
        if (pFGInt) {
            if (secretKey) {
                [secretKey release];
            }
            secretKey = newSecretKey;
            if (yFGInt) {
                [yFGInt release];
            }
            yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: pFGInt];
        } else {
            NSLog(@"pFGInt is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"gFGInt is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}


-(id) copyWithZone: (NSZone *) zone {
    FGIntDSA *newKeys = [[FGIntDSA allocWithZone: zone] init];
    if (pFGInt) {
        [newKeys setPFGInt: [pFGInt mutableCopy]];
    }
    if (qFGInt) {
        [newKeys setQFGInt: [qFGInt mutableCopy]];
    }
    if (gFGInt) {
        [newKeys setGFGInt: [gFGInt mutableCopy]];
    }
    if (secretKey) {
        [newKeys setSecretKey: [secretKey mutableCopy]];
    }
    if (yFGInt) {
        [newKeys setYFGInt: [yFGInt mutableCopy]];
    }
    return newKeys;
}


-(id) initWithBitLength: (FGIntOverflow) bitLength {
    if (self = [super init]) {
        FGIntOverflow byteLength, qBitLength = 0, secretKeyLength;
        FGInt *tmpFGInt;

        if (bitLength > 7936) qBitLength = (bitLength * 512) / 15424;
        if (bitLength <= 7936) qBitLength = (bitLength * 384) / 7936;
        if (bitLength <= 5312) qBitLength = (bitLength * 320) / 5312;
        if (bitLength <= 3248) qBitLength = (bitLength * 256) / 3248;
        if (bitLength <= 2432) qBitLength = (bitLength * 224) / 2432;
        if (bitLength <= 1248) qBitLength = (bitLength * 160) / 1248;
        if (bitLength <= 816) qBitLength = (bitLength * 128) / 816;
        if (bitLength <= 640) qBitLength = (bitLength * 112) / 640;
        if (bitLength <= 480) qBitLength = (bitLength * 96) / 480;
        qFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: qBitLength];
        [qFGInt findLargerPrime];

        pFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        [pFGInt findLargerDSAPrimeWith: qFGInt];

        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        secretKeyLength = qBitLength;
        byteLength = (secretKeyLength / 8) + (((secretKeyLength % 8) == 0) ? 0 : 1);
        do {
            tmpFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: secretKeyLength];
            secretKey = [FGInt mod: tmpFGInt by: qFGInt];
            [tmpFGInt release];
        } while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal));
        [zero release]; 

        FGInt *hFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        hFGInt = [FGInt longDivisionModBis: hFGInt by: pFGInt];

        FGInt *phi;
        tmpFGInt = [pFGInt mutableCopy];
        [tmpFGInt decrement];
        NSDictionary *tmpDiv = [FGInt divide: tmpFGInt by: qFGInt];
        [tmpFGInt release];
        phi = [[tmpDiv objectForKey: quotientKey] retain];
        [tmpDiv release];
        gFGInt = [FGInt raise: hFGInt toThePower: phi montgomeryMod: pFGInt];
        while ([FGInt compareAbsoluteValueOf: gFGInt with: one] == equal) {
            [hFGInt increment];
            [gFGInt release];
            gFGInt = [FGInt raise: hFGInt toThePower: phi montgomeryMod: pFGInt];
        } 
        [hFGInt release];
        [one release];
        [phi release];
        
        yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: pFGInt];
    }
    return self;
}


-(id) initWithNSData: (NSData *) secretKeyData {
    if (!secretKeyData) {
        NSLog(@"No secretKeyData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if ([secretKeyData length] == 0) {
        NSLog(@"secretKeyData is empty for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (self = [super init]) {
        FGIntOverflow bitLength = 0, secretKeyLength = [secretKeyData length]*8, qBitLength = secretKeyLength;
        FGInt *tmpFGInt;

        if (qBitLength > 384) bitLength = (qBitLength * 15424) / 512;
        if (qBitLength <= 384) bitLength = (qBitLength * 7936) / 384;
        if (qBitLength <= 320) bitLength = (qBitLength * 5312) / 320;
        if (qBitLength <= 256) bitLength = (qBitLength * 3248) / 256;
        if (qBitLength <= 224) bitLength = (qBitLength * 2432) / 224;
        if (qBitLength <= 160) bitLength = (qBitLength * 1248) / 160;
        if (qBitLength <= 128) bitLength = (qBitLength * 816) / 128;
        if (qBitLength <= 112) bitLength = (qBitLength * 640) / 112;
        if (qBitLength <= 96) bitLength = (qBitLength * 480) / 96;
        qFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: qBitLength];
        [qFGInt findLargerPrime];

        pFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        [pFGInt findLargerDSAPrimeWith: qFGInt];
    
        tmpFGInt = [[FGInt alloc] initWithNSData: secretKeyData];
        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        secretKey = [FGInt mod: tmpFGInt by: qFGInt];
        while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal)) {
            [tmpFGInt increment];
            [secretKey release];
            secretKey = [FGInt mod: tmpFGInt by: qFGInt];
        } 
        [tmpFGInt release];
        [zero release]; 

        FGInt *hFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: bitLength];
        hFGInt = [FGInt longDivisionModBis: hFGInt by: pFGInt];

        FGInt *phi;
        tmpFGInt = [pFGInt mutableCopy];
        [tmpFGInt decrement];
        NSDictionary *tmpDiv = [FGInt divide: tmpFGInt by: qFGInt];
        [tmpFGInt release];
        phi = [[tmpDiv objectForKey: quotientKey] retain];
        [tmpDiv release];
        gFGInt = [FGInt raise: hFGInt toThePower: phi montgomeryMod: pFGInt];
        while ([FGInt compareAbsoluteValueOf: gFGInt with: one] == equal) {
            [hFGInt increment];
            [gFGInt release];
            gFGInt = [FGInt raise: hFGInt toThePower: phi montgomeryMod: pFGInt];
        } 
        [hFGInt release];
        [one release];
        [phi release];
        
        yFGInt = [FGInt raise: gFGInt toThePower: secretKey montgomeryMod: pFGInt];
    }
    return self;
}

-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData {
    NSData *tmpData;
    unsigned char aBuffer[[publicKeyNSData length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    pFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    qFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    gFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    yFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
}


-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString {
    NSData *publicKeyNSData = [FGInt convertBase64ToNSData: publicKeyBase64NSString];
    [self setPublicKeyWithNSData: publicKeyNSData];
    [publicKeyNSData release];    
}


-(NSData *) publicKeyToNSData {
    if (!pFGInt) {
        NSLog(@"No pFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!qFGInt) {
        NSLog(@"No qFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yFGInt) {
        NSLog(@"No yFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSMutableData *publicKeyData = [[NSMutableData alloc] init];
    NSData *tmpData;
    
    tmpData = [pFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [qFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [gFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];
        
    tmpData = [yFGInt toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];
        
    return publicKeyData;
}


-(NSString *) publicKeyToBase64NSString {
    NSData *publicKeyData = [self publicKeyToNSData];
    NSString *publicKeyBase64NSString = [FGInt convertNSDataToBase64: publicKeyData];
    [publicKeyData release];
    return publicKeyBase64NSString;    
}


-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData {
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    unsigned char aBuffer[[secretKeyNSData length]];

    if ([secretKeyNSData length] < rangeStart + 2) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8)); 
    keyLength = (mpiLength + 7)/8 + 2;
    if ([secretKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    secretKey = [[FGInt alloc] initWithMPINSData: secretKeyNSData];
}


-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString {
    NSData *secretKeyNSData = [FGInt convertBase64ToNSData: secretKeyBase64NSString];
    [self setSecretKeyWithNSData: secretKeyNSData];
    [secretKeyNSData release];
}


-(NSData *) secretKeyToNSData {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [secretKey toMPINSData];
    return secretKeyData;
}


-(NSString *) secretKeyToBase64NSString {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [self secretKeyToNSData];
    NSString *secretKeyBase64NSString = [FGInt convertNSDataToBase64: secretKeyData];
    [secretKeyData release];
    return secretKeyBase64NSString;    
}


-(void) dealloc {
    if (pFGInt != nil)  {
        [pFGInt release];
    }
    if (qFGInt != nil) {
        [qFGInt release];
    }
    if (secretKey != nil) {
        [secretKey release];
    }
    if (gFGInt != nil) {
        [gFGInt release];
    }
    if (yFGInt != nil) {
        [yFGInt release];
    }
    [super dealloc];
}



-(NSData *) signNSString: (NSString *) plainText {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData];
        return signedData;
    }
}


-(NSData *) signNSString: (NSString *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData withRandomNSData: kData];
        return signedData;
    }
}


-(NSData *) signNSData: (NSData *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!pFGInt) {
        NSLog(@"No pFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!kData) {
        NSLog(@"No kData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    FGIntOverflow byteLength = [qFGInt byteSize];
    FGIntBase firstBit, j;
    if ([plainText length] < byteLength) {
        NSLog(@"plainText is too small for %s at line %d, make sure it contains more than %llu bytes", __PRETTY_FUNCTION__, __LINE__, byteLength);
        return nil;
    }

    FGIntOverflow length;
    FGIntBase* numberArray;
    FGInt *kFGInt;
    kFGInt = [[FGInt alloc] initWithNSData: kData];
    firstBit = (1u << 31);
    numberArray = [[kFGInt number] mutableBytes];
    length = [[kFGInt number] length]/4;
    j = numberArray[length - 1];
    j = j | firstBit;
    numberArray[length - 1] = j;

    FGInt *rFGInt = nil, *sFGInt;
    BOOL noLuck;
    do {
        FGInt *hFGInt, *tmpFGInt, *zero = [[FGInt alloc] initWithFGIntBase: 0];
        noLuck = YES;
        while (noLuck) {
            tmpFGInt = [FGInt raise: gFGInt toThePower: kFGInt montgomeryMod: pFGInt];
            rFGInt = [FGInt mod: tmpFGInt by: qFGInt];
            [tmpFGInt release];
            noLuck = ([FGInt compareAbsoluteValueOf: zero with: rFGInt] == equal);
            if (noLuck) {
                [rFGInt release];
                [kFGInt increment];
            }
        }
            
        FGInt *dataFGInt = [[FGInt alloc] initWithNSData: plainText];
        tmpFGInt = [FGInt mod: dataFGInt by: qFGInt];
        if ([FGInt compareAbsoluteValueOf: zero with: tmpFGInt] == equal) {
            [dataFGInt release];
            dataFGInt = [[FGInt alloc] initWithFGIntBase: 1];
        }
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: rFGInt and: secretKey];
        hFGInt = [FGInt multiply: kFGInt and: dataFGInt];
        [kFGInt release];
        [tmpFGInt addWith: hFGInt];
        [hFGInt release];
        sFGInt = [FGInt mod: tmpFGInt by: qFGInt];
        [tmpFGInt release];

        noLuck = ([FGInt compareAbsoluteValueOf: zero with: sFGInt] == equal);
        if (noLuck) {
            [rFGInt release];
            [sFGInt release];
            [kFGInt increment];
        }
        [zero release];
    } while (noLuck);

    NSMutableData *signatureData = [[NSMutableData alloc] init];
    NSData *mpiData = [rFGInt toMPINSData];
    [rFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    mpiData = [sFGInt toMPINSData];
    [sFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    return signatureData;
}

-(NSData *) signNSData: (NSData *) plainText {
    FGIntOverflow byteLength = [[secretKey number] length];
    NSMutableData *kData;
    kData = [[NSMutableData alloc] initWithLength: byteLength];
    int result = SecRandomCopyBytes(kSecRandomDefault, byteLength, kData.mutableBytes);

    NSData *signatureData = [self signNSData: plainText withRandomNSData: kData];
    [kData release];

    return signatureData;
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!pFGInt) {
        NSLog(@"No pFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!qFGInt) {
        NSLog(@"No qFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!gFGInt) {
        NSLog(@"No gFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!yFGInt) {
        NSLog(@"No yFGInt available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    NSData *tmpData;
    unsigned char aBuffer[[signature length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([signature length] < rangeStart + 2) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *rFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;
    
    if ([FGInt compareAbsoluteValueOf: rFGInt with: pFGInt] != smaller) {
        [rFGInt release];
        return NO;
    }

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([signature length] < rangeStart + 2) {
        [rFGInt release];
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        [rFGInt release];
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *sFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];

    BOOL signatureCheck = YES;
    if ([FGInt compareAbsoluteValueOf: sFGInt with: qFGInt] != smaller) {
        [rFGInt release];
        [sFGInt release];
        signatureCheck = NO;
    }
    if (!signatureCheck)
        return signatureCheck;

    signatureCheck = YES;
    if ([FGInt compareAbsoluteValueOf: rFGInt with: qFGInt] != smaller) {
        [rFGInt release];
        [sFGInt release];
        signatureCheck = NO;
    }
    if (!signatureCheck)
        return signatureCheck;

//    NSLog(@"kitty here");
    FGInt *plainTextFGInt = [[FGInt alloc] initWithNSData: plainText], *zero = [[FGInt alloc] initWithFGIntBase: 0], *tmpFGInt, *vFGInt;
    tmpFGInt = [FGInt mod: plainTextFGInt by: qFGInt];
    if ([FGInt compareAbsoluteValueOf: zero with: tmpFGInt] == equal) {
        [plainTextFGInt release];
        plainTextFGInt = [[FGInt alloc] initWithFGIntBase: 1];
        vFGInt = [plainTextFGInt mutableCopy];
    } else {
        vFGInt = [FGInt invert: plainTextFGInt moduloPrime: qFGInt];
    }
    [zero release];
    tmpFGInt = [FGInt multiply: vFGInt and: sFGInt];
    FGInt *u1FGInt = [FGInt mod: tmpFGInt by: qFGInt];
    [tmpFGInt release];
    FGInt *tmpFGInt1 = [qFGInt mutableCopy];
    [tmpFGInt1 subtractWith: rFGInt];
    tmpFGInt = [FGInt multiply: tmpFGInt1 and: vFGInt];
    [tmpFGInt1 release];
    FGInt *u2FGInt = [FGInt mod: tmpFGInt by: qFGInt];
    [tmpFGInt release];
    tmpFGInt1 = [FGInt raise: gFGInt toThePower: u1FGInt montgomeryMod: pFGInt];
    FGInt *tmpFGInt2 = [FGInt raise: yFGInt toThePower: u2FGInt montgomeryMod: pFGInt];
    [u1FGInt release];
    [u2FGInt release];
    tmpFGInt = [FGInt multiply: tmpFGInt1 and: tmpFGInt2];
    [tmpFGInt1 release];
    [tmpFGInt2 release];
    tmpFGInt1 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    FGInt *uFGInt = [FGInt mod: tmpFGInt1 by: qFGInt];
    [tmpFGInt1 release];

    signatureCheck = ([FGInt compareAbsoluteValueOf: rFGInt with: uFGInt] == equal);

    [rFGInt release];
    [uFGInt release];

    return signatureCheck;
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    @autoreleasepool{
        return [self verifySignature: signature ofPlainTextNSData: [plainText dataUsingEncoding:NSUTF8StringEncoding]];;
    }
}


@end

















@implementation ECDSA
@synthesize gPoint;
@synthesize secretKey;
@synthesize yPoint;


-(id) init {
    if (self = [super init]) {
        gPoint = nil;
        secretKey = nil;
        yPoint = nil;
    }
    return self;
}



-(void) dealloc {
    if (gPoint != nil) {
        [gPoint release];
    }
    if (yPoint != nil) {
        [yPoint release];
    }
    if (secretKey != nil) {
        [secretKey release];
    }
    [super dealloc];
}


-(id) copyWithZone: (NSZone *) zone {
    ECDSA *newKeys = [[ECDSA allocWithZone: zone] init];
    if (gPoint) {
        [newKeys setGPoint: [gPoint mutableCopy]];
    }
    if (secretKey) {
        [newKeys setSecretKey: [secretKey mutableCopy]];
    }
    if (yPoint) {
        [newKeys setYPoint: [yPoint mutableCopy]];
    }
    return newKeys;
}


-(void) setGPointAndComputeYPoint: (ECPoint *) newG {
    if (secretKey) {
        if ([newG ellipticCurve]) {
            if ([[newG ellipticCurve] p]) {
                if (gPoint) {
                    [gPoint release];
                }
                gPoint = newG;
                if (yPoint) {
                    [yPoint release];
                }
                yPoint = [ECPoint add: gPoint kTimes: secretKey];
            } else {
                NSLog(@"No ellipticCurve prime for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
            }
        } else {
            NSLog(@"No ellipticCurve parameters for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"secretKey is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}

-(void) setSecretKeyAndComputeYPoint: (FGInt *) newSecretKey {
    if (gPoint) {
        if ([gPoint ellipticCurve]) {
            if ([[gPoint ellipticCurve] p]) {
                if (secretKey) {
                    [secretKey release];
                }
                secretKey = newSecretKey;
                if (yPoint) {
                    [yPoint release];
                }
                yPoint = [ECPoint add: gPoint kTimes: secretKey];
            } else {
                NSLog(@"No ellipticCurve prime for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
            }
        } else {
            NSLog(@"No ellipticCurve parameters for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"gPoint is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}


-(id) initWithBitLength: (FGIntOverflow) bitLength {
    if (self = [super init]) {
        FGIntOverflow secretKeyLength;
        FGInt *tmpFGInt;

        gPoint = [ECPoint generateSecureCurveAndPointOfSize: bitLength];
        FGInt *nFGInt = [gPoint pointOrder], *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        
        secretKeyLength = bitLength;
        do {
            tmpFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: secretKeyLength];
            secretKey = [FGInt mod: tmpFGInt by: nFGInt];
            [tmpFGInt release];
        } while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal));
        [zero release]; 
        [one release];
        
        yPoint = [ECPoint add: gPoint kTimes: secretKey];

        // FGIntOverflow precision = [[[gPoint ellipticCurve] p] bitSize];
        // [[gPoint ellipticCurve] setInvertedPrecision: precision];
        // [[gPoint ellipticCurve] setInvertedDivisorP: [FGInt newtonInversion: [[gPoint ellipticCurve] p] withPrecision: precision]];
    }
    return self;
}


-(id) initWithNSData: (NSData *) secretKeyData {
    if (!secretKeyData) {
        NSLog(@"No secretKeyData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if ([secretKeyData length] == 0) {
        NSLog(@"secretKeyData is empty for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (self = [super init]) {
        FGInt *tmpFGInt;
        FGIntOverflow bitLength = [secretKeyData length] * 8;

        gPoint = [ECPoint generateSecureCurveAndPointOfSize: bitLength];
        FGInt *nFGInt = [gPoint pointOrder], *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        
        tmpFGInt = [[FGInt alloc] initWithNSData: secretKeyData];
        secretKey = [FGInt mod: tmpFGInt by: nFGInt];
        while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal)) {
            [tmpFGInt increment];
            [secretKey release];
            secretKey = [FGInt mod: tmpFGInt by: nFGInt];
        } 
        [tmpFGInt release];
        [zero release]; 
        [one release];
        
        yPoint = [ECPoint add: gPoint kTimes: secretKey];
    }
    return self;
}



-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData {
    NSData *tmpData;
    unsigned char aBuffer[[publicKeyNSData length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *pFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *aFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *bFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    EllipticCurve *ec = [[EllipticCurve alloc] init];
    [ec setP: pFGInt];
    [ec setA: aFGInt];
    [ec setB: bFGInt];
    FGIntOverflow byteLength = [pFGInt byteSize];


    bytesRange = NSMakeRange(rangeStart, 1);
    if ([publicKeyNSData length] < rangeStart + 1) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    if (aBuffer[0] == 0) {
        gPoint = [[ECPoint alloc] initInfinityWithEllpiticCurve: ec];
        rangeStart += 1;
    } else if (aBuffer[0] == 4) {
        bytesRange = NSMakeRange(rangeStart , 2*byteLength + 1);
        if ([publicKeyNSData length] < rangeStart + 2*byteLength + 1) {
            NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return;
        }
        [publicKeyNSData getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: 2*byteLength + 1];
        gPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (2*byteLength + 1);
    } else if ((aBuffer[0] != 2) && (aBuffer[0] != 3)) {
        NSLog(@"publicKeyNSData is corrupt, no valid gPoint data, tag is %u, for %s at line %d", aBuffer[0], __PRETTY_FUNCTION__, __LINE__);
        return;
    } else {
        bytesRange = NSMakeRange(rangeStart , byteLength + 1);
        if ([publicKeyNSData length] < rangeStart + byteLength + 1) {
            NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return;
        }
        [publicKeyNSData getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: byteLength + 1];
        gPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (byteLength + 1);
    }

    bytesRange = NSMakeRange(rangeStart, 1);
    if ([publicKeyNSData length] < rangeStart + 1) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    if (aBuffer[0] == 0) {
        yPoint = [[ECPoint alloc] initInfinityWithEllpiticCurve: ec];
        rangeStart += 1;
    } else if (aBuffer[0] == 4) {
        bytesRange = NSMakeRange(rangeStart , 2*byteLength + 1);
        if ([publicKeyNSData length] < rangeStart + 2*byteLength + 1) {
            NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return;
        }
        [publicKeyNSData getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: 2*byteLength + 1];
        yPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (2*byteLength + 1);
    } else if ((aBuffer[0] != 2) && (aBuffer[0] != 3)) {
        NSLog(@"publicKeyNSData is corrupt, no valid yPoint data, tag is %u, for %s at line %d", aBuffer[0], __PRETTY_FUNCTION__, __LINE__);
        return;
    } else {
        bytesRange = NSMakeRange(rangeStart, byteLength + 1);
        if ([publicKeyNSData length] < rangeStart + byteLength + 1) {
            NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return;
        }
        [publicKeyNSData getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: byteLength + 1];
        yPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (byteLength + 1);
    }

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *oFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    [gPoint setPointOrder: oFGInt];
    [yPoint setPointOrder: [oFGInt retain]];
    rangeStart += keyLength;
    
    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
//        NSLog(@"publicKeyNSData is corrupt: %u + %u != %lu", rangeStart, keyLength, [publicKeyNSData length]);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *tmpFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    [ec setCurveOrder: [FGInt multiply: oFGInt and: tmpFGInt]];
//    [gPoint setEllipticCurve: ec];
//    [yPoint setEllipticCurve: ec];
    [[gPoint ellipticCurve] setCurveOrder: [FGInt multiply: oFGInt and: tmpFGInt]];
    [[yPoint ellipticCurve] setCurveOrder: [[[gPoint ellipticCurve] curveOrder] retain]];
    [tmpFGInt release];
    
    if (rangeStart + keyLength != [publicKeyNSData length]) {
        NSLog(@"Public Key NSData was malformatted.");
    }
}


-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString {
    NSData *publicKeyNSData = [FGInt convertBase64ToNSData: publicKeyBase64NSString];
    [self setPublicKeyWithNSData: publicKeyNSData];
    [publicKeyNSData release];    
}


-(NSData *) publicKeyToNSData {
    if (!gPoint) {
        NSLog(@"No gPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yPoint) {
        NSLog(@"No yPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![gPoint ellipticCurve]) {
        NSLog(@"No ellipticCurve available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSMutableData *publicKeyData = [[NSMutableData alloc] init];
    NSData *tmpData;

    tmpData = [[[gPoint ellipticCurve] p] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [[[gPoint ellipticCurve] a] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [[[gPoint ellipticCurve] b] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [gPoint toCompressedNSData];
    // tmpData = [gPoint toNSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [yPoint toCompressedNSData];
    // tmpData = [yPoint toNSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [[gPoint pointOrder] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    NSDictionary *tmpDiv = [FGInt divide: [[gPoint ellipticCurve] curveOrder] by: [gPoint pointOrder]];
    tmpData = [[tmpDiv objectForKey: quotientKey] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];
    [tmpDiv release];

    return publicKeyData;
}


-(NSString *) publicKeyToBase64NSString {
    NSData *publicKeyData = [self publicKeyToNSData];
    NSString *publicKeyBase64NSString = [FGInt convertNSDataToBase64: publicKeyData];
    [publicKeyData release];
    return publicKeyBase64NSString;    
}








-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData {
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    unsigned char aBuffer[2];

    if ([secretKeyNSData length] < rangeStart + 2) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8)); 
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([secretKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    secretKey = [[FGInt alloc] initWithMPINSData: secretKeyNSData];
}


-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString {
    NSData *secretKeyNSData = [FGInt convertBase64ToNSData: secretKeyBase64NSString];
    [self setSecretKeyWithNSData: secretKeyNSData];
    [secretKeyNSData release];
}


-(NSData *) secretKeyToNSData {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [secretKey toMPINSData];
    return secretKeyData;
}


-(NSString *) secretKeyToBase64NSString {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [self secretKeyToNSData];
    NSString *secretKeyBase64NSString = [FGInt convertNSDataToBase64: secretKeyData];
    [secretKeyData release];
    return secretKeyBase64NSString;    
}


-(NSData *) signNSString: (NSString *) plainText {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData];
        return signedData;
    }
}


-(NSData *) signNSString: (NSString *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *signedData = [self signNSData: plainTextData withRandomNSData: kData];
        return signedData;
    }
}


-(NSData *) signNSData: (NSData *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gPoint) {
        NSLog(@"No gPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![gPoint ellipticCurve]) {
        NSLog(@"No ellipticCurve available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yPoint) {
        NSLog(@"No yPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!kData) {
        NSLog(@"No kData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    FGIntOverflow byteLength = [[[gPoint ellipticCurve] p] byteSize];
    FGIntBase firstBit, j;
    if ([plainText length] < byteLength) {
        NSLog(@"plainText is too small for %s at line %d, make sure it contains more than %llu bytes", __PRETTY_FUNCTION__, __LINE__, byteLength);
        return nil;
    }

    FGInt *rFGInt, *sFGInt;
    FGInt *nFGInt = [gPoint pointOrder];
    FGIntOverflow nBitLength = [nFGInt bitSize], length;
    FGInt *dataFGInt = [[FGInt alloc] initWithNSData: plainText];
    [dataFGInt shiftRightBy: [dataFGInt bitSize] - nBitLength];
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
    FGIntBase* numberArray;    

    BOOL noLuck;
    do {
        FGInt *tmpFGInt = [[FGInt alloc] initWithNSData: kData];
        firstBit = (1u << 31);
        numberArray = [[tmpFGInt number] mutableBytes];
        length = [[tmpFGInt number] length]/4;
        j = numberArray[length - 1];
        j = j | firstBit;
        numberArray[length - 1] = j;
        FGInt *kFGInt = [FGInt mod: tmpFGInt by: nFGInt];
        ECPoint *kGPoint = [ECPoint add: gPoint kTimes: kFGInt];
        rFGInt = [FGInt mod: [kGPoint x] by: nFGInt];
        while (([FGInt compareAbsoluteValueOf: zero with: kFGInt] == equal) || ([FGInt compareAbsoluteValueOf: one with: kFGInt] == equal) || ([FGInt compareAbsoluteValueOf: zero with: rFGInt] == equal)) {
            [tmpFGInt increment];
            [kFGInt release];
            kFGInt = [FGInt mod: tmpFGInt by: nFGInt];
            [kGPoint release];
            kGPoint = [ECPoint add: gPoint kTimes: kFGInt];
            [rFGInt release];
            rFGInt = [FGInt mod: [kGPoint x] by: nFGInt];
        } 
        [tmpFGInt release];
    
        FGInt *kInvertedFGInt = [FGInt modularInverse: kFGInt mod: nFGInt];
        tmpFGInt = [FGInt multiply: rFGInt and: secretKey];
        [kFGInt release];
        [dataFGInt addWith: tmpFGInt];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: kInvertedFGInt and: dataFGInt];
        [dataFGInt release];
        [kInvertedFGInt release];
        sFGInt = [FGInt mod: tmpFGInt by: nFGInt];
        [tmpFGInt release];
    
        noLuck = ([FGInt compareAbsoluteValueOf: zero with: sFGInt] == equal);
        if (noLuck) {
            [rFGInt release];
            [sFGInt release];
            [kGPoint release];
        }
    } while (noLuck);

    [zero release]; 
    [one release];

    NSMutableData *signatureData = [[NSMutableData alloc] init];
    NSData *mpiData = [rFGInt toMPINSData];
    [rFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    mpiData = [sFGInt toMPINSData];
    [sFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    return signatureData;
}


-(NSData *) signNSData: (NSData *) plainText {
    FGIntOverflow byteLength = [secretKey byteSize];
    NSMutableData *kData;
    kData = [[NSMutableData alloc] initWithLength: byteLength];
    int result = SecRandomCopyBytes(kSecRandomDefault, byteLength, kData.mutableBytes);

    NSData *signatureData = [self signNSData: plainText withRandomNSData: kData];
    [kData release];

    return signatureData;
}



-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!gPoint) {
        NSLog(@"No gPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (![gPoint ellipticCurve]) {
        NSLog(@"No ellipticCurve available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!yPoint) {
        NSLog(@"No yPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    NSData *tmpData;
    unsigned char aBuffer[[signature length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([signature length] < rangeStart + 2) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *rFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;
    
    FGInt *nFGInt = [gPoint pointOrder];
    if ([FGInt compareAbsoluteValueOf: rFGInt with: nFGInt] != smaller) {
        [rFGInt release];
        return NO;
    }

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([signature length] < rangeStart + 2) {
        [rFGInt release];
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        [rFGInt release];
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *sFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];

    FGIntOverflow nBitLength = [nFGInt bitSize];
    FGInt *plainTextFGInt = [[FGInt alloc] initWithNSData: plainText];
    [plainTextFGInt shiftRightBy: [plainTextFGInt bitSize] - nBitLength];

    BOOL signatureCheck = YES;
    if ([FGInt compareAbsoluteValueOf: sFGInt with: nFGInt] != smaller) {
        [rFGInt release];
        [sFGInt release];
        signatureCheck = NO;
    }
    if (!signatureCheck) {
        return signatureCheck;
    }

    FGInt *tmpFGInt, *wFGInt = [FGInt modularInverse: sFGInt mod: nFGInt];
    tmpFGInt = [FGInt multiply: wFGInt and: plainTextFGInt];
    FGInt *u1FGInt = [FGInt mod: tmpFGInt by: nFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: wFGInt and: rFGInt];
    FGInt *u2FGInt = [FGInt mod: tmpFGInt by: nFGInt];
    [tmpFGInt release];
    [wFGInt release];
    ECPoint *sum = [ECPoint add: gPoint k1Times: u1FGInt and: yPoint k2Times: u2FGInt];
    [u1FGInt release];
    [u2FGInt release];
    [sFGInt release];
    
    tmpFGInt = [FGInt mod: [sum x] by: nFGInt];
    signatureCheck = ([FGInt compareAbsoluteValueOf: rFGInt with: tmpFGInt] == equal);
    [tmpFGInt release];

    [rFGInt release];
    [sum release];

    return signatureCheck;
}

-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    @autoreleasepool{
        return [self verifySignature: signature ofPlainTextNSData: [plainText dataUsingEncoding:NSUTF8StringEncoding]];;
    }
}

@end




























@implementation ECElGamal
@synthesize gPoint;
@synthesize secretKey;
@synthesize yPoint;


-(id) init {
    if (self = [super init]) {
        gPoint = nil;
        secretKey = nil;
        yPoint = nil;
    }
    return self;
}



-(void) dealloc {
    if (gPoint != nil) {
        [gPoint release];
    }
    if (yPoint != nil) {
        [yPoint release];
    }
    if (secretKey != nil) {
        [secretKey release];
    }
    [super dealloc];
}


-(id) copyWithZone: (NSZone *) zone {
    ECDSA *newKeys = [[ECDSA allocWithZone: zone] init];
    if (gPoint) {
        [newKeys setGPoint: [gPoint mutableCopy]];
    }
    if (secretKey) {
        [newKeys setSecretKey: [secretKey mutableCopy]];
    }
    if (yPoint) {
        [newKeys setYPoint: [yPoint mutableCopy]];
    }
    return newKeys;
}


-(void) setGPointAndComputeYPoint: (ECPoint *) newG {
    if (secretKey) {
        if ([newG ellipticCurve]) {
            if ([[newG ellipticCurve] p]) {
                if (gPoint) {
                    [gPoint release];
                }
                gPoint = newG;
                if (yPoint) {
                    [yPoint release];
                }
                yPoint = [ECPoint add: gPoint kTimes: secretKey];
            } else {
                NSLog(@"No ellipticCurve prime for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
            }
        } else {
            NSLog(@"No ellipticCurve parameters for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"secretKey is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}

-(void) setSecretKeyAndComputeYPoint: (FGInt *) newSecretKey {
    if (gPoint) {
        if ([gPoint ellipticCurve]) {
            if ([[gPoint ellipticCurve] p]) {
                if (secretKey) {
                    [secretKey release];
                }
                secretKey = newSecretKey;
                if (yPoint) {
                    [yPoint release];
                }
                yPoint = [ECPoint add: gPoint kTimes: secretKey];
            } else {
                NSLog(@"No ellipticCurve prime for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
            }
        } else {
            NSLog(@"No ellipticCurve parameters for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"gPoint is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}


-(id) initWithBitLength: (FGIntOverflow) bitLength {
    if (self = [super init]) {
        FGIntOverflow secretKeyLength;
        FGInt *tmpFGInt;

        gPoint = [ECPoint generateSecureCurveAndPointOfSize: bitLength];
        FGInt *nFGInt = [gPoint pointOrder], *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        
        secretKeyLength = bitLength;
        do {
            tmpFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: secretKeyLength];
            secretKey = [FGInt mod: tmpFGInt by: nFGInt];
            [tmpFGInt release];
        } while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal));
        [zero release]; 
        [one release];
        
        yPoint = [ECPoint add: gPoint kTimes: secretKey];
    }
    return self;
}


-(id) initWithNSData: (NSData *) secretKeyData {
    if (!secretKeyData) {
        NSLog(@"No secretKeyData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if ([secretKeyData length] == 0) {
        NSLog(@"secretKeyData is empty for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (self = [super init]) {
        FGInt *tmpFGInt;
        FGIntOverflow bitLength = [secretKeyData length] * 8;

        gPoint = [ECPoint generateSecureCurveAndPointOfSize: bitLength];
        FGInt *nFGInt = [gPoint pointOrder], *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        
        tmpFGInt = [[FGInt alloc] initWithNSData: secretKeyData];
        secretKey = [FGInt mod: tmpFGInt by: nFGInt];
        while (([FGInt compareAbsoluteValueOf: zero with: secretKey] == equal) || ([FGInt compareAbsoluteValueOf: one with: secretKey] == equal)) {
            [tmpFGInt increment];
            [secretKey release];
            secretKey = [FGInt mod: tmpFGInt by: nFGInt];
        } 
        [tmpFGInt release];
        [zero release]; 
        [one release];
        
        yPoint = [ECPoint add: gPoint kTimes: secretKey];
    }
    return self;
}



-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData {
    NSData *tmpData;
    unsigned char aBuffer[[publicKeyNSData length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *pFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    bytesRange = NSMakeRange(rangeStart, 2);
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *aFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *bFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;

    EllipticCurve *ec = [[EllipticCurve alloc] init];
    [ec setP: pFGInt];
    [ec setA: aFGInt];
    [ec setB: bFGInt];

    FGIntOverflow byteLength = [pFGInt byteSize];

    bytesRange = NSMakeRange(rangeStart, 1);
    if ([publicKeyNSData length] < rangeStart + 1) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    if (aBuffer[0] == 0) {
        gPoint = [[ECPoint alloc] initInfinityWithEllpiticCurve: ec];
        rangeStart += 1;
    } else if (aBuffer[0] == 4) {
        bytesRange = NSMakeRange(rangeStart , 2*byteLength + 1);
        if ([publicKeyNSData length] < rangeStart + 2*byteLength + 1) {
            NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return;
        }
        [publicKeyNSData getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: 2*byteLength + 1];
        gPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (2*byteLength + 1);
    } else if ((aBuffer[0] != 2) && (aBuffer[0] != 3)) {
        NSLog(@"publicKeyNSData is corrupt, no valid gPoint data, tag is %u, for %s at line %d", aBuffer[0], __PRETTY_FUNCTION__, __LINE__);
        return;
    } else {
        bytesRange = NSMakeRange(rangeStart , byteLength + 1);
        if ([publicKeyNSData length] < rangeStart + byteLength + 1) {
            NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return;
        }
        [publicKeyNSData getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: byteLength + 1];
        gPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (byteLength + 1);
    }

    bytesRange = NSMakeRange(rangeStart, 1);
    if ([publicKeyNSData length] < rangeStart + 1) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    if (aBuffer[0] == 0) {
        yPoint = [[ECPoint alloc] initInfinityWithEllpiticCurve: ec];
        rangeStart += 1;
    } else if (aBuffer[0] == 4) {
        bytesRange = NSMakeRange(rangeStart , 2*byteLength + 1);
        if ([publicKeyNSData length] < rangeStart + 2*byteLength + 1) {
            NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return;
        }
        [publicKeyNSData getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: 2*byteLength + 1];
        yPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (2*byteLength + 1);
    } else if ((aBuffer[0] != 2) && (aBuffer[0] != 3)) {
        NSLog(@"publicKeyNSData is corrupt, no valid yPoint data, tag is %u, for %s at line %d", aBuffer[0], __PRETTY_FUNCTION__, __LINE__);
        return;
    } else {
        bytesRange = NSMakeRange(rangeStart, byteLength + 1);
        if ([publicKeyNSData length] < rangeStart + byteLength + 1) {
            NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return;
        }
        [publicKeyNSData getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: byteLength + 1];
        yPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (byteLength + 1);
    }

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *oFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    [gPoint setPointOrder: oFGInt];
    [yPoint setPointOrder: [oFGInt retain]];
    rangeStart += keyLength;
    
    bytesRange = NSMakeRange(rangeStart , 2);
    if ([publicKeyNSData length] < rangeStart + 2) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([publicKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"publicKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
//        NSLog(@"publicKeyNSData is corrupt: %u + %u != %lu", rangeStart, keyLength, [publicKeyNSData length]);
        return;
    }
    [publicKeyNSData getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *tmpFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    [ec setCurveOrder: [FGInt multiply: oFGInt and: tmpFGInt]];
//    [gPoint setEllipticCurve: ec];
//    [yPoint setEllipticCurve: ec];
    [[gPoint ellipticCurve] setCurveOrder: [FGInt multiply: oFGInt and: tmpFGInt]];
    [[yPoint ellipticCurve] setCurveOrder: [[[gPoint ellipticCurve] curveOrder] retain]];
    [tmpFGInt release];
    
}


-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString {
    NSData *publicKeyNSData = [FGInt convertBase64ToNSData: publicKeyBase64NSString];
    [self setPublicKeyWithNSData: publicKeyNSData];
    [publicKeyNSData release];    
}


-(NSData *) publicKeyToNSData {
    if (!gPoint) {
        NSLog(@"No gPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yPoint) {
        NSLog(@"No yPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![gPoint ellipticCurve]) {
        NSLog(@"No ellipticCurve available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSMutableData *publicKeyData = [[NSMutableData alloc] init];
    NSData *tmpData;

    tmpData = [[[gPoint ellipticCurve] p] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [[[gPoint ellipticCurve] a] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [[[gPoint ellipticCurve] b] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [gPoint toCompressedNSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [yPoint toCompressedNSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

    tmpData = [[gPoint pointOrder] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];

//NSLog(@"The kitty key is");

    NSDictionary *tmpDiv = [FGInt divide: [[gPoint ellipticCurve] curveOrder] by: [gPoint pointOrder]];
    tmpData = [[tmpDiv objectForKey: quotientKey] toMPINSData];
    [publicKeyData appendData: tmpData];
    [tmpData release];
    [tmpDiv release];

    return publicKeyData;
}


-(NSString *) publicKeyToBase64NSString {
    NSData *publicKeyData = [self publicKeyToNSData];
    NSString *publicKeyBase64NSString = [FGInt convertNSDataToBase64: publicKeyData];
    [publicKeyData release];
    return publicKeyBase64NSString;    
}








-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData {
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    unsigned char aBuffer[2];

    if ([secretKeyNSData length] < rangeStart + 2) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [secretKeyNSData getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8)); 
    keyLength = (mpiLength + 7)/8 + 2;
    if ([secretKeyNSData length] < rangeStart + keyLength) {
        NSLog(@"secretKeyNSData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return;
    }
    secretKey = [[FGInt alloc] initWithMPINSData: secretKeyNSData];
}


-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString {
    NSData *secretKeyNSData = [FGInt convertBase64ToNSData: secretKeyBase64NSString];
    [self setSecretKeyWithNSData: secretKeyNSData];
    [secretKeyNSData release];
}


-(NSData *) secretKeyToNSData {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [secretKey toMPINSData];
    return secretKeyData;
}


-(NSString *) secretKeyToBase64NSString {
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *secretKeyData = [self secretKeyToNSData];
    NSString *secretKeyBase64NSString = [FGInt convertNSDataToBase64: secretKeyData];
    [secretKeyData release];
    return secretKeyBase64NSString;    
}


-(NSData *) encryptNSString: (NSString *) plainText {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *encryptedData = [self encryptNSData: plainTextData];
        return encryptedData;
    }
}


-(NSData *) encryptNSString: (NSString *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSData *plainTextData = [plainText dataUsingEncoding:NSUTF8StringEncoding], 
            *encryptedData = [self encryptNSData: plainTextData withRandomNSData: kData];
        return encryptedData;
    }
}


-(NSData *) encryptNSData: (NSData *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gPoint) {
        NSLog(@"No gPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![gPoint ellipticCurve]) {
        NSLog(@"No ellipticCurve available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yPoint) {
        NSLog(@"No yPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!kData) {
        NSLog(@"No kData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    FGIntOverflow byteLength = [[[gPoint ellipticCurve] p] byteSize];
    FGIntBase j;
    if ([plainText length] > byteLength - 3) {
        NSLog(@"plainText is too big for %s at line %d, make sure it contains %llu bytes or less", __PRETTY_FUNCTION__, __LINE__, byteLength - 3);
        return nil;
    }

    FGInt *nFGInt = [gPoint pointOrder];
    ECPoint *dataPoint = [ECPoint inbedNSData: plainText onEllipticCurve: [gPoint ellipticCurve]];
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
        
    FGInt *tmpFGInt = [[FGInt alloc] initWithNSData: kData];
    FGIntBase firstBit = (1u << 31);
    FGIntBase* numberArray = [[tmpFGInt number] mutableBytes];
    FGIntOverflow length = [[tmpFGInt number] length]/4;
    j = numberArray[length - 1];
    j = j | firstBit;
    numberArray[length - 1] = j;
    FGInt *kFGInt = [FGInt mod: tmpFGInt by: nFGInt];
    while (([FGInt compareAbsoluteValueOf: zero with: kFGInt] == equal) || ([FGInt compareAbsoluteValueOf: one with: kFGInt] == equal)) {
        [tmpFGInt increment];
        [kFGInt release];
        kFGInt = [FGInt mod: tmpFGInt by: nFGInt];
    } 
    [tmpFGInt release];
    ECPoint *kGPoint = [ECPoint add: gPoint kTimes: kFGInt];
    ECPoint *kYPoint = [ECPoint add: yPoint kTimes: kFGInt];
    [kFGInt release];
    [zero release]; 
    [one release];
    ECPoint *encryptedPoint = [ECPoint add: kYPoint and: dataPoint];
    [kYPoint release];

    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    NSData *pointData = [kGPoint toCompressedNSData];
    [encryptedData appendData: pointData];
    [pointData release];
    [kGPoint release];

    pointData = [encryptedPoint toCompressedNSData];
    [encryptedData appendData: pointData];
    [pointData release];

    return encryptedData;
}


-(NSData *) encryptNSData: (NSData *) plainText {
    FGIntOverflow byteLength = [secretKey byteSize];
    NSMutableData *kData;
    kData = [[NSMutableData alloc] initWithLength: byteLength];
    int result = SecRandomCopyBytes(kSecRandomDefault, byteLength, kData.mutableBytes);

    NSData *encryptedData = [self encryptNSData: plainText withRandomNSData: kData];
    [kData release];

    return encryptedData;
}



-(NSData *) decryptNSData: (NSData *) cipherText {
    if (!cipherText) {
        NSLog(@"No cipherText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gPoint) {
        NSLog(@"No gPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![gPoint ellipticCurve]) {
        NSLog(@"No ellipticCurve available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yPoint) {
        NSLog(@"No yPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSData *tmpData;
    unsigned char aBuffer[[cipherText length]];
    EllipticCurve *ec = [gPoint ellipticCurve];
    FGIntBase rangeStart = 0;
    ECPoint *encryptedPoint, *kGPoint = nil;
    FGIntOverflow byteLength = [[[gPoint ellipticCurve] p] byteSize];
    if (([cipherText length] != 2*(byteLength + 1)) && ([cipherText length] != 2) && ([cipherText length] != (byteLength + 2))) {
        NSLog(@"cipherText is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    
    NSRange bytesRange = NSMakeRange(rangeStart, 1);
    if ([cipherText length] < rangeStart + 1) {
        NSLog(@"cipherText is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    [cipherText getBytes: aBuffer range: bytesRange];
    if (aBuffer[0] == 0) {
        gPoint = [[ECPoint alloc] initInfinityWithEllpiticCurve: ec];
        rangeStart += 1;
    } else if ((aBuffer[0] != 2) && (aBuffer[0] != 3)) {
        NSLog(@"cipherText is corrupt, no valid kGPoint data, tag is %u, for %s at line %d", aBuffer[0], __PRETTY_FUNCTION__, __LINE__);
        return nil;
    } else {
        bytesRange = NSMakeRange(rangeStart , byteLength + 1);
        if ([cipherText length] < rangeStart + byteLength + 1) {
            NSLog(@"cipherText is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }
        [cipherText getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: byteLength + 1];
        kGPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (byteLength + 1);
    }

    bytesRange = NSMakeRange(rangeStart, 1);
    if ([cipherText length] < rangeStart + 1) {
        NSLog(@"cipherText is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    [cipherText getBytes: aBuffer range: bytesRange];
    if (aBuffer[0] == 0) {
        yPoint = [[ECPoint alloc] initInfinityWithEllpiticCurve: ec];
        rangeStart += 1;
    } else if ((aBuffer[0] != 2) && (aBuffer[0] != 3)) {
        NSLog(@"cipherText is corrupt, no valid encryptedPoint data, tag is %u, for %s at line %d", aBuffer[0], __PRETTY_FUNCTION__, __LINE__);
        return nil;
    } else {
        bytesRange = NSMakeRange(rangeStart, byteLength + 1);
        if ([cipherText length] < rangeStart + byteLength + 1) {
            NSLog(@"cipherText is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }
        [cipherText getBytes: aBuffer range: bytesRange];
        tmpData = [[NSData alloc] initWithBytes: aBuffer length: byteLength + 1];
        encryptedPoint = [[ECPoint alloc] initWithNSData: tmpData andEllipticCurve: ec];
        [tmpData release];
        rangeStart += (byteLength + 1);
    }
    ECPoint *tmpPoint = [ECPoint add: kGPoint kTimes: secretKey], *invPoint = [ECPoint invert: tmpPoint], *decryptedPoint = [ECPoint add: invPoint and: encryptedPoint];
    [tmpPoint release];
    [invPoint release];
    [kGPoint release];
    
    NSData *decryptedNSData = [decryptedPoint extractInbeddedNSData];
    [decryptedPoint release];

    return decryptedNSData;
}


@end





































@implementation NISTECDSA
@synthesize nistPrime;



-(id) initWithNISTcurve: (tag) nistPrimeTag {
    if (self = [super init]) {
        EllipticCurve *ec = [[EllipticCurve alloc] init];
        gPoint = [[ECPoint alloc] init];
        nistPrime = nistPrimeTag;
        switch (nistPrime) {
            case p192:
                [ec setP: [[FGInt alloc] initWithBase10String: @"6277101735386680763835789423207666416083908700390324961279"]];
                [ec setA: [[FGInt alloc] initWithBase10String: @"6277101735386680763835789423207666416083908700390324961276"]];
                [ec setB: [[FGInt alloc] initWithBase10String: @"2455155546008943817740293915197451784769108058161191238065"]];
                [ec setCurveOrder: [[FGInt alloc] initWithBase10String: @"6277101735386680763835789423176059013767194773182842284081"]];
                break;
            case p224:
                [ec setP: [[FGInt alloc] initWithBase10String: @"26959946667150639794667015087019630673557916260026308143510066298881"]];
                [ec setA: [[FGInt alloc] initWithBase10String: @"26959946667150639794667015087019630673557916260026308143510066298878"]];
                [ec setB: [[FGInt alloc] initWithBase10String: @"18958286285566608000408668544493926415504680968679321075787234672564"]];
                [ec setCurveOrder: [[FGInt alloc] initWithBase10String: @"26959946667150639794667015087019625940457807714424391721682722368061"]];
                break;
            case p256:
                [ec setP: [[FGInt alloc] initWithBase10String: @"115792089210356248762697446949407573530086143415290314195533631308867097853951"]];
                [ec setA: [[FGInt alloc] initWithBase10String: @"115792089210356248762697446949407573530086143415290314195533631308867097853948"]];
                [ec setB: [[FGInt alloc] initWithBase10String: @"41058363725152142129326129780047268409114441015993725554835256314039467401291"]];
                [ec setCurveOrder: [[FGInt alloc] initWithBase10String: @"115792089210356248762697446949407573529996955224135760342422259061068512044369"]];
                break;
            case p384:
                [ec setP: [[FGInt alloc] initWithBase10String: @"39402006196394479212279040100143613805079739270465446667948293404245721771496870329047266088258938001861606973112319"]];
                [ec setA: [[FGInt alloc] initWithBase10String: @"39402006196394479212279040100143613805079739270465446667948293404245721771496870329047266088258938001861606973112316"]];
                [ec setB: [[FGInt alloc] initWithBase10String: @"27580193559959705877849011840389048093056905856361568521428707301988689241309860865136260764883745107765439761230575"]];
                [ec setCurveOrder: [[FGInt alloc] initWithBase10String: @"39402006196394479212279040100143613805079739270465446667946905279627659399113263569398956308152294913554433653942643"]];
                break;
            case p521:
                [ec setP: [[FGInt alloc] initWithBase10String: @"6864797660130609714981900799081393217269435300143305409394463459185543183397656052122559640661454554977296311391480858037121987999716643812574028291115057151"]];
                [ec setA: [[FGInt alloc] initWithBase10String: @"6864797660130609714981900799081393217269435300143305409394463459185543183397656052122559640661454554977296311391480858037121987999716643812574028291115057148"]];
                [ec setB: [[FGInt alloc] initWithBase10String: @"1093849038073734274511112390766805569936207598951683748994586394495953116150735016013708737573759623248592132296706313309438452531591012912142327488478985984"]];
                [ec setCurveOrder: [[FGInt alloc] initWithBase10String: @"6864797660130609714981900799081393217269435300143305409394463459185543183397655394245057746333217197532963996371363321113864768612440380340372808892707005449"]];
                break;
        }
        [gPoint setEllipticCurve: ec];
        FGIntOverflow bits = [[ec p] bitSize] - 1;
        [gPoint setX: [[FGInt alloc] initWithRandomNumberOfBitSize: bits]];
        [gPoint setY: [[FGInt alloc] initWithFGIntBase: 0]];
        [gPoint setPointOrder: [[ec curveOrder] mutableCopy]];
        BOOL stop = NO;
        [gPoint findNextECPointWithStop: &stop];
        [self setSecretKeyAndComputeYPoint: [[FGInt alloc] initWithRandomNumberOfBitSize: bits]];
    }
    return self;
}


-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData {
    [super setPublicKeyWithNSData: publicKeyNSData];
    switch ([[[gPoint ellipticCurve] p] bitSize]) {
        case 192:
            nistPrime = p192;
            break;
        case 224:
            nistPrime = p224;
            break;
        case 256:
            nistPrime = p256;
            break;
        case 384:
            nistPrime = p384;
            break;
        case 521:
            nistPrime = p521;
            break;
    }
}

-(void) setGPointAndComputeYPoint: (ECPoint *) newG {
    if (secretKey) {
        if ([newG ellipticCurve]) {
            if ([[newG ellipticCurve] p]) {
                if (gPoint) {
                    [gPoint release];
                }
                gPoint = newG;
                if (yPoint) {
                    [yPoint release];
                }
                yPoint = [ECPoint add: gPoint kTimes: secretKey withNISTprime: nistPrime];
            } else {
                NSLog(@"No ellipticCurve prime for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
            }
        } else {
            NSLog(@"No ellipticCurve parameters for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"secretKey is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}

-(void) setSecretKeyAndComputeYPoint: (FGInt *) newSecretKey {
    if (gPoint) {
        if ([gPoint ellipticCurve]) {
            if ([[gPoint ellipticCurve] p]) {
                if (secretKey) {
                    [secretKey release];
                }
                secretKey = newSecretKey;
                if (yPoint) {
                    [yPoint release];
                }
                yPoint = [ECPoint add: gPoint kTimes: secretKey withNISTprime: nistPrime];
            } else {
                NSLog(@"No ellipticCurve prime for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
            }
        } else {
            NSLog(@"No ellipticCurve parameters for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"gPoint is empty for %s at line %d, cannot compute yFGInt without it", __PRETTY_FUNCTION__, __LINE__);
    }
}





-(NSData *) signNSData: (NSData *) plainText withRandomNSData: (NSData *) kData {
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!secretKey) {
        NSLog(@"No secretKey available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!gPoint) {
        NSLog(@"No gPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![gPoint ellipticCurve]) {
        NSLog(@"No ellipticCurve available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!yPoint) {
        NSLog(@"No yPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!kData) {
        NSLog(@"No kData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    FGIntOverflow byteLength = [[[gPoint ellipticCurve] p] byteSize];
    FGIntBase firstBit, j;
    if ([plainText length] < byteLength) {
        NSLog(@"plainText is too small for %s at line %d, make sure it contains more than %llu bytes", __PRETTY_FUNCTION__, __LINE__, byteLength);
        return nil;
    }

    FGInt *rFGInt, *sFGInt;
    FGInt *nFGInt = [gPoint pointOrder];
    FGIntOverflow nBitLength = [nFGInt bitSize], length;
    FGInt *dataFGInt = [[FGInt alloc] initWithNSData: plainText];
    [dataFGInt shiftRightBy: [dataFGInt bitSize] - nBitLength];
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0];
    FGIntBase* numberArray;    

    BOOL noLuck;
    do {
        FGInt *tmpFGInt = [[FGInt alloc] initWithNSData: kData];
        firstBit = (1u << 31);
        numberArray = [[tmpFGInt number] mutableBytes];
        length = [[tmpFGInt number] length]/4;
        j = numberArray[length - 1];
        j = j | firstBit;
        numberArray[length - 1] = j;
        FGInt *kFGInt = [FGInt mod: tmpFGInt by: nFGInt];
        ECPoint *kGPoint = [ECPoint add: gPoint kTimes: kFGInt withNISTprime: nistPrime];
        rFGInt = [FGInt mod: [kGPoint x] by: nFGInt];
        while (([FGInt compareAbsoluteValueOf: zero with: kFGInt] == equal) || ([FGInt compareAbsoluteValueOf: one with: kFGInt] == equal) || ([FGInt compareAbsoluteValueOf: zero with: rFGInt] == equal)) {
            [tmpFGInt increment];
            [kFGInt release];
            kFGInt = [FGInt mod: tmpFGInt by: nFGInt];
            [kGPoint release];
            kGPoint = [ECPoint add: gPoint kTimes: kFGInt withNISTprime: nistPrime];
            [rFGInt release];
            rFGInt = [FGInt mod: [kGPoint x] by: nFGInt];
        } 
        [tmpFGInt release];
    
        FGInt *kInvertedFGInt = [FGInt modularInverse: kFGInt mod: nFGInt];
        tmpFGInt = [FGInt multiply: rFGInt and: secretKey];
        [kFGInt release];
        [dataFGInt addWith: tmpFGInt];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: kInvertedFGInt and: dataFGInt];
        [dataFGInt release];
        [kInvertedFGInt release];
        sFGInt = [FGInt mod: tmpFGInt by: nFGInt];
        [tmpFGInt release];
    
        noLuck = ([FGInt compareAbsoluteValueOf: zero with: sFGInt] == equal);
        if (noLuck) {
            [rFGInt release];
            [sFGInt release];
            [kGPoint release];
        }
    } while (noLuck);

    [zero release]; 
    [one release];

    NSMutableData *signatureData = [[NSMutableData alloc] init];
    NSData *mpiData = [rFGInt toMPINSData];
    [rFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    mpiData = [sFGInt toMPINSData];
    [sFGInt release];
    [signatureData appendData: mpiData];
    [mpiData release];

    return signatureData;
}


-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText {
    if (!signature) {
        NSLog(@"No signature available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!plainText) {
        NSLog(@"No plainText available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!gPoint) {
        NSLog(@"No gPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (![gPoint ellipticCurve]) {
        NSLog(@"No ellipticCurve available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    if (!yPoint) {
        NSLog(@"No yPoint available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }

    NSData *tmpData;
    unsigned char aBuffer[[signature length]];
    FGIntBase rangeStart = 0, mpiLength, keyLength;
    
    if ([signature length] < rangeStart + 2) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    NSRange bytesRange = NSMakeRange(rangeStart, 2);
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *rFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];
    rangeStart += keyLength;
    
    FGInt *nFGInt = [gPoint pointOrder];
    if ([FGInt compareAbsoluteValueOf: rFGInt with: nFGInt] != smaller) {
        [rFGInt release];
        return NO;
    }

    bytesRange = NSMakeRange(rangeStart , 2);
    if ([signature length] < rangeStart + 2) {
        [rFGInt release];
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    mpiLength = (aBuffer[1] | (aBuffer[0] << 8));
    keyLength = (mpiLength + 7)/8 + 2;
    bytesRange = NSMakeRange(rangeStart, keyLength);
    if ([signature length] < rangeStart + keyLength) {
        [rFGInt release];
        NSLog(@"signature is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return NO;
    }
    [signature getBytes: aBuffer range: bytesRange];
    tmpData = [[NSData alloc] initWithBytes: aBuffer length: keyLength];
    FGInt *sFGInt = [[FGInt alloc] initWithMPINSData: tmpData];
    [tmpData release];

    FGIntOverflow nBitLength = [nFGInt bitSize];
    FGInt *plainTextFGInt = [[FGInt alloc] initWithNSData: plainText];
    [plainTextFGInt shiftRightBy: [plainTextFGInt bitSize] - nBitLength];

    BOOL signatureCheck = YES;
    if ([FGInt compareAbsoluteValueOf: sFGInt with: nFGInt] != smaller) {
        [rFGInt release];
        [sFGInt release];
        signatureCheck = NO;
    }
    if (!signatureCheck) {
        return signatureCheck;
    }

    FGInt *tmpFGInt, *wFGInt = [FGInt modularInverse: sFGInt mod: nFGInt];
    tmpFGInt = [FGInt multiply: wFGInt and: plainTextFGInt];
    FGInt *u1FGInt = [FGInt mod: tmpFGInt by: nFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: wFGInt and: rFGInt];
    FGInt *u2FGInt = [FGInt mod: tmpFGInt by: nFGInt];
    [tmpFGInt release];
    [wFGInt release];
    // ECPoint *sum = [ECPoint add: gPoint k1Times: u1FGInt and: yPoint k2Times: u2FGInt];
    ECPoint *sum = [ECPoint add: gPoint k1Times: u1FGInt and: yPoint k2Times: u2FGInt withNISTprime: nistPrime];
    [u1FGInt release];
    [u2FGInt release];
    [sFGInt release];
    
    tmpFGInt = [FGInt mod: [sum x] by: nFGInt];
    signatureCheck = ([FGInt compareAbsoluteValueOf: rFGInt with: tmpFGInt] == equal);
    [tmpFGInt release];

    [rFGInt release];
    [sum release];

    return signatureCheck;
}


@end







































