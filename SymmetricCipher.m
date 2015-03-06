#import "SymmetricCipher.h"
#import <CommonCrypto/CommonCryptor.h>
#import "FGInt.h"



@implementation Salsa20
@synthesize inputData;
@synthesize nonce;
@synthesize key;

/* some test vectors here https://github.com/alexwebr/salsa20/blob/master/test_vectors.128 */

static word rotateBy(word inputWord, int offSet) {
	return (inputWord << offSet) | (inputWord >> (32 - offSet));
}

static void quarterRound(word* const outputWord0, word* const outputWord1, word* const outputWord2, word* const outputWord3, word* const inputWord0, word* const inputWord1, word* const inputWord2, word* const inputWord3) {
	*outputWord1 = *inputWord1 ^ (rotateBy(*inputWord0 + *inputWord3, 7));
	*outputWord2 = *inputWord2 ^ (rotateBy(*outputWord1 + *inputWord0, 9));
	*outputWord3 = *inputWord3 ^ (rotateBy(*outputWord2 + *outputWord1, 13));
	*outputWord0 = *inputWord0 ^ (rotateBy(*outputWord3 + *outputWord2, 18));
}

static void rowRound(word* const outputWords, word* const inputWords) {
	quarterRound(&outputWords[0], &outputWords[1], &outputWords[2], &outputWords[3], &inputWords[0], &inputWords[1], &inputWords[2], &inputWords[3]);
	quarterRound(&outputWords[5], &outputWords[6], &outputWords[7], &outputWords[4], &inputWords[5], &inputWords[6], &inputWords[7], &inputWords[4]);
	quarterRound(&outputWords[10], &outputWords[11], &outputWords[8], &outputWords[9], &inputWords[10], &inputWords[11], &inputWords[8], &inputWords[9]);
	quarterRound(&outputWords[15], &outputWords[12], &outputWords[13], &outputWords[14], &inputWords[15], &inputWords[12], &inputWords[13], &inputWords[14]);
}

static void columnRound(word* const outputWords, word* const inputWords) {
	quarterRound(&outputWords[0], &outputWords[4], &outputWords[8], &outputWords[12], &inputWords[0], &inputWords[4], &inputWords[8], &inputWords[12]);
	quarterRound(&outputWords[5], &outputWords[9], &outputWords[13], &outputWords[1], &inputWords[5], &inputWords[9], &inputWords[13], &inputWords[1]);
	quarterRound(&outputWords[10], &outputWords[14], &outputWords[2], &outputWords[6], &inputWords[10], &inputWords[14], &inputWords[2], &inputWords[6]);
	quarterRound(&outputWords[15], &outputWords[3], &outputWords[7], &outputWords[11], &inputWords[15], &inputWords[3], &inputWords[7], &inputWords[11]);
}

static void doubleRound(word* outputWords, word* inputWords) {
	static word tmpWords[16];
	columnRound(tmpWords, inputWords);
	rowRound(outputWords, tmpWords);
}

static void salsa20Hash(word* const outputWords, word* const inputWords) {
	word tmpWordsIn[16];
	memcpy(tmpWordsIn, inputWords, 64);

	for ( int i = 0; i < 5; i++ ) {
		doubleRound(outputWords, tmpWordsIn);
		doubleRound(tmpWordsIn, outputWords);
	}
	for ( int i = 0; i < 16; i++ ) {
		outputWords[i] = inputWords[i] + tmpWordsIn[i];
	}
}

static void salsa20Expand256bit(unsigned char* const outputBytes, unsigned char* const keyBytes, unsigned char* const nonceBytes) {
	unsigned char tmpBytes[64] = {101,120,112,97, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 110,100,32,51, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 50,45,98,121, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 116,101,32,107};
	memcpy(&tmpBytes[4], keyBytes, 16);
	memcpy(&tmpBytes[24], nonceBytes, 16);
	memcpy(&tmpBytes[44], &keyBytes[16], 16);
	salsa20Hash((word*) outputBytes, (word*) tmpBytes);
}

