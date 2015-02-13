#import "FGInt.h"
#import "TwistedEdwardsCurve.h"
#import <Security/SecRandom.h>



@implementation TwistedEdwardsCurve
@synthesize a;
@synthesize d;
@synthesize p;
// @synthesize curveOrder;


-(id) init {
    if ((self = [super init])) {
        a = nil;
        d = nil;
        p = nil;
        // curveOrder = nil;
    }
    return self;
}

-(id) initAsEd25519 {
    if ((self = [super init])) {
        a = [[FGInt alloc] initWithNegativeFGIntBase: 1];
        d = [[FGInt alloc] initWithNZeroes: 8];
        FGIntBase* numberArray = [[d number] mutableBytes];
        numberArray[0] = 324630691u; numberArray[1] = 1978355146u; numberArray[2] = 1094834347u; numberArray[3] = 7342669u; 
        numberArray[4] = 2004478104u; numberArray[5] = 2361868409u; numberArray[6] = 728759923u; numberArray[7] = 1375956206u; 
        p = [[FGInt alloc] initAsP25519];
        // curveOrder = nil;
    }
    return self;
}

-(void) dealloc {
    if (a != nil) {
        [a release];
    }
    if (d != nil) {
        [d release];
    }
    if (p != nil) {
        [p release];
    }
    // if (curveOrder != nil) {
    //     [curveOrder release];
    // }
    [super dealloc];
}


-(id) mutableCopyWithZone: (NSZone *) zone {
    TwistedEdwardsCurve *newTEC = [[TwistedEdwardsCurve allocWithZone: zone] init];
    [newTEC setA: [a mutableCopy]];
    [newTEC setD: [d mutableCopy]];
    [newTEC setP: [p mutableCopy]];
    // [newTEC setCurveOrder: [curveOrder mutableCopy]];
    return newTEC;
}


@end





@implementation TECPoint
@synthesize x;
@synthesize y;
@synthesize projectiveZ;
@synthesize extendedT;
// @synthesize pointOrder;
@synthesize tec;


-(id) init {
    if ((self = [super init])) {
        x = nil;
        y = nil;
        projectiveZ = nil;
        extendedT = nil;
        // pointOrder = nil;
        tec = nil;
    }
    return self;
}

-(id) initAsInfinity {
    if ((self = [super init])) {
        x = [[FGInt alloc] initAsZero];
        y = [[FGInt alloc] initWithFGIntBase: 1];
        projectiveZ = nil;
        extendedT = nil;
        // pointOrder = nil;
        tec = nil;
    }
    return self;
}
-(id) initAsInfinityWithTEC: (TwistedEdwardsCurve *) twistedEdwardsCurve {
    if ((self = [super init])) {
        x = [[FGInt alloc] initAsZero];
        y = [[FGInt alloc] initWithFGIntBase: 1];
        projectiveZ = nil;
        extendedT = nil;
        // pointOrder = nil;
        tec = twistedEdwardsCurve;
    }
    return self;
}


-(id) initEd25519BasePoint {
    if ((self = [super init])) {
        x = [[FGInt alloc] initWithNZeroes: 8];
        FGIntBase* numberArray = [[x number] mutableBytes];
        numberArray[0] = 2401621274u; numberArray[1] = 3377868128u; numberArray[2] = 2502272946u; numberArray[3] = 1764542304u; 
        numberArray[4] = 4258716764u; numberArray[5] = 3232031281u; numberArray[6] = 3446559742u; numberArray[7] = 560543443u; 
        y = [[FGInt alloc] initWithNZeroes: 8];
        numberArray = [[y number] mutableBytes];
        numberArray[0] = 1717986904u; numberArray[1] = 1717986918u; numberArray[2] = 1717986918u; numberArray[3] = 1717986918u; 
        numberArray[4] = 1717986918u; numberArray[5] = 1717986918u; numberArray[6] = 1717986918u; numberArray[7] = 1717986918u; 
        projectiveZ = nil;
        extendedT = nil;
        // pointOrder = nil;
        tec = [[TwistedEdwardsCurve alloc] initAsEd25519];
    }
    return self;
}
-(id) initEd25519BasePointWithoutCurve {
    if ((self = [super init])) {
        x = [[FGInt alloc] initWithNZeroes: 8];
        FGIntBase* numberArray = [[x number] mutableBytes];
        numberArray[0] = 2401621274u; numberArray[1] = 3377868128u; numberArray[2] = 2502272946u; numberArray[3] = 1764542304u; 
        numberArray[4] = 4258716764u; numberArray[5] = 3232031281u; numberArray[6] = 3446559742u; numberArray[7] = 560543443u; 
        y = [[FGInt alloc] initWithNZeroes: 8];
        numberArray = [[y number] mutableBytes];
        numberArray[0] = 1717986904u; numberArray[1] = 1717986918u; numberArray[2] = 1717986918u; numberArray[3] = 1717986918u; 
        numberArray[4] = 1717986918u; numberArray[5] = 1717986918u; numberArray[6] = 1717986918u; numberArray[7] = 1717986918u; 
        projectiveZ = nil;
        extendedT = nil;
        // pointOrder = nil;
        tec = nil;
    }
    return self;
}

