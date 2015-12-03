#define TwistedEdwardsCurve_version 20150203


@interface TwistedEdwardsCurve : NSObject <NSMutableCopying> {
    FGInt *a, *d, *p; //, *curveOrder;
}
@property (assign, readwrite) FGInt *a, *d, *p;
@end





@interface TECPoint : NSObject <NSMutableCopying> {
    FGInt *x, *y, *projectiveZ, *extendedT; 
    TwistedEdwardsCurve *tec;
}
@property (assign, readwrite) FGInt *x, *y, *projectiveZ, *extendedT;
@property (retain, readwrite) TwistedEdwardsCurve *tec;

-(id) initEd25519BasePoint;
-(id) initEd25519BasePointWithoutCurve;
-(id) initFromCompressed25519NSDataWithoutCurve: (NSData *) compressedPoint;
-(NSData *) to25519NSData;
-(void) makeProjective;
-(void) makeProjective25519;
-(void) makeAffine;
-(void) makeAffine25519;
+(TECPoint *) add: (TECPoint *) tecPoint kTimes: (FGInt *) kTimes;
+(TECPoint *) addEd25519: (TECPoint *) tecPoint kTimes: (FGInt *) kTimes;
+(TECPoint *) add: (TECPoint *) tecPoint1 k1Times: (FGInt *) k1FGInt and: (TECPoint *) tecPoint2 k2Times: (FGInt *) k2FGInt;
+(TECPoint *) addEd25519: (TECPoint *) tecPoint1 k1Times: (FGInt *) k1FGInt and: (TECPoint *) tecPoint2 k2Times: (FGInt *) k2FGInt;

@end