static void salsa20Expand128bit(unsigned char* const outputBytes, unsigned char* const keyBytes, unsigned char* const nonceBytes) {
	unsigned char tmpBytes[64] = {101,120,112,97, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 110,100,32,49, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 54,45,98,121, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 116,101,32,107};
	memcpy(&tmpBytes[4], keyBytes, 16);
	memcpy(&tmpBytes[24], nonceBytes, 16);
	memcpy(&tmpBytes[44], keyBytes, 16);
	salsa20Hash((word*) outputBytes, (word*) tmpBytes);
}

static void salsa20EncryptDecryptOrWhatever(unsigned char* const outputBytes, unsigned char* const inputBytes, unsigned long long const length , unsigned char* const keyBytes, int const keyLength, unsigned char* const nonceBytes) {
	unsigned char nonceBytesCounter[16];
	memcpy(nonceBytesCounter, nonceBytes, 8);
	unsigned long long nonceCounter = 0;

	unsigned char salsa20kv[64];

	for ( word i = 0; i < (length >> 6); i++ ) {
		memcpy(&nonceBytesCounter[8], &nonceCounter, 8);
		if (keyLength == 32) {
			salsa20Expand256bit(salsa20kv, keyBytes, nonceBytesCounter);
		} else {
			salsa20Expand128bit(salsa20kv, keyBytes, nonceBytesCounter);
		}
		for ( int j = 0; j < 64; j++ ) {
			outputBytes[i*64 + j] = inputBytes[i*64 + j] ^ salsa20kv[j];
		}
		nonceCounter += 1;
	}
	word leftOver = (length & 63);
	if (leftOver != 0) {
		memcpy(&nonceBytesCounter[8], &nonceCounter, 8);
		if (keyLength == 32) {
			salsa20Expand256bit(salsa20kv, keyBytes, nonceBytesCounter);
		} else {
			salsa20Expand128bit(salsa20kv, keyBytes, nonceBytesCounter);
		}
		for ( int j = 0; j < leftOver; j++ ) {
			outputBytes[(length >> 6)*64 + j] = inputBytes[(length >> 6)*64 + j] ^ salsa20kv[j];
		}
	}
}



-(id) init {
    if (self = [super init]) {
    	inputData = nil;
    	nonce = nil;
    	key = nil;
    }
    return self;
}

-(id) copyWithZone: (NSZone *) zone {
	Salsa20 *new = [[Salsa20 alloc] init];
	[new setInputData: [inputData copy]];
	[new setNonce: [nonce copy]];
	[new setKey: [key copy]];
	return new;
}


-(NSData *) encrypt {
	NSAssert([self inputData], @"No input data available for Salsa20");
	NSAssert([self key], @"No key available for Salsa20");
	NSAssert([self nonce], @"No nonce available for Salsa20");
    NSAssert([[self nonce] length] == 8, @"The nonce needs to be 8 bytes long, Salsa20 received %lu bytes", [[self nonce] length]);
    NSAssert((([[self key] length] == 16) || ([[self key] length] == 32)), @"The key needs to be 16 or 32 bytes long, Salsa20 received %lu bytes", [[self key] length]);


	NSMutableData *cipherText = [[NSMutableData alloc] initWithLength: [[self inputData] length]];
	unsigned char* plainTextBytes = (unsigned char*) [[self inputData] bytes];
	unsigned char* cipherTextBytes = [cipherText mutableBytes];
	unsigned char* keyBytes = (unsigned char*) [[self key] bytes];
	unsigned char* nonceBytes = (unsigned char*) [[self nonce] bytes];

	salsa20EncryptDecryptOrWhatever(cipherTextBytes, plainTextBytes, [inputData length], keyBytes, [[self key] length], nonceBytes);

	return cipherText;
}

-(NSData *) decrypt {
	return [self encrypt];
}

@end















@implementation Poly1305
@synthesize inputData;
@synthesize nonce;
@synthesize key;
@synthesize hmac;




-(id) init {
    if (self = [super init]) {
    	inputData = nil;
    	nonce = nil;
    	key = nil;
    	hmac = nil;
    }
    return self;
}

-(id) copyWithZone: (NSZone *) zone {
	Poly1305 *new = [[Poly1305 alloc] init];
	[new setInputData: [inputData copy]];
	[new setNonce: [nonce copy]];
	[new setKey: [key copy]];
	[new setHmac: [hmac copy]];
	return new;
}

-(NSData *) hmac {
	if (hmac) {
		return hmac;
	} else {
		hmac = [self computeHMAC];
		return hmac;
	}
}