-(id) initFromCompressed25519NSDataWithoutCurve: (NSData *) compressedPoint {
	if ([compressedPoint length] != 32) {
		return nil;
	}
    if ((self = [super init])) {
    	y = [[FGInt alloc] initWithNSData: compressedPoint];
    	FGIntBase* numberArray = [[y number] mutableBytes];
    	FGIntBase signBit = 0;
    	if ([[y number] length]/4 == 8) {
    		signBit = numberArray[7] >> 31;
    		numberArray[7] = numberArray[7] - (signBit << 31);
    	}
        FGInt *d = [[FGInt alloc] initWithNZeroes: 8];
        numberArray = [[d number] mutableBytes];
        numberArray[0] = 324630691u; numberArray[1] = 1978355146u; numberArray[2] = 1094834347u; numberArray[3] = 7342669u; 
        numberArray[4] = 2004478104u; numberArray[5] = 2361868409u; numberArray[6] = 728759923u; numberArray[7] = 1375956206u; 
        FGInt *ySquare = [FGInt squareModulo25638: y];
        FGInt *u = [ySquare mutableCopy];
        [u decrement];
        FGInt *v = [FGInt multiplyModulo25638: ySquare and: d];
        [v increment];
        [d release];
        [ySquare release];

        FGInt *q58 = [[FGInt alloc] initAsP25519];
        FGInt *tmpFGInt = [[FGInt alloc] initWithFGIntBase: 5];
        [q58 subtractWith: tmpFGInt];
        [tmpFGInt release];
        [q58 shiftRightBy: 3];

        tmpFGInt = [FGInt squareModulo25638: v];
        FGInt *vCubed = [FGInt multiplyModulo25638: v and: tmpFGInt];
        FGInt *v7 = [FGInt squareModulo25638: tmpFGInt];
        [tmpFGInt release];
        tmpFGInt = v7;
        v7 = [FGInt multiplyModulo25638: tmpFGInt and: vCubed];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiplyModulo25638: v7 and: u];
        [v7 release];
        v7 = [FGInt raise: tmpFGInt toThePowerMod25519: q58];
        [q58 release];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiplyModulo25638: vCubed and: v7];
        [v7 release];
        [vCubed release];
        FGInt *beta = [FGInt multiplyModulo25638: tmpFGInt and: u];
        [tmpFGInt release];
        tmpFGInt = [FGInt squareModulo25638: beta];
        FGInt *t1 = [FGInt multiplyModulo25638: tmpFGInt and: v];
        [v release];
        [tmpFGInt release];
        [u setSign: NO];
        [u mod25519];
        [t1 mod25519];
        if ([FGInt compareAbsoluteValueOf: t1 with: u] == equal) {
	        FGInt *sqrtMinusOne = [[FGInt alloc] initWithNZeroes: 8];
	        numberArray = [[sqrtMinusOne number] mutableBytes];
	        numberArray[0] = 1242472624u; numberArray[1] = 3303938855u; numberArray[2] = 2905597048u; numberArray[3] = 792926214u; 
	        numberArray[4] = 1039914919u; numberArray[5] = 726466713u; numberArray[6] = 1338105611u; numberArray[7] = 730014848u; 
        	tmpFGInt = [FGInt multiplyModulo25638: beta and: sqrtMinusOne];
        	[beta release];
        	beta = tmpFGInt;
        }
        [t1 release];
        [u release];

		
    	[beta mod25519];
    	numberArray = [[beta number] mutableBytes];
    	if ((numberArray[0] % 2) != signBit) {
    		[beta setSign: NO];
    		[beta mod25519];
    	}
    	x = beta;

        projectiveZ = nil;
        extendedT = nil;
        // pointOrder = nil;
        tec = nil;
    }
    return self;
}

