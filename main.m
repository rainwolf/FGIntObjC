#import <Foundation/Foundation.h>
#import "FGInt.h"
#import "ECGFp.h"
#import "FGIntCryptography.h"

int main (int argc, const char * argv[]) {
    @autoreleasepool{
        NSDate *date;
        double timePassed_ms;
        NSString *plaintextString, *pkey, *skey;
        NSData *encryptedData, *decryptedData, *signedData;
        FGIntBase bitSize = 1024;    

        NSLog(@" initializing %u bit RSA.", bitSize);
        plaintextString = @"Prediction is very difficult, especially of the future.";
        date = [NSDate date];
        FGIntRSA *rsaKeys = [[FGIntRSA alloc] initWithBitLength: bitSize];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Generating %u bit RSA keys took %fms", bitSize, timePassed_ms);
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [rsaKeys publicKeyToBase64NSString];
        skey = [rsaKeys secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [rsaKeys release];
        rsaKeys = [[FGIntRSA alloc] init];
        [rsaKeys setPublicKeyWithBase64NSString: pkey];
        [rsaKeys setSecretKeyWithBase64NSString: skey];
        NSLog(@"encrypting: %@",plaintextString);
        date = [NSDate date];
        encryptedData = [rsaKeys encryptNSString: plaintextString];
        NSLog(@"decrypting...");
        decryptedData = [rsaKeys decryptNSData: encryptedData];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Encryption/Decryption with %u bit RSA keys took %fms", bitSize, timePassed_ms);
        NSLog(@"the decrypted result is: %@",[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]);
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [rsaKeys signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [rsaKeys verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with %u bit RSA keys took %fms \n \n ", bitSize, timePassed_ms);
        [rsaKeys release];
        [encryptedData release];
        [decryptedData release];
        [signedData release];
        [pkey release];
        [skey release];

    

        NSLog(@" initializing %u bit ElGamal.", bitSize);
        plaintextString = @"The sooner you fall behind, the more time you'll have to catch up.";
        date = [NSDate date];
        FGIntElGamal *elgamalKeys = [[FGIntElGamal alloc] initWithBitLength: bitSize];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Generating %u bit ElGamal keys took %fms", bitSize, timePassed_ms);
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [elgamalKeys publicKeyToBase64NSString]; 
        skey = [elgamalKeys secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey );
        NSLog(@"The secret key is: %@", skey );
        [elgamalKeys release];
        elgamalKeys = [[FGIntElGamal alloc] init];
        [elgamalKeys setPublicKeyWithBase64NSString: pkey];
        [elgamalKeys setSecretKeyWithBase64NSString: skey];
        NSLog(@"encrypting: %@",plaintextString);
        date = [NSDate date];
        encryptedData = [elgamalKeys encryptNSString: plaintextString];
        NSLog(@"decrypting...");
        decryptedData = [elgamalKeys decryptNSData: encryptedData];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Encryption/Decryption with %u bit ElGamal keys took %fms", bitSize, timePassed_ms);
        NSLog(@"the decrypted result is: %@",[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]);
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [elgamalKeys signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [elgamalKeys verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with %u bit ElGamal keys took %fms \n \n ", bitSize, timePassed_ms);
        [elgamalKeys release];
        [encryptedData release];
        [decryptedData release];
        [signedData release];
        [pkey release];
        [skey release];



        NSLog(@" initializing %u bit DSA.", bitSize);
        plaintextString = @"Theory is important, at least in theory.";
        date = [NSDate date];
        FGIntDSA *dsaKeys = [[FGIntDSA alloc] initWithBitLength: bitSize];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Generating %u bit DSA keys took %fms", bitSize, timePassed_ms);
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [dsaKeys publicKeyToBase64NSString]; 
        skey = [dsaKeys secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", [dsaKeys publicKeyToBase64NSString] );
        NSLog(@"The secret key is: %@", [dsaKeys secretKeyToBase64NSString] );
        [dsaKeys release];
        dsaKeys = [[FGIntDSA alloc] init];
        [dsaKeys setPublicKeyWithBase64NSString: pkey];
        [dsaKeys setSecretKeyWithBase64NSString: skey];
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [dsaKeys signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [dsaKeys verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with %u bit DSA keys took %fms \n \n ", bitSize, timePassed_ms);
        [dsaKeys release];
        [signedData release];
        [pkey release];
        [skey release];




        NSLog(@" initializing %u bit GOSTDSA.", bitSize);
        plaintextString = @"2 + 2 = 5, for large values of 2.";
        date = [NSDate date];
        FGIntGOSTDSA *gostdsaKeys = [[FGIntGOSTDSA alloc] initWithBitLength: bitSize];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Generating %u bit GOSTDSA keys took %fms", bitSize, timePassed_ms);
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [gostdsaKeys publicKeyToBase64NSString]; 
        skey = [gostdsaKeys secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [gostdsaKeys release];
        gostdsaKeys = [[FGIntGOSTDSA alloc] init];
        [gostdsaKeys setPublicKeyWithBase64NSString: pkey];
        [gostdsaKeys setSecretKeyWithBase64NSString: skey];
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [gostdsaKeys signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [gostdsaKeys verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with %u bit GOSTDSA keys took %fms \n \n ", bitSize, timePassed_ms);
        [gostdsaKeys release];
        [signedData release];
        [pkey release];
        [skey release];



        bitSize = 160;
        plaintextString = @"Physics is like sex. Sure, it may give some practical results, but that's not why we do it.";
        NSLog(@" initializing %u bit ECDSA.", bitSize);
        date = [NSDate date];
        ECDSA *ecDSA = [[ECDSA alloc] initWithBitLength: bitSize];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Generating %u bit ECDSA keys took %fms", bitSize, timePassed_ms);
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [ecDSA publicKeyToBase64NSString];
        skey = [ecDSA secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [ecDSA release];
        ecDSA = [[ECDSA alloc] init];
        [ecDSA setSecretKeyWithBase64NSString: skey];
        [ecDSA setPublicKeyWithBase64NSString: pkey];
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [ecDSA signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [ecDSA verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with %u bit ECDSA keys took %fms \n \n ", bitSize, timePassed_ms);
        [ecDSA release];
        [signedData release];
        [pkey release];
        [skey release];




        plaintextString = @"Warp 5, engage!";
        NSLog(@" initializing %u bit ECElGamal.", bitSize);
        date = [NSDate date];
        ECElGamal *ecElGamal = [[ECElGamal alloc] initWithBitLength: bitSize];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Generating %u bit ECElGamal keys took %fms", bitSize, timePassed_ms);
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [ecElGamal publicKeyToBase64NSString];
        skey = [ecElGamal secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [ecElGamal release];
        ecElGamal = [[ECElGamal alloc] init];
        [ecElGamal setSecretKeyWithBase64NSString: skey];
        [ecElGamal setPublicKeyWithBase64NSString: pkey];
        NSLog(@"encrypting: %@",plaintextString);
        date = [NSDate date];
        encryptedData = [ecElGamal encryptNSString: plaintextString];
        decryptedData = [ecElGamal decryptNSData: encryptedData];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Encryption/Decryption with %u bit ECElGamal keys took %fms", bitSize, timePassed_ms);
        NSLog(@"the decrypted result is: %@",[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]);
        [ecElGamal release];
        [encryptedData release];
        [decryptedData release];
        [pkey release];
        [skey release];
    }
    return 0;
}
