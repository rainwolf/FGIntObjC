//#import <Foundation/Foundation.h>
//#import "FGInt.h"

#define ECGFp_version 20141216
#define ecBarrettThreshold 128


/*
#define quotientKey @"quotient"
#define remainderKey @"remainder"
#define aKey @"a"
#define bKey @"b"
*/


@interface EllipticCurve : NSObject <NSMutableCopying> {
    FGInt *a, *b, *p, *curveOrder;
}
@property (assign, readwrite) FGInt *a, *b, *p, *curveOrder;

-(BOOL) isSuperSingular;

@end


@interface ECPoint : NSObject <NSMutableCopying> {
    FGInt *x, *y, *pointOrder, *projectiveZ;
    BOOL infinity;
    EllipticCurve *ellipticCurve;
}
@property (assign, readwrite) FGInt *x, *y, *pointOrder, *projectiveZ;
@property (assign, readwrite) BOOL infinity;
@property (retain, readwrite) EllipticCurve *ellipticCurve;

#define vKey @"v"
#define wKey @"w"

-(id) initInfinityWithEllpiticCurve: (EllipticCurve *) ec;
-(id) initWithNSData: (NSData *) ecPointData andEllipticCurve: (EllipticCurve *) ellipticC;
-(NSData *) toNSData;
-(NSData *) toCompressedNSData;
-(void) makeProjective;
-(void) makeAffine;
+(ECPoint *) double: (ECPoint *) ecPoint;
+(ECPoint *) add: (ECPoint *) ecPoint1 and: (ECPoint *) ecPoint2;
+(ECPoint *) projectiveDouble: (ECPoint *) ecPoint aEqualsMinus3: (BOOL) is3;
+(ECPoint *) projectiveAdd: (ECPoint *) ecPoint1 and: (ECPoint *) ecPoint2 aEqualsMinus3: (BOOL) is3;
+(ECPoint *) add: (ECPoint *) ecPoint kTimes: (FGInt *) kFGInt;
+(ECPoint *) add: (ECPoint *) ecPoint1 k1Times: (FGInt *) k1FGInt and: (ECPoint *) ecPoint2 k2Times: (FGInt *) k2FGInt;
+(ECPoint *) invert: (ECPoint *) ecPoint;
+(ECPoint *) inbedNSData: (NSData *) data onEllipticCurve: (EllipticCurve *) ellipticC;
-(NSData *) extractInbeddedNSData;
-(void) findNextECPoint;
+(EllipticCurve *) constructCurveWithCMD: (unsigned char) cmd;
+(NSDictionary *) is: (FGInt *) dFGInt aCMDmod: (FGInt *) pFGInt;
+(unsigned char) findNextCMD: (unsigned char) cmd mod: (FGInt *) pFGInt;
+(NSArray *) possibleCurveOrderMod: (FGInt *) pFGInt;
+(ECPoint *) constructCurveAndPointWithOrder: (FGInt *) rFGInt andCMD: (unsigned char) cmd andCurve: (EllipticCurve *) ellipticC;
+(ECPoint *) constructCurveAndPointMod: (FGInt *) pFGInt ofLeastOrder: (FGIntOverflow) leastBitSize;
-(BOOL) verifyFieldAndCurveOrderStrength;
+(ECPoint *) generateSecureCurveAndPointOfSize: (FGIntOverflow) gFpSize;


@end