-(void) dealloc {
    if (x != nil) {
        [x release];
    }
    if (y != nil) {
        [y release];
    }
    if (projectiveZ != nil) {
        [projectiveZ release];
    } 
    if (extendedT != nil) {
        [extendedT release];
    } 
    // if (pointOrder != nil) {
    //     [pointOrder release];
    // }
    if (tec != nil) {
        [tec release];
    }
    [super dealloc];
}



-(id) mutableCopyWithZone: (NSZone *) zone {
    TECPoint *newTECPoint = [[TECPoint allocWithZone: zone] init];
    [newTECPoint setX: [x mutableCopy]];
    [newTECPoint setY: [y mutableCopy]];
    if (projectiveZ != nil) {
        [newTECPoint setProjectiveZ: [projectiveZ mutableCopy]];
    } else {
        [newTECPoint setProjectiveZ: nil];
    }
    if (extendedT != nil) {
        [newTECPoint setExtendedT: [extendedT mutableCopy]];
    } else {
        [newTECPoint setExtendedT: nil];
    }
    // if (pointOrder) {
    //     [newTECPoint setPointOrder: [pointOrder mutableCopy]];
    // } else {
    //     [newTECPoint setPointOrder: nil];
    // }
    if (tec) {
        [newTECPoint setTec: tec];
    } else {
        [newTECPoint setTec: nil];
    }
    return newTECPoint;
}


-(NSData *) to25519NSData {
	FGIntBase* numberArray = [[x number] mutableBytes];
	FGIntBase signBit = numberArray[0] % 2;
	NSMutableData *result = [[y number] mutableCopy];
	[result setLength: 32];
	numberArray = [result mutableBytes];
	numberArray[7] = numberArray[7] | (signBit << 31);
	return result;
}


-(void) makeProjective {
    projectiveZ = [[FGInt alloc] initWithFGIntBase: 1];
    FGInt *tmpFGInt = [FGInt multiply: x and: y];
    extendedT = [FGInt mod: tmpFGInt by: [tec p]];
    [tmpFGInt release];
}
-(void) makeProjective25519 {
    projectiveZ = [[FGInt alloc] initWithFGIntBase: 1];
    extendedT = [FGInt multiplyModulo25638: x and: y];
}
-(void) makeAffine {
    FGInt  *tmpFGInt, *zInv = [FGInt invert: projectiveZ moduloPrime: [tec p]];
    tmpFGInt = [FGInt multiply: y and: zInv];
    [y release];
    y = [FGInt mod: tmpFGInt by: [tec p]];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: x and: zInv];
    [x release];
    x = [FGInt mod: tmpFGInt by: [tec p]];
    [tmpFGInt release];
    [projectiveZ release];
    projectiveZ = nil;
    [extendedT release];
    extendedT = nil;
}
-(void) makeAffine25519 {
	FGInt *p25519 = [[FGInt alloc] initAsP25519];
    FGInt  *tmpFGInt, *zInv = [FGInt invert: projectiveZ moduloPrime: p25519];
    tmpFGInt = [FGInt multiply: y and: zInv];
    [y release];
    [tmpFGInt mod25519];
    y = tmpFGInt;

    tmpFGInt = [FGInt multiply: x and: zInv];
    [x release];
    [tmpFGInt mod25519];
    x = tmpFGInt;
    [projectiveZ release];
    projectiveZ = nil;
    [extendedT release];
    extendedT = nil;
    [p25519 release];
}