-(NSData *) clamp {
	if (!key || ([key length] != 32)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] initWithLength: 16];
	unsigned char* resultBytes = [result mutableBytes];
	[[self key] getBytes: resultBytes range: NSMakeRange(16, 16)];
	resultBytes[3] = resultBytes[3] & 15;
	resultBytes[7] = resultBytes[7] & 15;
	resultBytes[11] = resultBytes[11] & 15;
	resultBytes[15] = resultBytes[15] & 15;
	resultBytes[4] = resultBytes[4] & 252;
	resultBytes[8] = resultBytes[8] & 252;
	resultBytes[12] = resultBytes[12] & 252;

	return result;
}

-(NSData *) encrypt {
	NSLog(@" Poly1305 was not overrided with the proper encryption function!");
	NSAssert(NO, @" Poly1305 was not overrided with the proper encryption function!");
	return nil;	
}


-(NSData *) computeHMAC {
	FGInt *messageBlockFGInt = [[FGInt alloc] initWithNZeroes: 5];
	FGInt *rFGInt = [[FGInt alloc] initWithNSData: [self clamp]];
	unsigned char* messageBlockArray = [[messageBlockFGInt number] mutableBytes];
	const unsigned char* inputDataArray = [inputData bytes];
	messageBlockArray[16] = 1;
	FGIntBase length = [inputData length];

	FGInt *hmacFGInt = [[FGInt alloc] initAsZero], *tmpFGInt;
	for ( FGIntIndex i = 0; i < (length >> 4); i++ ) {
		memcpy(messageBlockArray, &inputDataArray[i << 4], 16);
		[hmacFGInt addWith: messageBlockFGInt];
		tmpFGInt = [FGInt multiplyModulo1305ish: hmacFGInt and: rFGInt];
		[hmacFGInt release];
		hmacFGInt = tmpFGInt;
	}
	if ((length & 15) != 0) {
		memset(messageBlockArray, 0, 17);
		memcpy(messageBlockArray, &inputDataArray[length - (length & 15)], (length & 15));
		messageBlockArray[(length & 15)] = 1;
		[hmacFGInt addWith: messageBlockFGInt];
		tmpFGInt = [FGInt multiplyModulo1305ish: hmacFGInt and: rFGInt];
		[hmacFGInt release];
		hmacFGInt = tmpFGInt;
	}
	[hmacFGInt mod1305];

	[rFGInt release];
	[messageBlockFGInt release];

	NSData *encryptedNonce = [self encrypt];
	FGInt *encryptedNonceFGInt = [[FGInt alloc] initWithNSData: encryptedNonce];
	[encryptedNonce release];
	[hmacFGInt addWith: encryptedNonceFGInt];
	[encryptedNonceFGInt release];

	NSMutableData *result = [[hmacFGInt number] retain];
	[result setLength: 16];
	[hmacFGInt release];

	return result;
}



-(BOOL) verifyHmac {
	BOOL result;

	NSData *computedHMAC = [self computeHMAC];
	result = [hmac isEqualToData: computedHMAC];
	[computedHMAC release];

	return result;
}



@end









@implementation Poly1305AES

/* some test vectors that passed
http://www.inconteam.com/software-development/41-encryption/55-aes-test-vectors#aes-ecb-128
http://cr.yp.to/mac/poly1305aes.py
*/

-(NSData *) encrypt {
    NSAssert([self key], @"No key available for Poly1305AES");
    NSAssert([self nonce], @"No nonce available for Poly1305AES");
    NSAssert([[self nonce] length] == 16, @"The nonce needs to be 8 bytes long, Poly1305AES received %lu bytes", [[self nonce] length]);
    NSAssert([[self key] length] == 32, @"The key needs to be 32 bytes long, Poly1305AES received %lu bytes", [[self key] length]);

    NSMutableData *cipherData = [[NSMutableData alloc] initWithLength: [nonce length]];
    size_t numBytesCrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
    0x00, //No padding
    [key bytes], kCCKeySizeAES128,
    nil,
    [nonce bytes], [nonce length], [cipherData mutableBytes], [nonce length],
    &numBytesCrypted);

    if(cryptStatus == kCCSuccess) {
        return cipherData;
    }
    return nil; 
}


@end










