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

/*
#define rsaKey @"RSA"
#define elgamalKey @"ElGamal"
#define dsaKey @"DSA"
#define gostdsaKey @"GOSTDSA"
*/

#define FGIntCryptography_version 20141115



@interface FGIntRSA : NSObject <NSMutableCopying> {
    FGInt *modulus, *publicExponent, *privateKey, *pFGInt, *qFGInt, *pInvertedModQ;
}
@property (assign, readwrite) FGInt *modulus;
@property (assign, readwrite) FGInt *publicExponent;
@property (assign, readwrite) FGInt *privateKey;
@property (assign, readwrite) FGInt *pFGInt;
@property (assign, readwrite) FGInt *qFGInt;
@property (assign, readwrite) FGInt *pInvertedModQ;

-(void) dealloc;
-(id) initWithBitLength: (FGIntOverflow) bitLength;
-(id) initWithNSData: (NSData *) dataSeed;
-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData;
-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString;
-(NSData *) publicKeyToNSData;
-(NSString *) publicKeyToBase64NSString;
-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData;
-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString;
-(NSData *) secretKeyToNSData;
-(NSString *) secretKeyToBase64NSString;
-(NSData *) encryptNSString: (NSString *) plainText;
-(NSData *) encryptNSData: (NSData *) plainText;
-(NSData *) decryptNSData: (NSData *) cipherText;
-(NSData *) signNSString: (NSString *) plainText;
-(NSData *) signNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText;

@end




@interface FGIntElGamal : NSObject <NSCopying> {
    FGInt *primeFGInt, *gFGInt, *secretKey, *yFGInt;
}
@property (assign, readwrite) FGInt *primeFGInt;
@property (assign, readwrite) FGInt *gFGInt;
@property (assign, readwrite) FGInt *secretKey;
@property (assign, readwrite) FGInt *yFGInt;

-(void) setGFGIntAndComputeY: (FGInt *) newG;
-(void) setSecretKeyAndComputeY: (FGInt *) newSecretKey;
-(void) dealloc;
-(id) initWithBitLength: (FGIntOverflow) bitLength;
// -(id) initWithNSData: (NSData *) secretKeyData;
-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData;
-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString;
-(NSData *) publicKeyToNSData;
-(NSString *) publicKeyToBase64NSString;
-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData;
-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString;
-(NSData *) secretKeyToNSData;
-(NSString *) secretKeyToBase64NSString;
-(NSData *) encryptNSString: (NSString *) plainText;
-(NSData *) encryptNSData: (NSData *) plainText;
-(NSData *) decryptNSData: (NSData *) cipherText;
-(NSData *) signNSString: (NSString *) plainText;
-(NSData *) signNSString: (NSString *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) signNSData: (NSData *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) signNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText;

@end




@interface FGIntDSA : NSObject <NSCopying> {
    FGInt *pFGInt, *qFGInt, *gFGInt, *secretKey, *yFGInt;
}
@property (assign, readwrite) FGInt *pFGInt;
@property (assign, readwrite) FGInt *qFGInt;
@property (assign, readwrite) FGInt *gFGInt;
@property (assign, readwrite) FGInt *secretKey;
@property (assign, readwrite) FGInt *yFGInt;

-(void) setGFGIntAndComputeY: (FGInt *) newG;
-(void) setSecretKeyAndComputeY: (FGInt *) newSecretKey;
-(void) dealloc;
-(id) initWithBitLength: (FGIntOverflow) bitLength;
-(id) initWithNSData: (NSData *) secretKeyData;
-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData;
-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString;
-(NSData *) publicKeyToNSData;
-(NSString *) publicKeyToBase64NSString;
-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData;
-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString;
-(NSData *) secretKeyToNSData;
-(NSString *) secretKeyToBase64NSString;
-(NSData *) signNSString: (NSString *) plainText;
-(NSData *) signNSString: (NSString *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) signNSData: (NSData *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) signNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText;

@end