+(TECPoint *) projectiveDouble: (TECPoint *) tecPoint {
	FGInt *pFGInt = [[tecPoint tec] p];
	FGInt *tmpFGInt = [FGInt square: [tecPoint x]];
	FGInt *aFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	tmpFGInt = [FGInt square: [tecPoint y]];
	FGInt *bFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	tmpFGInt = [FGInt square: [tecPoint projectiveZ]];
	[tmpFGInt shiftLeft];
	FGInt *cFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	tmpFGInt = [FGInt multiply: [[tecPoint tec] a] and: aFGInt];
	FGInt *dFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	FGInt *eFGInt = [FGInt add: [tecPoint x] and: [tecPoint y]];
	tmpFGInt = [FGInt square: eFGInt];
	[eFGInt release];
	eFGInt = [FGInt subtract: tmpFGInt and: aFGInt];
	[aFGInt release];
	[tmpFGInt release];
	tmpFGInt = [FGInt subtract: eFGInt and: bFGInt];
	[eFGInt release];
	eFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	FGInt *gFGInt = [FGInt add: dFGInt and: bFGInt];
	FGInt *fFGInt = [FGInt subtract: gFGInt and: cFGInt];
	[cFGInt release];
	FGInt *hFGInt = [FGInt subtract: dFGInt and: bFGInt];
	[dFGInt release];
	[bFGInt release];

	TECPoint *result = [[TECPoint alloc] init];
	tmpFGInt = [FGInt multiply: eFGInt and: fFGInt];
	[result setX: [FGInt mod: tmpFGInt by: pFGInt]];
	[tmpFGInt release];
	tmpFGInt = [FGInt multiply: gFGInt and: hFGInt];
	[result setY: [FGInt mod: tmpFGInt by: pFGInt]];
	[tmpFGInt release];
	tmpFGInt = [FGInt multiply: eFGInt and: hFGInt];
	[result setExtendedT: [FGInt mod: tmpFGInt by: pFGInt]];
	[tmpFGInt release];
	tmpFGInt = [FGInt multiply: gFGInt and: fFGInt];
	[result setProjectiveZ: [FGInt mod: tmpFGInt by: pFGInt]];
	[tmpFGInt release];
	[eFGInt release];
	[fFGInt release];
	[gFGInt release];
	[hFGInt release];

	[result setTec: [tecPoint tec]];

	return result;
}


+(TECPoint *) projectiveAdd: (TECPoint *) tecPoint1 and: (TECPoint *) tecPoint2 {
	FGInt *pFGInt = [[tecPoint1 tec] p];
	FGInt *tmpFGInt = [FGInt multiply: [tecPoint1 x] and: [tecPoint2 x]];
	FGInt *aFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	tmpFGInt = [FGInt multiply: [tecPoint1 y] and: [tecPoint2 y]];
	FGInt *bFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	FGInt *cFGInt = [FGInt multiply: [tecPoint1 extendedT] and: [tecPoint2 extendedT]];
	tmpFGInt = [FGInt multiply: cFGInt and: [[tecPoint1 tec] d]];
	[cFGInt release];
	cFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	tmpFGInt = [FGInt multiply: [tecPoint1 projectiveZ] and: [tecPoint2 projectiveZ]];
	FGInt *dFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	FGInt *eFGInt = [FGInt add: [tecPoint1 x] and: [tecPoint1 y]];
	FGInt *fFGInt = [FGInt add: [tecPoint2 x] and: [tecPoint2 y]];
	tmpFGInt = [FGInt multiply: eFGInt and: fFGInt];
	[eFGInt release];
	[fFGInt release];
	eFGInt = [FGInt subtract: tmpFGInt and: aFGInt];
	tmpFGInt = [FGInt subtract: eFGInt and: bFGInt];
	[eFGInt release];
	eFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	FGInt *hFGInt = [FGInt multiply: aFGInt and: [[tecPoint1 tec] a]];
	tmpFGInt = [FGInt subtract: bFGInt and: hFGInt];
	[hFGInt release];
	hFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	[tmpFGInt release];
	fFGInt = [FGInt subtract: dFGInt and: cFGInt];
	FGInt *gFGInt = [FGInt add: dFGInt and: cFGInt];
	[aFGInt release];
	[bFGInt release];
	[cFGInt release];
	[dFGInt release];

	TECPoint *result = [[TECPoint alloc] init];
	tmpFGInt = [FGInt multiply: eFGInt and: fFGInt];
	[result setX: [FGInt mod: tmpFGInt by: pFGInt]];
	[tmpFGInt release];
	tmpFGInt = [FGInt multiply: gFGInt and: hFGInt];
	[result setY: [FGInt mod: tmpFGInt by: pFGInt]];
	[tmpFGInt release];
	tmpFGInt = [FGInt multiply: eFGInt and: hFGInt];
	[result setExtendedT: [FGInt mod: tmpFGInt by: pFGInt]];
	[tmpFGInt release];
	tmpFGInt = [FGInt multiply: gFGInt and: fFGInt];
	[result setProjectiveZ: [FGInt mod: tmpFGInt by: pFGInt]];
	[tmpFGInt release];
	[eFGInt release];
	[fFGInt release];
	[gFGInt release];
	[hFGInt release];

	[result setTec: [tecPoint1 tec]];

	return result;
}




