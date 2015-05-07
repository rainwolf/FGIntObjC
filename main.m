#import <Foundation/Foundation.h>
#import "NSMutableData+FGInt.h"
#import "FGIntCryptography.h"
#import "NaCl.h"



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
        NSLog(@"the decrypted result is: %@ \n \n ",[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]);
        [ecElGamal release];
        [encryptedData release];
        [decryptedData release];
        [pkey release];
        [skey release];




        plaintextString = @"If you must choose between two evils, pick the one you've never tried before.";
        NSLog(@" initializing ECDSA with NIST Curve P192.");
        NISTECDSA *nistECDSA = [[NISTECDSA alloc] initWithNISTcurve: p192];
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [nistECDSA publicKeyToBase64NSString];
        skey = [nistECDSA secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [nistECDSA release];
        nistECDSA = [[NISTECDSA alloc] init];
        [nistECDSA setSecretKeyWithBase64NSString: skey];
        [nistECDSA setPublicKeyWithBase64NSString: pkey];
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [nistECDSA signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [nistECDSA verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with P192 ECDSA keys took %fms \n \n ", timePassed_ms);
        [nistECDSA release];
        [signedData release];
        [pkey release];
        [skey release];



        plaintextString = @"Experience is something you don't get until just after you need it.";
        NSLog(@" initializing ECDSA with NIST Curve P224.");
        nistECDSA = [[NISTECDSA alloc] initWithNISTcurve: p224];
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [nistECDSA publicKeyToBase64NSString];
        skey = [nistECDSA secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [nistECDSA release];
        nistECDSA = [[NISTECDSA alloc] init];
        [nistECDSA setSecretKeyWithBase64NSString: skey];
        [nistECDSA setPublicKeyWithBase64NSString: pkey];
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [nistECDSA signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [nistECDSA verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with P224 ECDSA keys took %fms \n \n ", timePassed_ms);
        [nistECDSA release];
        [signedData release];
        [pkey release];
        [skey release];



        plaintextString = @"Money can't buy love. But it CAN rent a very close imitation.";
        NSLog(@" initializing ECDSA with NIST Curve P256.");
        nistECDSA = [[NISTECDSA alloc] initWithNISTcurve: p256];
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [nistECDSA publicKeyToBase64NSString];
        skey = [nistECDSA secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [nistECDSA release];
        nistECDSA = [[NISTECDSA alloc] init];
        [nistECDSA setSecretKeyWithBase64NSString: skey];
        [nistECDSA setPublicKeyWithBase64NSString: pkey];
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [nistECDSA signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [nistECDSA verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with P256 ECDSA keys took %fms \n \n ", timePassed_ms);
        [nistECDSA release];
        [signedData release];
        [pkey release];
        [skey release];




        plaintextString = @"How many of you believe in telekinesis? Raise my hands....";
        NSLog(@" initializing ECDSA with NIST Curve P384.");
        nistECDSA = [[NISTECDSA alloc] initWithNISTcurve: p384];
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [nistECDSA publicKeyToBase64NSString];
        skey = [nistECDSA secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [nistECDSA release];
        nistECDSA = [[NISTECDSA alloc] init];
        [nistECDSA setSecretKeyWithBase64NSString: skey];
        [nistECDSA setPublicKeyWithBase64NSString: pkey];
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [nistECDSA signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [nistECDSA verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with P384 ECDSA keys took %fms \n \n ", timePassed_ms);
        [nistECDSA release];
        [signedData release];
        [pkey release];
        [skey release];




        plaintextString = @"It is an infantile superstition of the human spirit that virginity would be thought a virtue and not the barrier that separates ignorance from knowledge.";
        NSLog(@" initializing ECDSA with NIST Curve P521.");
        nistECDSA = [[NISTECDSA alloc] initWithNISTcurve: p521];
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [nistECDSA publicKeyToBase64NSString];
        skey = [nistECDSA secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [nistECDSA release];
        nistECDSA = [[NISTECDSA alloc] init];
        [nistECDSA setSecretKeyWithBase64NSString: skey];
        [nistECDSA setPublicKeyWithBase64NSString: pkey];
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [nistECDSA signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [nistECDSA verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with P521 ECDSA keys took %fms \n \n ", timePassed_ms);
        [nistECDSA release];
        [signedData release];
        [pkey release];
        [skey release];




        plaintextString = @"Religion is a culture of faith; science is a culture of doubt.";
        NSLog(@" initializing bit Ed25519-SHA-512.");
        date = [NSDate date];
        Ed25519SHA512 *edKeys = [[Ed25519SHA512 alloc] init];
        [edKeys generateNewSecretAndPublicKey];
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Generating Ed25519-SHA-512 keys took %fms", timePassed_ms);
// The next 8 lines are an example of how to extract the keys and reuse them
        pkey = [edKeys publicKeyToBase64NSString];
        skey = [edKeys secretKeyToBase64NSString];
        NSLog(@"The public key is: %@", pkey);
        NSLog(@"The secret key is: %@", skey);
        [edKeys release];
        edKeys = [[Ed25519SHA512 alloc] init];
        [edKeys setSecretKeyWithBase64NSString: skey];
        [edKeys setPublicKeyWithBase64NSString: pkey];
        NSLog(@"Signing: %@", plaintextString);
        date = [NSDate date];
        signedData = [edKeys signNSString: plaintextString];
        NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
        NSLog(@"Verifying the signature...   Is it valid? %@", [edKeys verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
        timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
        NSLog(@"Signature Generation/Verification with Ed25519-SHA-512 took %fms \n \n ", timePassed_ms);
        [edKeys release];
        [signedData release];
        [pkey release];
        [skey release];




        NSLog(@" (un)packing of a message with Curve25519, XSalsa20, and Poly1305. Like NaCl does.");
        NaClPacket *nacl = [[NaClPacket alloc] init];
        [nacl setSecretKey: [[NSMutableData alloc] initWithHexString: @"77076d0a7318a57d3c16c17251b26645df4c2f87ebc0992ab177fba51db92c2a"]];
        [nacl setRecipientPK: [[NSMutableData alloc] initWithHexString: @"de9edb7d7b7dc1b4d35b61c2ece435373f8343c85b78674dadfc7e146f882b4f"]];
        [nacl setNonce: [[NSMutableData alloc] initWithHexString: @"69696ee955b62b73cd62bda875fc73d68219e0036b7a0b37"]];
        [nacl setMessage: [[NSMutableData alloc] initWithHexString: @"be075fc53c81f2d5cf141316ebeb0c7b5228c52a4c62cbd44b66849b64244ffce5ecbaaf33bd751a1ac728d45e6c61296cdc3c01233561f41db66cce314adb310e3be8250c46f06dceea3a7fa1348057e2f6556ad6b1318a024a838f21af1fde048977eb48f59ffd4924ca1c60902e52f0a089bc76897040e082f937763848645e0705"]];
        NSMutableData *tmpResult = (NSMutableData *) [nacl packCurve25519Xsalsa20Poly1305];
        [nacl release];
        NSLog(@" Expected boxed packet: f3ffc7703f9400e52a7dfb4b3d3305d98e993b9f48681273c29650ba32fc76ce48332ea7164d96a4476fb8c531a1186ac0dfc17c98dce87b4da7f011ec48c97271d2c20f9b928fe2270d6fb863d51738b48eeee314a7cc8ab932164548e526ae90224368517acfeabd6bb3732bc0e9da99832b61ca01b6de56244a9e88d5f9b37973f622a43d14a6599b1f654cb45a74e355a5");
        NSLog(@" Actual  boxed  packet: %@", [tmpResult toHexString]);
        nacl = [[NaClPacket alloc] initWithMessage: [[NSMutableData alloc] initWithHexString: @"f3ffc7703f9400e52a7dfb4b3d3305d98e993b9f48681273c29650ba32fc76ce48332ea7164d96a4476fb8c531a1186ac0dfc17c98dce87b4da7f011ec48c97271d2c20f9b928fe2270d6fb863d51738b48eeee314a7cc8ab932164548e526ae90224368517acfeabd6bb3732bc0e9da99832b61ca01b6de56244a9e88d5f9b37973f622a43d14a6599b1f654cb45a74e355a5"]
            recipientsPublicKey: [[NSMutableData alloc] initWithHexString: @"de9edb7d7b7dc1b4d35b61c2ece435373f8343c85b78674dadfc7e146f882b4f"] secretKey: [[NSMutableData alloc] initWithHexString: @"77076d0a7318a57d3c16c17251b26645df4c2f87ebc0992ab177fba51db92c2a"]
            andNonce: [[NSMutableData alloc] initWithHexString: @"69696ee955b62b73cd62bda875fc73d68219e0036b7a0b37"]];
        tmpResult = (NSMutableData *) [nacl unpackCurve25519Xsalsa20Poly1305];
        [nacl release];
        NSLog(@" Expected unboxed packet: be075fc53c81f2d5cf141316ebeb0c7b5228c52a4c62cbd44b66849b64244ffce5ecbaaf33bd751a1ac728d45e6c61296cdc3c01233561f41db66cce314adb310e3be8250c46f06dceea3a7fa1348057e2f6556ad6b1318a024a838f21af1fde048977eb48f59ffd4924ca1c60902e52f0a089bc76897040e082f937763848645e0705");
        NSLog(@" Actual  unboxed  packet: %@", [tmpResult toHexString]);






    }
    return 0;
}
