//#import <Foundation/Foundation.h>
//#import "FGInt.h"

#import "FGInt.h"

#define ECGFp_version 20141216


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
+(ECPoint *) add: (ECPoint *) ecPoint1 and: (ECPoint *) ecPoint2;
+(ECPoint *) add: (ECPoint *) ecPoint kTimes: (FGInt *) kFGInt;
+(ECPoint *) add: (ECPoint *) ecPoint kTimes: (FGInt *) kFGInt withStop: (BOOL *) stop;
+(ECPoint *) add: (ECPoint *) ecPoint1 k1Times: (FGInt *) k1FGInt and: (ECPoint *) ecPoint2 k2Times: (FGInt *) k2FGInt;
+(ECPoint *) add: (ECPoint *) ecPoint kTimes: (FGInt *) kFGInt withNISTprime: (tag) nistPrimeTag;
+(ECPoint *) add: (ECPoint *) ecPoint1 k1Times: (FGInt *) k1FGInt and: (ECPoint *) ecPoint2 k2Times: (FGInt *) k2FGInt withNISTprime: (tag) nistPrimeTag;
+(ECPoint *) invert: (ECPoint *) ecPoint;
+(ECPoint *) inbedNSData: (NSData *) data onEllipticCurve: (EllipticCurve *) ellipticC;
-(NSData *) extractInbeddedNSData;
-(void) findNextECPointWithStop: (BOOL *) stop;
+(ECPoint *) generateSecureCurveAndPointOfSize: (FGIntOverflow) gFpSize;


@end