+(TECPoint *) projectiveDoubleEd25519: (TECPoint *) tecPoint {
	FGInt *aFGInt = [FGInt squareModulo25638: [tecPoint x]];
	FGInt *bFGInt = [FGInt squareModulo25638: [tecPoint y]];
	FGInt *cFGInt = [FGInt squareModulo25638: [tecPoint projectiveZ]];
	// [tmpFGInt shiftLeft];
	// FGInt *cFGInt = [FGInt mod: tmpFGInt by: pFGInt];
	// [tmpFGInt release];

	// FGInt *dFGInt = [FGInt multiplyModulo25638: [[tecPoint tec] a] and: aFGInt];

	FGInt *tmpFGInt = [FGInt addModulo25638: [tecPoint x] and: [tecPoint y]];
	FGInt *eFGInt = [FGInt squareModulo25638: tmpFGInt];
	[tmpFGInt release];
	tmpFGInt = [FGInt subtractModulo25638: eFGInt and: aFGInt];
	// [aFGInt release];
	[eFGInt release];
	// [tmpFGInt release];
	eFGInt = [FGInt subtractModulo25638: tmpFGInt and: bFGInt];
	[tmpFGInt release];	

	FGInt *gFGInt = [FGInt subtractModulo25638: bFGInt and: aFGInt];
	tmpFGInt = [FGInt subtractModulo25638: gFGInt and: cFGInt];
	FGInt *fFGInt = [FGInt subtractModulo25638: tmpFGInt and: cFGInt];
	[tmpFGInt release];
	[cFGInt release];
	FGInt *zero = [[FGInt alloc] initAsZero];
	tmpFGInt = [FGInt subtractModulo25638: zero and: aFGInt];
	[zero release];
	[aFGInt release];
	FGInt *hFGInt = [FGInt subtractModulo25638: tmpFGInt and: bFGInt];
	[tmpFGInt release];
	// [dFGInt release];
	[bFGInt release];

	TECPoint *result = [[TECPoint alloc] init];
	[result setX: [FGInt multiplyModulo25638: eFGInt and: fFGInt]];
	[result setY: [FGInt multiplyModulo25638: gFGInt and: hFGInt]];
	[result setExtendedT: [FGInt multiplyModulo25638: eFGInt and: hFGInt]];
	[result setProjectiveZ: [FGInt multiplyModulo25638: gFGInt and: fFGInt]];
	[eFGInt release];
	[fFGInt release];
	[gFGInt release];
	[hFGInt release];

	return result;
}


