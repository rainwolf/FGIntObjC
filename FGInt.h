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

#import <Foundation/Foundation.h>

typedef unsigned int FGIntBase;
typedef unsigned long long FGIntOverflow;
typedef long long FGIntIndex;

typedef enum {error, equal, smaller, larger} tCompare;
#define FGInt_version 201411020
#define karatsubaThreshold 300 // ToBeDetermined
#define barrettThreshold 512
#define quotientKey @"quotient"
#define remainderKey @"remainder"
#define aKey @"a"
#define bKey @"b"



@interface FGInt : NSObject <NSMutableCopying> {
    NSMutableData *number;
    BOOL sign;
}

@property (assign, readwrite) BOOL sign;
@property (retain, readwrite) NSMutableData *number;

-(FGInt *) initWithNZeroes: (FGIntOverflow) n;
-(id) initWithCapacity: (FGIntOverflow) capacity;
-(id) initWithNumber: (NSMutableData *) initNumber;
-(id) initWithoutNumber;
-(void) dealloc;
// -(id) shallowCopy;
-(void) verifyAdjust;
+(void) verifyAdjustNumber: (NSMutableData *) numberData;

-(NSMutableData *) number;
-(void) setNumber: (NSMutableData *) inputNumber;

-(FGInt *) initWithBase10String: (NSString *) base10String;
-(FGInt *) initWithFGIntBase: (FGIntBase) fGIntBase;
-(FGInt *) initWithNegativeFGIntBase: (FGIntBase) fGIntBase;
-(FGInt *) initWithNSString: (NSString *) string;
-(FGInt *) initWithNSData: (NSData *) nsData;
-(NSData *) toNSData;
-(NSData *) toMPINSData;
-(NSString *) toNSString;

// +(FGIntBase) divideFGIntNumberByIntBis: (NSMutableArray *) FGIntNumber divideBy: (FGIntBase) divInt;
// //-(id) duplicate;
// -(NSMutableArray *) duplicateNumber;
-(NSString *) toBase10String;
+(tCompare) compareAbsoluteValueOf: (FGInt *) fGInt1 with: (FGInt *) fGInt2;
+(FGInt *) add: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
-(void) changeSign;
+(FGInt *) subtract: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) pencilPaperMultiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) karatsubaMultiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) multiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) pencilPaperSquare: (FGInt *) fGInt;
+(FGInt *) karatsubaSquare: (FGInt *) fGInt;
+(FGInt *) square: (FGInt *) fGInt;
+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN;
-(void) shiftLeftBy32;
-(void) shiftRightBy32;
-(void) shiftLeftBy32Times: (FGIntOverflow) n;
-(void) shiftRightBy32Times: (FGIntOverflow) n;
-(void) shiftLeft;
-(void) shiftRight;
-(void) shiftRightBy: (FGIntBase) by;
-(void) shiftLeftBy: (FGIntBase) by;
-(void) increment;
-(void) decrement;
-(void) multiplyByInt: (FGIntBase) multInt;
-(void) subtractWith: (FGInt *) fGInt;
-(void) addWith: (FGInt *) fGInt;
-(void) subtractWith: (FGInt *) fGInt multipliedByInt: (FGIntBase) multInt;
+(NSDictionary *) longDivision: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) newtonInversion: (FGInt *) fGInt withPrecision: (FGIntOverflow) precision;
+(NSDictionary *) barrettDivision: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) barrettMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) barrettMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision;
+(FGInt *) barrettModBis: (FGInt *) fGInt by: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision;
+(FGInt *) longDivisionMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) longDivisionModBis: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN barrettMod: (FGInt *) modFGInt;
+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN longDivisionMod: (FGInt *) modFGInt;
+(FGInt *) mod: (FGInt *) fGInt by: (FGInt *) modFGInt;
+(NSDictionary *) divide: (FGInt *) fGInt by: (FGInt *) divisorFGInt;
+(FGInt *) gcd: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) lcm: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
+(FGInt *) modularInverse: (FGInt *) fGInt mod: (FGInt *) modFGInt;
+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN montgomeryMod: (FGInt *) modFGInt;
+(FGInt *) leftShiftModularInverse: (FGInt *) fGInt mod: (FGInt *) modFGInt;
-(FGIntBase) modFGIntByInt: (FGIntBase) divInt;
-(void) divideByInt: (FGIntBase) divInt;
-(BOOL) trialDivision;
+(NSDictionary *) bezoutBachet: (FGInt *) fGInt1 and: (FGInt *) fGInt2;
-(BOOL) rabinMillerTest: (FGIntBase) numberOfTests;
-(BOOL) primalityTest: (FGIntBase) numberOfTests;
+(FGInt *) divide: (FGInt *) fGInt byFGIntBase: (FGIntBase) divInt;
-(int) legendreSymbolMod: (FGInt *) pFGInt;
+(FGInt *) squareRootOf: (FGInt *) fGInt mod: (FGInt *) pFGInt;
-(FGInt *) factorial;
//-(FGInt *) findNearestLargerPrime;
-(void) findNearestLargerPrime;
-(void) findNearestLargerPrimeWithRabinMillerTests: (FGIntBase) numberOfTests;
//-(FGInt *) findNearestLargerDSAPrimeWith: (FGInt *) qFGInt;
-(void) findNearestLargerDSAPrimeWith: (FGInt *) qFGInt;
-(FGInt *) isNearlyPrimeAndAtLeast: (FGIntOverflow) leastSize;


+(NSString *) convertNSDataToBase64: (NSData *) nsData;
+(NSString *) convertNSStringToBase64: (NSString *) nsString;
+(int) getBase64Index: (char) base64Char;
+(NSData *) convertBase64ToNSData: (NSString *) base64String;
+(NSString *) convertBase64ToNSString: (NSString *) base64String;
-(FGIntOverflow) bitSize;


//-(NSMutableArray *) duplicate;

@end