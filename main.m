#import <Foundation/Foundation.h>
#import "FGInt.h"
#import "ECGFp.h"
#import "FGIntCryptography.h"

int main (int argc, const char * argv[]) {
    @autoreleasepool{
    		NSString *plaintextString, *pkey, *skey;
    		NSData *encryptedData, *decryptedData, *signedData;
        FGIntBase bitSize = 1024;    
    
    		NSLog(@" initializing %u bit RSA.", bitSize);
    		plaintextString = @"Prediction is very difficult, especially of the future.";
    		FGIntRSA *rsaKeys = [[FGIntRSA alloc] initWithBitLength: bitSize];
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
    		encryptedData = [rsaKeys encryptNSString: plaintextString];
    		NSLog(@"decrypting...");
    		decryptedData = [rsaKeys decryptNSData: encryptedData];
    		NSLog(@"the decrypted result is: %@",[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]);
    		NSLog(@"Signing: %@", plaintextString);
        signedData = [rsaKeys signNSString: plaintextString];
    		NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
    		NSLog(@"Verifying the signature...   Is it valid? %@ \n \n ", [rsaKeys verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
    		[rsaKeys release];
    		[encryptedData release];
    		[decryptedData release];
    		[signedData release];
    		[pkey release];
    		[skey release];

            
        
    
    		NSLog(@" initializing %u bit ElGamal.", bitSize);
    		plaintextString = @"The sooner you fall behind, the more time you'll have to catch up.";
    		FGIntElGamal *elgamalKeys = [[FGIntElGamal alloc] initWithBitLength: bitSize];
    		//FGIntElGamal *elgamalKeys = [[FGIntElGamal alloc] initWithNSData: [FGInt convertBase64ToNSData: @"AQkArWRd2GyY"]];
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
    		encryptedData = [elgamalKeys encryptNSString: plaintextString];
    		NSLog(@"decrypting...");
    		decryptedData = [elgamalKeys decryptNSData: encryptedData];
    		NSLog(@"the decrypted result is %@",[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]);
    		NSLog(@"Signing: %@", plaintextString);
        signedData = [elgamalKeys signNSString: plaintextString];
    		NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
    		NSLog(@"Verifying the signature...   Is it valid? %@ \n \n ", [elgamalKeys verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
    		[elgamalKeys release];
    		[encryptedData release];
    		[decryptedData release];
    		[signedData release];
    		[pkey release];
    		[skey release];
    
    
    
    		NSLog(@" initializing %u bit DSA.", bitSize);
    		plaintextString = @"Theory is important, at least in theory.";
    		FGIntDSA *dsaKeys = [[FGIntDSA alloc] initWithBitLength: bitSize];
    		//FGIntDSA *dsaKeys = [[FGIntDSA alloc] initWithNSData: [FGInt convertBase64ToNSData: @"AQkArWRd2GyY"]];
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
        signedData = [dsaKeys signNSString: plaintextString];
    		NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
    		NSLog(@"Verifying the signature...   Is it valid? %@ \n \n ", [dsaKeys verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
    		[dsaKeys release];
    		[signedData release];
    		[pkey release];
    		[skey release];
    
    
    
        NSLog(@" initializing %u bit GOSTDSA.", bitSize);
        plaintextString = @"2 + 2 = 5, for large values of 2.";
    		FGIntGOSTDSA *gostdsaKeys = [[FGIntGOSTDSA alloc] initWithBitLength: bitSize];
    		//FGIntGOSTDSA *gostdsaKeys = [[FGIntGOSTDSA alloc] initWithNSData: [FGInt convertBase64ToNSData: @"AQkArWRd2GyY"]];
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
        signedData = [gostdsaKeys signNSString: plaintextString];
    		NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
    		NSLog(@"Verifying the signature...   Is it valid? %@ \n \n ", [gostdsaKeys verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
    		[gostdsaKeys release];
    		[signedData release];
    		[pkey release];
    		[skey release];



        bitSize = 160;
    		plaintextString = @"Physics is like sex. Sure, it may give some practical results, but that's not why we do it.";
    		NSLog(@" initializing %u bit ECDSA.", bitSize);
        ECDSA *ecDSA = [[ECDSA alloc] initWithBitLength: bitSize];
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
        signedData = [ecDSA signNSString: plaintextString];
    		NSLog(@"The signature is: %@", [FGInt convertNSDataToBase64: signedData] );
    		NSLog(@"Verifying the signature...   Is it valid? %@ \n \n ", [ecDSA verifySignature: signedData ofPlainTextNSString: plaintextString] ? @"YES" : @"NO");
    		[ecDSA release];
    		[signedData release];
    		[pkey release];
    		[skey release];
    


    		plaintextString = @"Warp 5, engage!";
    		NSLog(@" initializing %u bit ECElGamal.", bitSize);
        ECElGamal *ecElGamal = [[ECElGamal alloc] initWithBitLength: bitSize];
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
        encryptedData = [ecElGamal encryptNSString: plaintextString];
    		decryptedData = [ecElGamal decryptNSData: encryptedData];
    		NSLog(@"the decrypted result is: %@ \n \n ",[[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding]);
    		[ecElGamal release];
    		[encryptedData release];
    		[decryptedData release];
    		[pkey release];
    		[skey release];
    }
    return 0;
}