+(TECPoint *) projectiveAddEd25519: (TECPoint *) tecPoint1 and: (TECPoint *) tecPoint2 withD: (FGInt *) d {
	FGInt *aFGInt = [FGInt multiplyModulo25638: [tecPoint1 x] and: [tecPoint2 x]];
	FGInt *bFGInt = [FGInt multiplyModulo25638: [tecPoint1 y] and: [tecPoint2 y]];
	FGInt *tmpFGInt = [FGInt multiplyModulo25638: [tecPoint1 extendedT] and: [tecPoint2 extendedT]];
	FGInt *cFGInt = [FGInt multiplyModulo25638: tmpFGInt and: d];
	[tmpFGInt release];
	FGInt *dFGInt = [FGInt multiplyModulo25638: [tecPoint1 projectiveZ] and: [tecPoint2 projectiveZ]];
	FGInt *eFGInt = [FGInt addModulo25638: [tecPoint1 x] and: [tecPoint1 y]];
	FGInt *fFGInt = [FGInt addModulo25638: [tecPoint2 x] and: [tecPoint2 y]];
	tmpFGInt = [FGInt multiplyModulo25638: eFGInt and: fFGInt];
	[eFGInt release];
	[fFGInt release];
	fFGInt = [FGInt subtractModulo25638: tmpFGInt and: aFGInt];
	[tmpFGInt release];
	eFGInt = [FGInt subtractModulo25638: fFGInt and: bFGInt];
	[fFGInt release];
	FGInt *hFGInt = [FGInt addModulo25638: aFGInt and: bFGInt];
	fFGInt = [FGInt subtractModulo25638: dFGInt and: cFGInt];
	FGInt *gFGInt = [FGInt addModulo25638: dFGInt and: cFGInt];
	[aFGInt release];
	[bFGInt release];
	[cFGInt release];
	[dFGInt release];

	TECPoint *result = [[TECPoint alloc] init];
	[result setX: [FGInt multiplyModulo25638: eFGInt and: fFGInt]];
	[result setY: [FGInt multiplyModulo25638: gFGInt and: hFGInt]];
	[result setExtendedT: [FGInt multiplyModulo25638: eFGInt and: hFGInt]];
	[result setProjectiveZ: [FGInt multiplyModulo25638: gFGInt and: fFGInt]];
	[eFGInt release];
	[fFGInt release];
	[gFGInt release];
	[hFGInt release];

	return result;
}




+(TECPoint *) add: (TECPoint *) tecPoint kTimes: (FGInt *) kTimes {
    TECPoint *dbl, *add;
   	TECPoint *tecPoint1 = [[TECPoint alloc] initAsInfinity], *tecPoint2 = [tecPoint mutableCopy];
   	[tecPoint1 setTec: [tecPoint2 tec]];
   	[tecPoint1 makeProjective]; 
   	[tecPoint2 makeProjective];

    FGIntOverflow kLength = [[kTimes number] length]/4;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kTimes number] mutableBytes];
    tmp = kFGIntNumber[kLength - 1];
    int j = 31;
    while ((tmp & (1 << j)) == 0) {
        --j;
    }
    while (j >= 0) {
        if ((tmp & (1 << j)) == 0) {
        	dbl = [TECPoint projectiveDouble: tecPoint1];
        	add = [TECPoint projectiveAdd: tecPoint1 and: tecPoint2];
        	[tecPoint1 release];
        	tecPoint1 = dbl;
        	[tecPoint2 release];
        	tecPoint2 = add;
        } else {
        	dbl = [TECPoint projectiveDouble: tecPoint2];
        	add = [TECPoint projectiveAdd: tecPoint1 and: tecPoint2];
        	[tecPoint1 release];
        	tecPoint1 = add;
        	[tecPoint2 release];
        	tecPoint2 = dbl;
        }
        --j;
    }
   for( FGIntIndex i = kLength - 2; i >= 0; i-- ) {
        tmp = kFGIntNumber[i];
        for( j = 31; j >= 0; --j ) {
	        if ((tmp & (1 << j)) == 0) {
	        	dbl = [TECPoint projectiveDouble: tecPoint1];
	        	add = [TECPoint projectiveAdd: tecPoint1 and: tecPoint2];
	        	[tecPoint1 release];
	        	tecPoint1 = dbl;
	        	[tecPoint2 release];
	        	tecPoint2 = add;
	        } else {
	        	dbl = [TECPoint projectiveDouble: tecPoint2];
	        	add = [TECPoint projectiveAdd: tecPoint1 and: tecPoint2];
	        	[tecPoint1 release];
	        	tecPoint1 = add;
	        	[tecPoint2 release];
	        	tecPoint2 = dbl;
	        }
        }
    }
    [tecPoint2 release];

    [tecPoint1 makeAffine];
    return tecPoint1;
}