@interface FGIntGOSTDSA : NSObject <NSCopying> {
    FGInt *pFGInt, *qFGInt, *gFGInt, *secretKey, *yFGInt;
}
@property (assign, readwrite) FGInt *pFGInt;
@property (assign, readwrite) FGInt *qFGInt;
@property (assign, readwrite) FGInt *gFGInt;
@property (assign, readwrite) FGInt *secretKey;
@property (assign, readwrite) FGInt *yFGInt;

-(void) setGFGIntAndComputeY: (FGInt *) newG;
-(void) setSecretKeyAndComputeY: (FGInt *) newSecretKey;
-(void) dealloc;
-(id) initWithBitLength: (FGIntOverflow) bitLength;
-(id) initWithNSData: (NSData *) secretKeyData;
-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData;
-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString;
-(NSData *) publicKeyToNSData;
-(NSString *) publicKeyToBase64NSString;
-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData;
-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString;
-(NSData *) secretKeyToNSData;
-(NSString *) secretKeyToBase64NSString;
-(NSData *) signNSString: (NSString *) plainText;
-(NSData *) signNSString: (NSString *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) signNSData: (NSData *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) signNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText;

@end




@interface ECDSA : NSObject <NSCopying> {
    ECPoint *gPoint, *yPoint;
    FGInt *secretKey;
}
@property (assign, readwrite) ECPoint *gPoint;
@property (assign, readwrite) FGInt *secretKey;
@property (assign, readwrite) ECPoint *yPoint;

-(void) dealloc;
-(void) setGPointAndComputeYPoint: (ECPoint *) newG;
-(void) setSecretKeyAndComputeYPoint: (FGInt *) newSecretKey;
-(id) initWithBitLength: (FGIntOverflow) bitLength;
-(id) initWithNSData: (NSData *) secretKeyData;

-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData;
-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString;
-(NSData *) secretKeyToNSData;
-(NSString *) secretKeyToBase64NSString;
-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData;
-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString;
-(NSData *) publicKeyToNSData;
-(NSString *) publicKeyToBase64NSString;
-(NSData *) signNSString: (NSString *) plainText;
-(NSData *) signNSString: (NSString *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) signNSData: (NSData *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) signNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSData: (NSData *) plainText;
-(BOOL) verifySignature: (NSData *) signature ofPlainTextNSString: (NSString *) plainText;

@end




@interface ECElGamal : NSObject <NSCopying> {
    ECPoint *gPoint, *yPoint;
    FGInt *secretKey;
}
@property (assign, readwrite) ECPoint *gPoint;
@property (assign, readwrite) FGInt *secretKey;
@property (assign, readwrite) ECPoint *yPoint;

-(void) dealloc;
-(void) setGPointAndComputeYPoint: (ECPoint *) newG;
-(void) setSecretKeyAndComputeYPoint: (FGInt *) newSecretKey;
-(id) initWithBitLength: (FGIntOverflow) bitLength;
-(id) initWithNSData: (NSData *) secretKeyData;

-(void) setSecretKeyWithNSData: (NSData *) secretKeyNSData;
-(void) setSecretKeyWithBase64NSString: (NSString *) secretKeyBase64NSString;
-(NSData *) secretKeyToNSData;
-(NSString *) secretKeyToBase64NSString;
-(void) setPublicKeyWithNSData: (NSData *) publicKeyNSData;
-(void) setPublicKeyWithBase64NSString: (NSString *) publicKeyBase64NSString;
-(NSData *) publicKeyToNSData;
-(NSString *) publicKeyToBase64NSString;
-(NSData *) encryptNSString: (NSString *) plainText;
-(NSData *) encryptNSString: (NSString *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) encryptNSData: (NSData *) plainText withRandomNSData: (NSData *) kData;
-(NSData *) encryptNSData: (NSData *) plainText;
-(NSData *) decryptNSData: (NSData *) cipherText;

@end




//@interface FGIntCryptography : NSObject {
//}

//@end