+(TECPoint *) addEd25519: (TECPoint *) tecPoint kTimes: (FGInt *) kTimes {
    TECPoint *dbl, *add;
   	TECPoint *tecPoint1 = [[TECPoint alloc] initAsInfinity], *tecPoint2 = [tecPoint mutableCopy];
   	// [tecPoint1 setTec: [tecPoint2 tec]];

   	[tecPoint1 makeProjective25519]; 
   	[tecPoint2 makeProjective25519];

    FGInt *d = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* numberArray = [[d number] mutableBytes];
    numberArray[0] = 324630691u; numberArray[1] = 1978355146u; numberArray[2] = 1094834347u; numberArray[3] = 7342669u; 
    numberArray[4] = 2004478104u; numberArray[5] = 2361868409u; numberArray[6] = 728759923u; numberArray[7] = 1375956206u; 

    FGIntOverflow kLength = [[kTimes number] length]/4;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kTimes number] mutableBytes];
    tmp = kFGIntNumber[kLength - 1];
    int j = 31;
    while ((tmp & (1 << j)) == 0) {
        --j;
    }
    while (j >= 0) {
        if ((tmp & (1 << j)) == 0) {
        	dbl = [TECPoint projectiveDoubleEd25519: tecPoint1];
        	add = [TECPoint projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];
        	[tecPoint1 release];
        	tecPoint1 = dbl;
        	[tecPoint2 release];
        	tecPoint2 = add;
        } else {
        	dbl = [TECPoint projectiveDoubleEd25519: tecPoint2];
        	add = [TECPoint projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];
        	[tecPoint1 release];
        	tecPoint1 = add;
        	[tecPoint2 release];
        	tecPoint2 = dbl;
        }
        --j;
    }
   for( FGIntIndex i = kLength - 2; i >= 0; i-- ) {
        tmp = kFGIntNumber[i];
        for( j = 31; j >= 0; --j ) {
	        if ((tmp & (1 << j)) == 0) {
	        	dbl = [TECPoint projectiveDoubleEd25519: tecPoint1];
	        	add = [TECPoint projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];
	        	[tecPoint1 release];
	        	tecPoint1 = dbl;
	        	[tecPoint2 release];
	        	tecPoint2 = add;
	        } else {
	        	dbl = [TECPoint projectiveDoubleEd25519: tecPoint2];
	        	add = [TECPoint projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];
	        	[tecPoint1 release];
	        	tecPoint1 = add;
	        	[tecPoint2 release];
	        	tecPoint2 = dbl;
	        }
        }
    }
    [tecPoint2 release];
    [d release];

    [tecPoint1 makeAffine25519];

    return tecPoint1;
}


+(TECPoint *) add: (TECPoint *) tecPoint1 k1Times: (FGInt *) k1FGInt and: (TECPoint *) tecPoint2 k2Times: (FGInt *) k2FGInt {
    if ([[k2FGInt number] length] > [[k1FGInt number] length]) {
        return [TECPoint add: tecPoint2 k1Times: k2FGInt and: tecPoint1 k2Times: k1FGInt];
    }

    TECPoint *result = [[TECPoint alloc] initAsInfinityWithTEC: [tecPoint1 tec]], *tmpECPoint, *tmpECPoint1;
    FGIntOverflow k1Length = [[k1FGInt number] length]/4, k2Length = [[k2FGInt number] length]/4, i;
    FGIntBase* k1FGIntNumber = [[k1FGInt number] mutableBytes];
    FGIntBase* k2FGIntNumber = [[k2FGInt number] mutableBytes];
    FGIntBase k1Base, k2Base;

    [result makeProjective];
    [tecPoint1 makeProjective];
    [tecPoint2 makeProjective];
    TECPoint *sum = [TECPoint projectiveAdd: tecPoint1 and: tecPoint2];

    for( i = 0; i < k1Length; ++i ) {
        k1Base = k1FGIntNumber[k1Length - i - 1];
        if (k2Length > k1Length - i - 1) {
            k2Base = k2FGIntNumber[k1Length - i - 1];
        } else {
            k2Base = 0;
        }
        for( int j = 31; j >= 0; --j ) {
            tmpECPoint = [TECPoint projectiveDouble: result];
            [result release];
            result = tmpECPoint;
            if ((((k1Base >> j) % 2) == 1) && (((k2Base >> j) % 2) == 1)) {
                tmpECPoint = [TECPoint projectiveAdd: result and: sum];
                [result release];
                result = tmpECPoint;
            } else if (((k1Base >> j) % 2) == 1) {
                tmpECPoint = [TECPoint projectiveAdd: result and: tecPoint1];
                [result release];
                result = tmpECPoint;
            } else if (((k2Base >> j) % 2) == 1) {
                tmpECPoint = [TECPoint projectiveAdd: result and: tecPoint2];
                [result release];
                result = tmpECPoint;
            }
        }
    }
    [sum release];

    [[tecPoint1 projectiveZ] release];
    [[tecPoint1 extendedT] release];
    [[tecPoint2 projectiveZ] release];
    [[tecPoint2 extendedT] release];
    [tecPoint1 setProjectiveZ: nil];
    [tecPoint2 setProjectiveZ: nil];
    [tecPoint1 setExtendedT: nil];
    [tecPoint2 setExtendedT: nil];
    [result makeAffine];

    return result;
}


+(TECPoint *) addEd25519: (TECPoint *) tecPoint1 k1Times: (FGInt *) k1FGInt and: (TECPoint *) tecPoint2 k2Times: (FGInt *) k2FGInt {
    if ([[k2FGInt number] length] > [[k1FGInt number] length]) {
        return [TECPoint addEd25519: tecPoint2 k1Times: k2FGInt and: tecPoint1 k2Times: k1FGInt];
    }
        
    FGInt *d = [[FGInt alloc] initWithNZeroes: 8];
    FGIntBase* numberArray = [[d number] mutableBytes];
    numberArray[0] = 324630691u; numberArray[1] = 1978355146u; numberArray[2] = 1094834347u; numberArray[3] = 7342669u; 
    numberArray[4] = 2004478104u; numberArray[5] = 2361868409u; numberArray[6] = 728759923u; numberArray[7] = 1375956206u; 

    TECPoint *result = [[TECPoint alloc] initAsInfinity], *tmpECPoint, *tmpECPoint1;
    FGIntOverflow k1Length = [[k1FGInt number] length]/4, k2Length = [[k2FGInt number] length]/4, i;
    FGIntBase* k1FGIntNumber = [[k1FGInt number] mutableBytes];
    FGIntBase* k2FGIntNumber = [[k2FGInt number] mutableBytes];
    FGIntBase k1Base, k2Base;

    [result makeProjective25519];
    [tecPoint1 makeProjective25519];
    [tecPoint2 makeProjective25519];
    TECPoint *sum = [TECPoint projectiveAddEd25519: tecPoint1 and: tecPoint2 withD: d];

    for( i = 0; i < k1Length; ++i ) {
        k1Base = k1FGIntNumber[k1Length - i - 1];
        if (k2Length > k1Length - i - 1) {
            k2Base = k2FGIntNumber[k1Length - i - 1];
        } else {
            k2Base = 0;
        }
        for( int j = 31; j >= 0; --j ) {
            tmpECPoint = [TECPoint projectiveDoubleEd25519: result];
            [result release];
            result = tmpECPoint;
            if ((((k1Base >> j) % 2) == 1) && (((k2Base >> j) % 2) == 1)) {
                tmpECPoint = [TECPoint projectiveAddEd25519: result and: sum withD: d];
                [result release];
                result = tmpECPoint;
            } else if (((k1Base >> j) % 2) == 1) {
                tmpECPoint = [TECPoint projectiveAddEd25519: result and: tecPoint1 withD: d];
                [result release];
                result = tmpECPoint;
            } else if (((k2Base >> j) % 2) == 1) {
                tmpECPoint = [TECPoint projectiveAddEd25519: result and: tecPoint2 withD: d];
                [result release];
                result = tmpECPoint;
            }
        }
    }
    [sum release];
    [d release];

    [[tecPoint1 projectiveZ] release];
    [[tecPoint1 extendedT] release];
    [[tecPoint2 projectiveZ] release];
    [[tecPoint2 extendedT] release];
    [tecPoint1 setProjectiveZ: nil];
    [tecPoint2 setProjectiveZ: nil];
    [tecPoint1 setExtendedT: nil];
    [tecPoint2 setExtendedT: nil];
    [result makeAffine25519];

    return result;
}




@end