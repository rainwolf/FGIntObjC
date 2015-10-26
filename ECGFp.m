#import "ECGFp.h"
#import <Security/SecRandom.h>



@implementation EllipticCurve
@synthesize a;
@synthesize b;
@synthesize p;
@synthesize curveOrder;


-(id)init {
    if ((self = [super init])) {
        a = nil;
        b = nil;
        p = nil;
        curveOrder = nil;
    }
    return self;
}

-(id) mutableCopyWithZone: (NSZone *) zone {
    EllipticCurve *newEC = [[EllipticCurve allocWithZone: zone] init];
    [newEC setA: [a mutableCopy]];
    [newEC setB: [b mutableCopy]];
    [newEC setP: [p mutableCopy]];
    [newEC setCurveOrder: [curveOrder mutableCopy]];
    return newEC;
}

-(void) dealloc {
    if (a != nil) {
        [a release];
    }
    if (b != nil) {
        [b release];
    }
    if (p != nil) {
        [p release];
    }
    if (curveOrder != nil) {
        [curveOrder release];
    }
    [super dealloc];
}

-(BOOL) isSuperSingular {
    FGInt *tmpFGInt, *a3, *b2;
    tmpFGInt = [FGInt square: a];
    a3 = [FGInt multiply: tmpFGInt and: a];
    [tmpFGInt release];
    [a3 shiftLeftBy: 2];
    b2 = [FGInt square: a];
    [b2 multiplyByInt: 27];
    [a3 addWith: b2];
    [b2 release];
    tmpFGInt = [FGInt mod: a3 by: p];
    [a3 release];
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1];
    BOOL result = ([FGInt compareAbsoluteValueOf: one with: tmpFGInt] == equal);
    [tmpFGInt release];
    [one release];
    return result;
}


@end










@implementation ECPoint
@synthesize x;
@synthesize y;
@synthesize projectiveZ;
@synthesize pointOrder;
@synthesize infinity;
@synthesize ellipticCurve;

-(id) init {
    if ((self = [super init])) {
        x = nil;
        y = nil;
        projectiveZ = nil;
        infinity = NO;
        pointOrder = nil;
        ellipticCurve = nil;
    }
    return self;
}

-(id) initInfinityWithEllpiticCurve: (EllipticCurve *) ec {
    if ((self = [super init])) {
        x = [[FGInt alloc] initWithFGIntBase: 0];
        y = [[FGInt alloc] initWithFGIntBase: 0];
        projectiveZ = nil;
        pointOrder = [[FGInt alloc] initWithFGIntBase: 0];
        infinity = YES;
        ellipticCurve = [ec retain];
    }
    return self;
}

-(id) mutableCopyWithZone: (NSZone *) zone {
    ECPoint *newECPoint = [[ECPoint allocWithZone: zone] init];
    [newECPoint setX: [x mutableCopy]];
    [newECPoint setY: [y mutableCopy]];
    if (projectiveZ != nil) {
        [newECPoint setProjectiveZ: [projectiveZ mutableCopy]];
    } else {
        [newECPoint setProjectiveZ: nil];
    }
    if (pointOrder) {
        [newECPoint setPointOrder: [pointOrder mutableCopy]];
    } else {
        [newECPoint setPointOrder: nil];
    }
    [newECPoint setInfinity: infinity];
    if (ellipticCurve) {
        [newECPoint setEllipticCurve: ellipticCurve];
    } else {
        [newECPoint setEllipticCurve: nil];
    }
    return newECPoint;
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
    if (pointOrder != nil) {
        [pointOrder release];
    }
    if (ellipticCurve != nil) {
        [ellipticCurve release];
    }
    [super dealloc];
}


-(id) initWithNSData: (NSData *) ecPointData andEllipticCurve: (EllipticCurve *) ellipticC {
    if (!ecPointData) {
        NSLog(@"No ecPointData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if ([ecPointData length] == 0) {
        NSLog(@"ecPointData is empty for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![ellipticC p]) {
        NSLog(@"No [ellipticC p] available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![ellipticC a]) {
        NSLog(@"No [ellipticC a] available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![ellipticC b]) {
        NSLog(@"No [ellipticC b] available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    if ([ecPointData length] == 1) {
        unsigned char aBuffer[1];
        [ecPointData getBytes: aBuffer length: 1];
        if (aBuffer[0] != 0) {
            NSLog(@"ecPointData is corrupt for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            return nil;
        }
        if ((self = [super init])) {
            x = [[FGInt alloc] initWithFGIntBase: 0];
            y = [[FGInt alloc] initWithFGIntBase: 0];
            infinity = YES;
            ellipticCurve = [ellipticC retain];
        }
        return self;
    }

    FGIntOverflow byteLength = [[ellipticC p] byteSize];

    if ([ecPointData length] == (2 * byteLength + 1)) {
        @autoreleasepool{
            NSData *tmpData = [ecPointData subdataWithRange: NSMakeRange(1, byteLength)];
            x = [[FGInt alloc] initWithBigEndianNSData: tmpData];
            tmpData = [ecPointData subdataWithRange: NSMakeRange(byteLength + 1, byteLength)];
            y = [[FGInt alloc] initWithBigEndianNSData: tmpData];
            infinity = NO;
            ellipticCurve = [ellipticC retain];
        }
        return self;
    }

    if ([ecPointData length] == (byteLength + 1)) {
        @autoreleasepool{
            NSData *tmpData = [ecPointData subdataWithRange: NSMakeRange(1, byteLength)];
            unsigned char firstByte[1]; 
            [ecPointData getBytes: firstByte range: NSMakeRange(0, 1)];
            if ((firstByte[0] < 2) || (firstByte[0] > 3)) {
                NSLog(@"Compressed byte is not valid, it is %i", firstByte[0]);
            }
            x = [[FGInt alloc] initWithBigEndianNSData: tmpData];
            FGInt *tmpFGInt = [FGInt square: x], *x3 = [FGInt multiply: x and: tmpFGInt], *ax = [FGInt multiply: x and: [ellipticC a]];
            [tmpFGInt release];
            [ax addWith: x3];
            [ax addWith: [ellipticC b]];
            [x3 release];
            x3 = [FGInt mod: ax by: [ellipticC p]];
            [ax release];
            int legendre = [x3 legendreSymbolMod: [ellipticC p]];
            if (legendre != 1) {
                NSLog(@"ecPointData is corrupt, y does not exist, Legendre symbol is %i, for %s at line %d", legendre, __PRETTY_FUNCTION__, __LINE__);
                // NSLog(@"x3 is %@", [x3 toBase10String]);
                [x3 release];
                return nil;
            }
            tmpFGInt = [FGInt squareRootOf: x3 mod: [ellipticC p]];
            [x3 release];
            FGIntBase* numberArray = [[tmpFGInt number] mutableBytes];
            if ((firstByte[0] % 2) != (numberArray[0] % 2)) {
                y = [[ellipticC p] mutableCopy];
                [y subtractWith: tmpFGInt];
                [tmpFGInt release];
            } else {
                y = tmpFGInt;
            }
            infinity = NO;
            ellipticCurve = [ellipticC retain];
        }
        return self;
    }

    NSLog(@"ecPointData is corrupt, wrong size, it should be 1, %llu or %llu, and it was %lu, for %s at line %d", byteLength + 1, 2 * byteLength + 1, [ecPointData length], __PRETTY_FUNCTION__, __LINE__);
    return nil;
}



-(void) makeProjective {
    projectiveZ = [[FGInt alloc] initWithFGIntBase: 1];
}
-(void) makeAffine {
    FGInt *zero = [[FGInt alloc] initWithFGIntBase: 0];
    if (infinity) {
        [x release];
        x = [zero mutableCopy];
        [y release];
        y = zero;
        return;
    }
    [zero release];
    FGInt  *tmpFGInt = [FGInt square: projectiveZ], *zCubed = [FGInt multiply: tmpFGInt and: projectiveZ], *z3Inv = [FGInt invert: zCubed moduloPrime: [ellipticCurve p]];
    [tmpFGInt release]; 
    [zCubed release];
    tmpFGInt = [FGInt multiply: y and: z3Inv];
    [y release];
    y = [FGInt mod: tmpFGInt by: [ellipticCurve p]];
    [tmpFGInt release];
    FGInt *tmpFGInt1 = [FGInt multiply: x and: z3Inv];
    tmpFGInt = [FGInt multiply: tmpFGInt1 and: projectiveZ];
    [tmpFGInt1 release];
    [x release];
    x = [FGInt mod: tmpFGInt by: [ellipticCurve p]];
    [projectiveZ release];
    projectiveZ = nil;
}



-(NSData *) toNSData {
    if (!x) {
        NSLog(@"No x available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!y) {
        NSLog(@"No y available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![ellipticCurve p]) {
        NSLog(@"No [ellipticCurve p] available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    
    NSData *tmpData;
    NSMutableData *result = [[NSMutableData alloc] init];
    FGIntOverflow byteLength = [[ellipticCurve p] byteSize];

    if (infinity) {
        [result setLength: 1];
        return result;
    }
    

    unsigned char aBuffer[1];
    aBuffer[0] = 4;
    [result appendBytes: aBuffer length: 1];

    tmpData = [x toBigEndianNSData];
    [result increaseLengthBy: (byteLength - [tmpData length])];
    [result appendData: tmpData];
    [tmpData release];
    
    tmpData = [y toBigEndianNSData];
    [result increaseLengthBy: (byteLength - [tmpData length])];
    [result appendData: tmpData];
    [tmpData release];
    
    return result;
}


-(NSData *) toCompressedNSData {
    if (!x) {
        NSLog(@"No x available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (!y) {
        NSLog(@"No y available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if (![ellipticCurve p]) {
        NSLog(@"No [ellipticCurve p] available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    
    NSData *tmpData;
    NSMutableData *result = [[NSMutableData alloc] init];
    FGIntOverflow byteLength = [[ellipticCurve p] byteSize];
    FGIntBase* numberArray;
    unsigned char aBuffer[1];
    aBuffer[0] = 0;

    if (infinity) {
        [result appendBytes: aBuffer length: 1];
        return result;
    }
    
    numberArray = [[y number] mutableBytes];
    aBuffer[0] = (2 + (numberArray[0] % 2));
    [result appendBytes: aBuffer length: 1];
    
    tmpData = [x toBigEndianNSData];
    [result increaseLengthBy: byteLength - [tmpData length]];
    [result appendData: tmpData];
    [tmpData release];
    
    return result;
}



+(ECPoint *) double: (ECPoint *) ecPoint {
    if ([ecPoint infinity]) {
        ECPoint *result = [ecPoint mutableCopy];
        return result;
    }
    
    FGInt *zero = [[FGInt alloc] initWithFGIntBase: 0];
    if ([FGInt compareAbsoluteValueOf: [ecPoint y] with: zero] == equal) {
        ECPoint *result = [[ECPoint alloc] init];
        [result setX: [zero mutableCopy]];
        [result setY: [zero mutableCopy]];
        [result setInfinity: YES];
        [result setEllipticCurve: [ecPoint ellipticCurve]];
        [zero release];
        return result;
    }
    [zero release];
        
    FGInt *x = [ecPoint x], *y = [ecPoint y], *p = [[ecPoint ellipticCurve] p], *lFGInt, *tmpFGInt = [FGInt square: x];
    [tmpFGInt multiplyByInt: 3];
    [tmpFGInt addWith: [[ecPoint ellipticCurve] a]];
    FGInt *tmpFGInt1 = [y mutableCopy];
    [tmpFGInt1 shiftLeft];
    FGInt *tmpFGInt2 = [FGInt invert: tmpFGInt1 moduloPrime: p];
    [tmpFGInt1 release];
    lFGInt = [FGInt multiply: tmpFGInt and: tmpFGInt2];
    [tmpFGInt release];
    [tmpFGInt2 release];
    
    tmpFGInt = [FGInt square: lFGInt];
    [tmpFGInt subtractWith: x multipliedByInt: 2];
    ECPoint *result = [[ECPoint alloc] init];
    [result setX: [FGInt mod: tmpFGInt by: p]];
    [tmpFGInt release];

    tmpFGInt1 = [FGInt subtract: x and: [result x]];
    tmpFGInt2 = [FGInt multiply: lFGInt and: tmpFGInt1];
    [lFGInt release];
    [tmpFGInt1 release];
    tmpFGInt = [FGInt subtract: tmpFGInt2 and: y];
    [tmpFGInt2 release];
    [result setY: [FGInt mod: tmpFGInt by: p]];
    [tmpFGInt release];
    
    [result setEllipticCurve: [ecPoint ellipticCurve]];

    return result;
}


+(ECPoint *) add: (ECPoint *) ecPoint1 and: (ECPoint *) ecPoint2 {
    if ([ecPoint1 infinity]) {
        ECPoint *result = [ecPoint2 mutableCopy];
        return result;
    }
    if ([ecPoint2 infinity]) {
        ECPoint *result = [ecPoint1 mutableCopy];
        return result;
    }
    
    if ([FGInt compareAbsoluteValueOf: [ecPoint1 x] with: [ecPoint2 x]] == equal) {
        if ([FGInt compareAbsoluteValueOf: [ecPoint1 y] with: [ecPoint2 y]] == equal) {
            return [ECPoint double: ecPoint1];
        }
        ECPoint *result = [[ECPoint alloc] init];
        [result setX: [[FGInt alloc] initWithFGIntBase: 0]];
        [result setY: [[FGInt alloc] initWithFGIntBase: 0]];
        [result setInfinity: YES];
        [result setEllipticCurve: [ecPoint1 ellipticCurve]];
        return result;
    }
        
    FGInt *x1 = [ecPoint1 x], *y1 = [ecPoint1 y], *x2 = [ecPoint2 x], *y2 = [ecPoint2 y], 
        *p = [[ecPoint1 ellipticCurve] p], *lFGInt, *tmpFGInt1 = [FGInt subtract: y2 and: y1], 
        *tmpFGInt2 = [FGInt subtract: x2 and: x1], 
         *tmpFGInt = [FGInt invert: tmpFGInt2 moduloPrime: p];
    [tmpFGInt2 release];
    lFGInt = [FGInt multiply: tmpFGInt1 and: tmpFGInt];
    [tmpFGInt1 release];
    [tmpFGInt release];
                

    tmpFGInt = [FGInt square: lFGInt];
    if ([FGInt compareAbsoluteValueOf: x1 with: tmpFGInt] == smaller) {
        [tmpFGInt subtractWith: x1];
    } else {
        tmpFGInt1 = [FGInt subtract: tmpFGInt and: x1];
        [tmpFGInt release];
        tmpFGInt = tmpFGInt1;
    }
    if (([FGInt compareAbsoluteValueOf: x2 with: tmpFGInt] == smaller) && [tmpFGInt sign]) {
        [tmpFGInt subtractWith: x2];
    } else {
        tmpFGInt1 = [FGInt subtract: tmpFGInt and: x2];
        [tmpFGInt release];
        tmpFGInt = tmpFGInt1;
    }
    ECPoint *result = [[ECPoint alloc] init];
    [result setX: [FGInt mod: tmpFGInt by: p]];
    [tmpFGInt release];

    tmpFGInt1 = [FGInt subtract: [ecPoint1 x] and: [result x]];
    tmpFGInt2 = [FGInt multiply: lFGInt and: tmpFGInt1];
    [lFGInt release];
    [tmpFGInt1 release];
    tmpFGInt = [FGInt subtract: tmpFGInt2 and: [ecPoint1 y]];
    [tmpFGInt2 release];
    [result setY: [FGInt mod: tmpFGInt by: p]];
    [tmpFGInt release];
    
    [result setEllipticCurve: [ecPoint1 ellipticCurve]];

    return result;
}



+(ECPoint *) projectiveDouble: (ECPoint *) ecPoint aEqualsMinus3: (BOOL) is3 {
    if ([ecPoint infinity]) {
        ECPoint *result = [ecPoint mutableCopy];
        return result;
    }
    
    FGInt *zero = [[FGInt alloc] initWithFGIntBase: 0];
    if ([FGInt compareAbsoluteValueOf: [ecPoint y] with: zero] == equal) {
        ECPoint *result = [[ECPoint alloc] init];
        [result setX: [[FGInt alloc] initWithFGIntBase: 1]];
        [result setY: [[FGInt alloc] initWithFGIntBase: 1]];
        [result setProjectiveZ: zero];
        [result setInfinity: YES];
        [result setEllipticCurve: [ecPoint ellipticCurve]];
        return result;
    }
    [zero release];
        
    FGInt *t1, *t2, *t3, *t4, *t5, *tmpFGInt, *pFGInt = [[ecPoint ellipticCurve] p];

    if (is3) {
        tmpFGInt = [FGInt square: [ecPoint projectiveZ]];
        t4 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
        t5 = [FGInt subtract: [ecPoint x] and: t4];
        [t4 addWith: [ecPoint x]];
        tmpFGInt = t4;
        t4 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: t4 and: t5];
        [t5 release];
        t5 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
        [t5 multiplyByInt: 3];
        t4 = [FGInt mod: t5 by: pFGInt];
        [t5 release];
    } else {
        tmpFGInt = [FGInt square: [ecPoint projectiveZ]];
        t1 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
        t2 = [FGInt square: t1];
        [t1 release];
        t1 = [FGInt mod: t2 by: pFGInt];
        [t2 release];
        tmpFGInt = [FGInt multiply: t1 and: [[ecPoint ellipticCurve] a]];
        [t1 release];
        t5 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
        t1 = [FGInt square: [ecPoint x]];
        t2 = [FGInt mod: t1 by: pFGInt];
        [t1 release];
        [t2 multiplyByInt: 3];
        [t2 addWith: t5];
        t4 = [FGInt mod: t2 by: pFGInt];
        [t5 release];
        [t2 release];
    }

    ECPoint *result = [[ECPoint alloc] init];
    [result setEllipticCurve: [ecPoint ellipticCurve]];

    t2 = [FGInt multiply: [ecPoint y] and: [ecPoint projectiveZ]];
    tmpFGInt = [FGInt mod: t2 by: pFGInt];
    [t2 release];
    [tmpFGInt shiftLeft];
    t3 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt square: [ecPoint y]];
    t2 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t2 and: [ecPoint x]];
    [tmpFGInt shiftLeftBy: 2];
    t5 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt square: t4];
    t1 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    [t5 shiftLeft];
    tmpFGInt = [FGInt subtract: t1 and: t5];
    [t1 release];
    t1 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    [t5 shiftRight];
    tmpFGInt = [FGInt square: t2];
    [t2 release];
    t2 = [FGInt mod: tmpFGInt by: pFGInt];
    [t2 shiftLeftBy: 3];
    [tmpFGInt release];
    tmpFGInt = [FGInt subtract: t5 and: t1];
    [t5 release];
    t5 = tmpFGInt;
    tmpFGInt = [FGInt multiply: t4 and: t5];
    t5 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt subtract: t5 and: t2];
    [t2 release];
    t2 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    [result setX: t1];
    [result setY: t2];
    [result setProjectiveZ: t3];

    return result;
}


+(ECPoint *) projectiveAdd: (ECPoint *) ecPoint1 and: (ECPoint *) ecPoint2 aEqualsMinus3: (BOOL) is3 {
    if ([ecPoint1 infinity]) {
        ECPoint *result = [ecPoint2 mutableCopy];
        return result;
    }
    if ([ecPoint2 infinity]) {
        ECPoint *result = [ecPoint1 mutableCopy];
        return result;
    }
        
    FGInt *t1, *t2, *t3, *t4, *t5, *t7, *tmpFGInt, *pFGInt = [[ecPoint1 ellipticCurve] p], *zerone = [[FGInt alloc] initWithFGIntBase: 1];
    BOOL z1isOne;
    t1 = [[ecPoint1 x] mutableCopy];
    t2 = [[ecPoint1 y] mutableCopy];
    t3 = [[ecPoint1 projectiveZ] mutableCopy];

    z1isOne = ([FGInt compareAbsoluteValueOf: zerone with: [ecPoint2 projectiveZ]] == equal);
    if (!z1isOne) {
        tmpFGInt = [FGInt square: [ecPoint2 projectiveZ]];
        t7 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: t1 and: t7];
        [t1 release];
        t1 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: [ecPoint2 projectiveZ] and: t7];
        [t7 release];
        t7 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: t2 and: t7];
        [t2 release];
        [t7 release];
        t2 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
    }

    tmpFGInt = [FGInt square: [ecPoint1 projectiveZ]];
    t7 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t7 and: [ecPoint2 x]];
    t4 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t7 and: [ecPoint1 projectiveZ]];
    [t7 release];
    t7 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t7 and: [ecPoint2 y]];
    [t7 release];
    t5 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    t4 = [FGInt subtract: t1 and: t4];
    tmpFGInt = [FGInt subtract: t2 and: t5];
    [t5 release];
    t5 = tmpFGInt;
    [zerone decrement];
    if ([FGInt compareAbsoluteValueOf: t4 with: zerone] == equal) {
        if ([FGInt compareAbsoluteValueOf: t5 with: zerone] == equal) {
            [zerone release];
            [t4 release];
            [t5 release];
            [t1 release];
            [t2 release];
            return [ECPoint projectiveDouble: ecPoint1 aEqualsMinus3: is3];
        } else {
            [zerone release];
            [t4 release];
            [t5 release];
            [t1 release];
            [t2 release];
            ECPoint *result = [[ECPoint alloc] initInfinityWithEllpiticCurve: [ecPoint1 ellipticCurve]];
            [result makeProjective];
            return result;
        }
    }
    [t1 shiftLeft];
    tmpFGInt = [FGInt subtract: t1 and: t4];
    [t1 release];
    t1 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    [t2 shiftLeft];
    tmpFGInt = [FGInt subtract: t2 and: t5];
    [t2 release];
    t2 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    if (!z1isOne) {
        tmpFGInt = [FGInt multiply: t3 and: [ecPoint2 projectiveZ]];
        [t3 release];
        t3 = [FGInt mod: tmpFGInt by: pFGInt];
        [tmpFGInt release];
    } 
    tmpFGInt = [FGInt multiply: t3 and: t4];
    [t3 release];
    t3 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt square: t4];
    t7 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t4 and: t7];
    [t4 release];
    t4 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t1 and: t7];
    [t7 release];
    t7 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    [t1 release];
    t1 = [FGInt square: t5];
    tmpFGInt = [FGInt subtract: t1 and: t7];
    [t1 release];
    t1 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    [t1 shiftLeft];
    tmpFGInt = [FGInt subtract: t7 and: t1];
    [t7 release];
    t7 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    [t1 shiftRight];
    tmpFGInt = [FGInt multiply: t5 and: t7];
    [t5 release];
    [t7 release];
    t5 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t2 and: t4];
    [t4 release];
    t4 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    [t2 release];
    tmpFGInt = [FGInt subtract: t5 and: t4];
    [t5 release];
    [t4 release];
    t2 = [FGInt mod: tmpFGInt by: pFGInt];
    [tmpFGInt release];
    FGIntBase* numberArray = [[t2 number] mutableBytes];
    if ((numberArray[0] & 1) == 0) {
        [t2 shiftRight];
    } else {
        [t2 addWith: pFGInt];
        [t2 shiftRight];
    }


    ECPoint *result = [[ECPoint alloc] init];
    [result setEllipticCurve: [ecPoint1 ellipticCurve]];
    [result setX: t1];
    [result setY: t2];
    [result setProjectiveZ: t3];
    return result;
}





+(ECPoint *) projectiveDouble: (ECPoint *) ecPoint aEqualsMinus3: (BOOL) is3 withInvertedPrime: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    if ([ecPoint infinity]) {
        ECPoint *result = [ecPoint mutableCopy];
        return result;
    }
    
    FGInt *zero = [[FGInt alloc] initWithFGIntBase: 0];
    if ([FGInt compareAbsoluteValueOf: [ecPoint y] with: zero] == equal) {
        ECPoint *result = [[ECPoint alloc] init];
        [result setX: [[FGInt alloc] initWithFGIntBase: 1]];
        [result setY: [[FGInt alloc] initWithFGIntBase: 1]];
        [result setProjectiveZ: zero];
        [result setInfinity: YES];
        [result setEllipticCurve: [ecPoint ellipticCurve]];
        return result;
    }
    [zero release];
        
    FGInt *t1, *t2, *t3, *t4, *t5, *tmpFGInt, *pFGInt = [[ecPoint ellipticCurve] p];

    if (is3) {
        tmpFGInt = [FGInt square: [ecPoint projectiveZ]];
        t4 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
        [tmpFGInt release];
        t5 = [FGInt subtract: [ecPoint x] and: t4];
        [t4 addWith: [ecPoint x]];
        [t4 reduceBySubtracting: pFGInt atMost: 2];
        tmpFGInt = [FGInt multiply: t4 and: t5];
        [t5 release];
        [t4 release];
        t4 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
        [t4 multiplyByInt: 3];
        [t4 reduceBySubtracting: pFGInt atMost: 3];
    } else {
        tmpFGInt = [FGInt square: [ecPoint projectiveZ]];
        t1 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
        [tmpFGInt release];
        t2 = [FGInt square: t1];
        [t1 release];
        t1 = [FGInt barrettMod: t2 by: pFGInt with: invertedP andPrecision: precision];
        [t2 release];
        tmpFGInt = [FGInt multiply: t1 and: [[ecPoint ellipticCurve] a]];
        [t1 release];
        t5 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
        [tmpFGInt release];
        t1 = [FGInt square: [ecPoint x]];
        t4 = [FGInt barrettMod: t1 by: pFGInt with: invertedP andPrecision: precision];
        [t1 release];
        [t4 multiplyByInt: 3];
        [t4 addWith: t5];
        [t4 reduceBySubtracting: pFGInt atMost: 4];
    }

    ECPoint *result = [[ECPoint alloc] init];
    [result setEllipticCurve: [ecPoint ellipticCurve]];

    t2 = [FGInt multiply: [ecPoint y] and: [ecPoint projectiveZ]];
    t3 = [FGInt barrettMod: t2 by: pFGInt with: invertedP andPrecision: precision];
    [t2 release];
    [t3 shiftLeft];
    [t3 reduceBySubtracting: pFGInt atMost: 1];
    tmpFGInt = [FGInt square: [ecPoint y]];
    t2 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t2 and: [ecPoint x]];
    t5 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [t5 shiftLeftBy: 2];
    [t5 reduceBySubtracting: pFGInt atMost: 4];
    [tmpFGInt release];
    tmpFGInt = [FGInt square: t4];
    t1 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    [t5 shiftLeft];
    tmpFGInt = [FGInt subtract: t1 and: t5];
    [t1 release];
    t1 = [FGInt reduce: tmpFGInt bySubtracting: pFGInt atMost: 3];
    [tmpFGInt release];
    [t5 shiftRight];
    tmpFGInt = [FGInt square: t2];
    [t2 release];
    t2 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [t2 shiftLeftBy: 3];
    [t2 reduceBySubtracting: pFGInt atMost: 8];
    [tmpFGInt release];
    tmpFGInt = [FGInt subtract: t5 and: t1];
    [tmpFGInt reduceBySubtracting: pFGInt atMost: 1];
    [t5 release];
    t5 = tmpFGInt;
    tmpFGInt = [FGInt multiply: t4 and: t5];
    t5 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt subtract: t5 and: t2];
    [t2 release];
    t2 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    [result setX: t1];
    [result setY: t2];
    [result setProjectiveZ: t3];

    return result;
}


+(ECPoint *) projectiveAdd: (ECPoint *) ecPoint1 and: (ECPoint *) ecPoint2 aEqualsMinus3: (BOOL) is3 withInvertedPrime: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    if ([ecPoint1 infinity]) {
        ECPoint *result = [ecPoint2 mutableCopy];
        return result;
    }
    if ([ecPoint2 infinity]) {
        ECPoint *result = [ecPoint1 mutableCopy];
        return result;
    }
        
    FGInt *t1, *t2, *t3, *t4, *t5, *t7, *tmpFGInt, *pFGInt = [[ecPoint1 ellipticCurve] p], *zerone = [[FGInt alloc] initWithFGIntBase: 1];
    BOOL z1isOne;
    t1 = [[ecPoint1 x] mutableCopy];
    t2 = [[ecPoint1 y] mutableCopy];
    t3 = [[ecPoint1 projectiveZ] mutableCopy];

    z1isOne = ([FGInt compareAbsoluteValueOf: zerone with: [ecPoint2 projectiveZ]] == equal);
    if (!z1isOne) {
        tmpFGInt = [FGInt square: [ecPoint2 projectiveZ]];
        t7 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: t1 and: t7];
        [t1 release];
        t1 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: [ecPoint2 projectiveZ] and: t7];
        [t7 release];
        t7 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: t2 and: t7];
        [t2 release];
        [t7 release];
        t2 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
        [tmpFGInt release];
    }

    tmpFGInt = [FGInt square: [ecPoint1 projectiveZ]];
    t7 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t7 and: [ecPoint2 x]];
    t4 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t7 and: [ecPoint1 projectiveZ]];
    [t7 release];
    t7 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t7 and: [ecPoint2 y]];
    [t7 release];
    t5 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt subtract: t1 and: t4];
    t4 = [FGInt reduce: tmpFGInt bySubtracting: pFGInt atMost: 1];
    tmpFGInt = [FGInt subtract: t2 and: t5];
    [t5 release];
    t5 = [FGInt reduce: tmpFGInt bySubtracting: pFGInt atMost: 1];
    [tmpFGInt release];
    [zerone decrement];
    if ([FGInt compareAbsoluteValueOf: t4 with: zerone] == equal) {
        if ([FGInt compareAbsoluteValueOf: t5 with: zerone] == equal) {
            [zerone release];
            [t4 release];
            [t5 release];
            [t1 release];
            [t2 release];
            return [ECPoint projectiveDouble: ecPoint1 aEqualsMinus3: is3];
        } else {
            [zerone release];
            [t4 release];
            [t5 release];
            [t1 release];
            [t2 release];
            ECPoint *result = [[ECPoint alloc] initInfinityWithEllpiticCurve: [ecPoint1 ellipticCurve]];
            [result makeProjective];
            return result;
        }
    }
    [t1 shiftLeft];
    tmpFGInt = [FGInt subtract: t1 and: t4];
    t1 = [FGInt reduce: tmpFGInt bySubtracting: pFGInt atMost: 2];
    [tmpFGInt release];
    [t2 shiftLeft];
    tmpFGInt = [FGInt subtract: t2 and: t5];
    [t2 release];
    t2 = [FGInt reduce: tmpFGInt bySubtracting: pFGInt atMost: 2];
    [tmpFGInt release];
    if (!z1isOne) {
        tmpFGInt = [FGInt multiply: t3 and: [ecPoint2 projectiveZ]];
        [t3 release];
        t3 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
        [tmpFGInt release];
    } 
    tmpFGInt = [FGInt multiply: t3 and: t4];
    [t3 release];
    t3 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt square: t4];
    t7 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t4 and: t7];
    [t4 release];
    t4 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t1 and: t7];
    [t7 release];
    t7 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    [t1 release];
    t1 = [FGInt square: t5];
    tmpFGInt = [FGInt subtract: t1 and: t7];
    [t1 release];
    t1 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    [t1 shiftLeft];
    tmpFGInt = [FGInt subtract: t7 and: t1];
    [t7 release];
    t7 = [FGInt reduce: tmpFGInt bySubtracting: pFGInt atMost: 2];
    [tmpFGInt release];
    [t1 shiftRight];
    tmpFGInt = [FGInt multiply: t5 and: t7];
    [t5 release];
    [t7 release];
    t5 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t2 and: t4];
    [t4 release];
    t4 = [FGInt barrettMod: tmpFGInt by: pFGInt with: invertedP andPrecision: precision];
    [tmpFGInt release];
    [t2 release];
    t2 = [FGInt subtract: t5 and: t4];
    [t5 release];
    [t4 release];
    [t2 reduceBySubtracting: pFGInt atMost: 1];    
    FGIntBase* numberArray = [[t2 number] mutableBytes];
    if ((numberArray[0] & 1) == 0) {
        [t2 shiftRight];
    } else {
        [t2 addWith: pFGInt];
        [t2 shiftRight];
    }


    ECPoint *result = [[ECPoint alloc] init];
    [result setEllipticCurve: [ecPoint1 ellipticCurve]];
    [result setX: t1];
    [result setY: t2];
    [result setProjectiveZ: t3];
    return result;
}





+(ECPoint *) projectiveDouble: (ECPoint *) ecPoint withNISTprime: (tag) nistPrimeTag aEqualsMinus3: (BOOL) is3 {
    if ([ecPoint infinity]) {
        ECPoint *result = [ecPoint mutableCopy];
        return result;
    }
    
    FGInt *zero = [[FGInt alloc] initWithFGIntBase: 0];
    if ([FGInt compareAbsoluteValueOf: [ecPoint y] with: zero] == equal) {
        ECPoint *result = [[ECPoint alloc] init];
        [result setX: [[FGInt alloc] initWithFGIntBase: 1]];
        [result setY: [[FGInt alloc] initWithFGIntBase: 1]];
        [result setProjectiveZ: zero];
        [result setInfinity: YES];
        [result setEllipticCurve: [ecPoint ellipticCurve]];
        return result;
    }
    [zero release];
        
    FGInt *t1, *t2, *t3, *t4, *t5, *tmpFGInt, *nistFGInt = [[ecPoint ellipticCurve] p];

    if (is3) {
        tmpFGInt = [FGInt square: [ecPoint projectiveZ]];
        t4 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
        t5 = [FGInt subtract: [ecPoint x] and: t4];
        [t4 addWith: [ecPoint x]];
        tmpFGInt = t4;
        t4 =  [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: t4 and: t5];
        [t5 release];
        t5 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
        [t5 multiplyByInt: 3];
        t4 = [t5 modNISTprime: nistFGInt andTag: nistPrimeTag];
        [t5 release];
    } else {
        tmpFGInt = [FGInt square: [ecPoint projectiveZ]];
        t1 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
        t2 = [FGInt square: t1];
        [t1 release];
        t1 = [t2 modNISTprime: nistFGInt andTag: nistPrimeTag];
        [t2 release];
        tmpFGInt = [FGInt multiply: t1 and: [[ecPoint ellipticCurve] a]];
        [t1 release];
        t5 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
        t1 = [FGInt square: [ecPoint x]];
        t2 = [t1 modNISTprime: nistFGInt andTag: nistPrimeTag];
        [t1 release];
        [t2 multiplyByInt: 3];
        [t2 addWith: t5];
        t4 = [t2 modNISTprime: nistFGInt andTag: nistPrimeTag];
        [t5 release];
        [t2 release];
    }

    ECPoint *result = [[ECPoint alloc] init];
    [result setEllipticCurve: [ecPoint ellipticCurve]];

    t2 = [FGInt multiply: [ecPoint y] and: [ecPoint projectiveZ]];
    tmpFGInt = [t2 modNISTprime: nistFGInt andTag: nistPrimeTag];
    [t2 release];
    [tmpFGInt shiftLeft];
    t3 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt square: [ecPoint y]];
    t2 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t2 and: [ecPoint x]];
    t5 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [t5 shiftLeftBy: 2];
    while ([FGInt compareAbsoluteValueOf: t5 with: nistFGInt] != smaller) {
        [t5 subtractWith: nistFGInt];
    }
    [tmpFGInt release];
    tmpFGInt = [FGInt square: t4];
    t1 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    [t5 shiftLeft];
    tmpFGInt = [FGInt subtract: t1 and: t5];
    [t1 release];
    t1 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    [t5 shiftRight];
    tmpFGInt = [FGInt square: t2];
    [t2 release];
    t2 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [t2 shiftLeftBy: 3];
    [tmpFGInt release];
    tmpFGInt = [FGInt subtract: t5 and: t1];
    [t5 release];
    t5 = tmpFGInt;
    tmpFGInt = [FGInt multiply: t4 and: t5];
    t5 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt subtract: t5 and: t2];
    [t2 release];
    t2 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    [result setX: t1];
    [result setY: t2];
    [result setProjectiveZ: t3];

    return result;
}


+(ECPoint *) projectiveAdd: (ECPoint *) ecPoint1 and: (ECPoint *) ecPoint2 withNISTprime: (tag) nistPrimeTag aEqualsMinus3: (BOOL) is3 {
    if ([ecPoint1 infinity]) {
        ECPoint *result = [ecPoint2 mutableCopy];
        return result;
    }
    if ([ecPoint2 infinity]) {
        ECPoint *result = [ecPoint1 mutableCopy];
        return result;
    }
        
    FGInt *t1, *t2, *t3, *t4, *t5, *t7, *tmpFGInt, *nistFGInt = [[ecPoint1 ellipticCurve] p], *zerone = [[FGInt alloc] initWithFGIntBase: 1];
    BOOL z1isOne;
    t1 = [[ecPoint1 x] mutableCopy];
    t2 = [[ecPoint1 y] mutableCopy];
    t3 = [[ecPoint1 projectiveZ] mutableCopy];

    z1isOne = ([FGInt compareAbsoluteValueOf: zerone with: [ecPoint2 projectiveZ]] == equal);
    if (!z1isOne) {
        tmpFGInt = [FGInt square: [ecPoint2 projectiveZ]];
        t7 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: t1 and: t7];
        [t1 release];
        t1 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: [ecPoint2 projectiveZ] and: t7];
        [t7 release];
        t7 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
        tmpFGInt = [FGInt multiply: t2 and: t7];
        [t2 release];
        [t7 release];
        t2 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
    }

    tmpFGInt = [FGInt square: [ecPoint1 projectiveZ]];
    t7 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t7 and: [ecPoint2 x]];
    t4 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t7 and: [ecPoint1 projectiveZ]];
    [t7 release];
    t7 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t7 and: [ecPoint2 y]];
    [t7 release];
    t5 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    t4 = [FGInt subtract: t1 and: t4];
    tmpFGInt = [FGInt subtract: t2 and: t5];
    [t5 release];
    t5 = tmpFGInt;
    [zerone decrement];
    if ([FGInt compareAbsoluteValueOf: t4 with: zerone] == equal) {
        if ([FGInt compareAbsoluteValueOf: t5 with: zerone] == equal) {
            [zerone release];
            [t4 release];
            [t5 release];
            [t1 release];
            [t2 release];
            return [ECPoint projectiveDouble: ecPoint1 aEqualsMinus3: is3];
        } else {
            [zerone release];
            [t4 release];
            [t5 release];
            [t1 release];
            [t2 release];
            ECPoint *result = [[ECPoint alloc] initInfinityWithEllpiticCurve: [ecPoint1 ellipticCurve]];
            [result makeProjective];
            return result;
        }
    }
    [t1 shiftLeft];
    tmpFGInt = [FGInt subtract: t1 and: t4];
    [t1 release];
    t1 =  [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    [t2 shiftLeft];
    tmpFGInt = [FGInt subtract: t2 and: t5];
    [t2 release];
    t2 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    if (!z1isOne) {
        tmpFGInt = [FGInt multiply: t3 and: [ecPoint2 projectiveZ]];
        [t3 release];
        t3 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
        [tmpFGInt release];
    } 
    tmpFGInt = [FGInt multiply: t3 and: t4];
    [t3 release];
    t3 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt square: t4];
    t7 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t4 and: t7];
    [t4 release];
    t4 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t1 and: t7];
    [t7 release];
    t7 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    [t1 release];
    t1 = [FGInt square: t5];
    tmpFGInt = [FGInt subtract: t1 and: t7];
    [t1 release];
    t1 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    [t1 shiftLeft];
    tmpFGInt = [FGInt subtract: t7 and: t1];
    [t7 release];
    t7 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    [t1 shiftRight];
    tmpFGInt = [FGInt multiply: t5 and: t7];
    [t5 release];
    [t7 release];
    t5 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    tmpFGInt = [FGInt multiply: t2 and: t4];
    [t4 release];
    t4 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    [t2 release];
    tmpFGInt = [FGInt subtract: t5 and: t4];
    [t5 release];
    [t4 release];
    t2 = [tmpFGInt modNISTprime: nistFGInt andTag: nistPrimeTag];
    [tmpFGInt release];
    FGIntBase* numberArray = [[t2 number] mutableBytes];
    if ((numberArray[0] & 1) == 0) {
        [t2 shiftRight];
    } else {
        [t2 addWith: nistFGInt];
        [t2 shiftRight];
    }


    ECPoint *result = [[ECPoint alloc] init];
    [result setEllipticCurve: [ecPoint1 ellipticCurve]];
    [result setX: t1];
    [result setY: t2];
    [result setProjectiveZ: t3];
    return result;
}






+(ECPoint *) add: (ECPoint *) ecPoint kTimes: (FGInt *) kFGInt {
    ECPoint *result = [[ECPoint alloc] initInfinityWithEllpiticCurve: [ecPoint ellipticCurve]], *tmpECPoint, *tmpECPoint1;

    FGInt *pFGInt = [[[ecPoint ellipticCurve] p] mutableCopy];
    FGIntOverflow precision = [pFGInt bitSize];
    FGInt *invertedP = [FGInt newtonInversion: pFGInt withPrecision: precision];

    [pFGInt decrement];
    [pFGInt decrement];
    [pFGInt decrement];
    BOOL aEqualsMinus3 = ([FGInt compareAbsoluteValueOf: [[ecPoint ellipticCurve] a] with: pFGInt] == equal);
    [pFGInt release];
    FGIntOverflow kLength = [[kFGInt number] length]/4, i, j;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kFGInt number] mutableBytes];
    
    tmpECPoint1 = [ecPoint retain];
    [tmpECPoint1 makeProjective];
    [result makeProjective];



    for( i = 0; i < kLength - 1; i++ ) {
        tmp = kFGIntNumber[i];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                // tmpECPoint = [ECPoint projectiveAdd: result and: tmpECPoint1 aEqualsMinus3: aEqualsMinus3];
                tmpECPoint = [ECPoint projectiveAdd: result and: tmpECPoint1 aEqualsMinus3: aEqualsMinus3 withInvertedPrime: invertedP andPrecision: precision];
                [result release];
                result = tmpECPoint;
            }
            // tmpECPoint = [ECPoint projectiveDouble: tmpECPoint1 aEqualsMinus3: aEqualsMinus3];
            tmpECPoint = [ECPoint projectiveDouble: tmpECPoint1 aEqualsMinus3: aEqualsMinus3 withInvertedPrime: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
            tmp >>= 1;
        }
    }
    tmp = kFGIntNumber[kLength - 1];
    while (tmp != 0) {
        if ((tmp % 2) == 1) {
            // tmpECPoint = [ECPoint projectiveAdd: result and: tmpECPoint1 aEqualsMinus3: aEqualsMinus3];
            tmpECPoint = [ECPoint projectiveAdd: result and: tmpECPoint1 aEqualsMinus3: aEqualsMinus3 withInvertedPrime: invertedP andPrecision: precision];
            [result release];
            result = tmpECPoint;
        }
        tmp >>= 1;
        if (tmp != 0) {
            // tmpECPoint = [ECPoint projectiveDouble: tmpECPoint1 aEqualsMinus3: aEqualsMinus3];
            tmpECPoint = [ECPoint projectiveDouble: tmpECPoint1 aEqualsMinus3: aEqualsMinus3 withInvertedPrime: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
        }
    }
    [invertedP release];

    [tmpECPoint1 makeAffine];
    [tmpECPoint1 release];
    [result makeAffine];

    return result;
}


+(ECPoint *) add: (ECPoint *) ecPoint1 k1Times: (FGInt *) k1FGInt and: (ECPoint *) ecPoint2 k2Times: (FGInt *) k2FGInt {
    if ([[k2FGInt number] length] > [[k1FGInt number] length]) {
        return [ECPoint add: ecPoint2 k1Times: k2FGInt and: ecPoint1 k2Times: k1FGInt];
    }
        
    FGInt *pFGInt = [[[ecPoint1 ellipticCurve] p] mutableCopy];
    FGIntOverflow precision = [pFGInt bitSize];
    FGInt *invertedP = [FGInt newtonInversion: pFGInt withPrecision: precision];

    [pFGInt decrement];
    [pFGInt decrement];
    [pFGInt decrement];
    BOOL aEqualsMinus3 = ([FGInt compareAbsoluteValueOf: [[ecPoint1 ellipticCurve] a] with: pFGInt] == equal);
    [pFGInt release];

    ECPoint *result = [[ECPoint alloc] initInfinityWithEllpiticCurve: [ecPoint1 ellipticCurve]], *tmpECPoint;
    FGIntOverflow k1Length = [[k1FGInt number] length]/4, k2Length = [[k2FGInt number] length]/4, i;
    FGIntBase* k1FGIntNumber = [[k1FGInt number] mutableBytes];
    FGIntBase* k2FGIntNumber = [[k2FGInt number] mutableBytes];
    FGIntBase k1Base, k2Base;

    [result makeProjective];
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1];
    [ecPoint1 setProjectiveZ: one];
    [ecPoint2 setProjectiveZ: one];
    ECPoint *sum = [ECPoint projectiveAdd: ecPoint1 and: ecPoint2 aEqualsMinus3: aEqualsMinus3];

    for( i = 0; i < k1Length; ++i ) {
        k1Base = k1FGIntNumber[k1Length - i - 1];
        if (k2Length > k1Length - i - 1) {
            k2Base = k2FGIntNumber[k1Length - i - 1];
        } else {
            k2Base = 0;
        }
        for( int j = 31; j >= 0; --j ) {
            // tmpECPoint = [ECPoint projectiveDouble: result aEqualsMinus3: aEqualsMinus3];
            tmpECPoint = [ECPoint projectiveDouble: result aEqualsMinus3: aEqualsMinus3 withInvertedPrime: invertedP andPrecision: precision];
            [result release];
            result = tmpECPoint;
            if ((((k1Base >> j) % 2) == 1) && (((k2Base >> j) % 2) == 1)) {
                // tmpECPoint = [ECPoint projectiveAdd: result and: sum aEqualsMinus3: aEqualsMinus3];
                tmpECPoint = [ECPoint projectiveAdd: result and: sum aEqualsMinus3: aEqualsMinus3 withInvertedPrime: invertedP andPrecision: precision];
                [result release];
                result = tmpECPoint;
            } else if (((k1Base >> j) % 2) == 1) {
                tmpECPoint = [ECPoint projectiveAdd: result and: ecPoint1 aEqualsMinus3: aEqualsMinus3 withInvertedPrime: invertedP andPrecision: precision];
                // tmpECPoint = [ECPoint projectiveAdd: result and: ecPoint1 aEqualsMinus3: aEqualsMinus3];
                [result release];
                result = tmpECPoint;
            } else if (((k2Base >> j) % 2) == 1) {
                tmpECPoint = [ECPoint projectiveAdd: result and: ecPoint2 aEqualsMinus3: aEqualsMinus3 withInvertedPrime: invertedP andPrecision: precision];
                // tmpECPoint = [ECPoint projectiveAdd: result and: ecPoint2 aEqualsMinus3: aEqualsMinus3];
                [result release];
                result = tmpECPoint;
            }
        }
    }
    [sum release];
    [invertedP release];

    [one release];
    [ecPoint1 setProjectiveZ: nil];
    [ecPoint2 setProjectiveZ: nil];
    [result makeAffine];

    return result;
}


+(ECPoint *) add: (ECPoint *) ecPoint kTimes: (FGInt *) kFGInt withNISTprime: (tag) nistPrimeTag {
    ECPoint *result = [[ECPoint alloc] initInfinityWithEllpiticCurve: [ecPoint ellipticCurve]], *tmpECPoint, *tmpECPoint1;

    FGInt *pFGInt = [[[ecPoint ellipticCurve] p] mutableCopy];
    [pFGInt decrement];
    [pFGInt decrement];
    [pFGInt decrement];
    BOOL aEqualsMinus3 = ([FGInt compareAbsoluteValueOf: [[ecPoint ellipticCurve] a] with: pFGInt] == equal);
    [pFGInt release];
    FGIntOverflow kLength = [[kFGInt number] length]/4, i, j;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kFGInt number] mutableBytes];
    
    tmpECPoint1 = [ecPoint retain];
    [tmpECPoint1 makeProjective];
    [result makeProjective];

    for( i = 0; i < kLength - 1; i++ ) {
        tmp = kFGIntNumber[i];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpECPoint = [ECPoint projectiveAdd: result and: tmpECPoint1 withNISTprime: nistPrimeTag aEqualsMinus3: aEqualsMinus3];
                [result release];
                result = tmpECPoint;
            }
            tmpECPoint = [ECPoint projectiveDouble: tmpECPoint1 withNISTprime: nistPrimeTag aEqualsMinus3: aEqualsMinus3];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
            tmp >>= 1;
        }
    }
    tmp = kFGIntNumber[kLength - 1];
    while (tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpECPoint = [ECPoint projectiveAdd: result and: tmpECPoint1 withNISTprime: nistPrimeTag aEqualsMinus3: aEqualsMinus3];
            [result release];
            result = tmpECPoint;
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpECPoint = [ECPoint projectiveDouble: tmpECPoint1 withNISTprime: nistPrimeTag aEqualsMinus3: aEqualsMinus3];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
        }
    }

    [tmpECPoint1 makeAffine];
    [tmpECPoint1 release];
    [result makeAffine];

    return result;
}


+(ECPoint *) add: (ECPoint *) ecPoint1 k1Times: (FGInt *) k1FGInt and: (ECPoint *) ecPoint2 k2Times: (FGInt *) k2FGInt withNISTprime: (tag) nistPrimeTag {
    if ([[k2FGInt number] length] > [[k1FGInt number] length]) {
        return [ECPoint add: ecPoint2 k1Times: k2FGInt and: ecPoint1 k2Times: k1FGInt];
    }
        
    FGInt *pFGInt = [[[ecPoint1 ellipticCurve] p] mutableCopy];
    [pFGInt decrement];
    [pFGInt decrement];
    [pFGInt decrement];
    BOOL aEqualsMinus3 = ([FGInt compareAbsoluteValueOf: [[ecPoint1 ellipticCurve] a] with: pFGInt] == equal);
    [pFGInt release];

    ECPoint *result = [[ECPoint alloc] initInfinityWithEllpiticCurve: [ecPoint1 ellipticCurve]], *tmpECPoint;
    FGIntOverflow k1Length = [[k1FGInt number] length]/4, k2Length = [[k2FGInt number] length]/4, i;
    FGIntBase* k1FGIntNumber = [[k1FGInt number] mutableBytes];
    FGIntBase* k2FGIntNumber = [[k2FGInt number] mutableBytes];
    FGIntBase k1Base, k2Base;

    [result makeProjective];
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1];
    [ecPoint1 setProjectiveZ: one];
    [ecPoint2 setProjectiveZ: one];
    ECPoint *sum = [ECPoint projectiveAdd: ecPoint1 and: ecPoint2 withNISTprime: nistPrimeTag aEqualsMinus3: aEqualsMinus3];

    for( i = 0; i < k1Length; ++i ) {
        k1Base = k1FGIntNumber[k1Length - i - 1];
        if (k2Length > k1Length - i - 1) {
            k2Base = k2FGIntNumber[k1Length - i - 1];
        } else {
            k2Base = 0;
        }
        for( int j = 31; j >= 0; --j ) {
            tmpECPoint = [ECPoint projectiveDouble: result withNISTprime: nistPrimeTag aEqualsMinus3: aEqualsMinus3];
            [result release];
            result = tmpECPoint;
            if ((((k1Base >> j) % 2) == 1) && (((k2Base >> j) % 2) == 1)) {
                tmpECPoint = [ECPoint projectiveAdd: result and: sum withNISTprime: nistPrimeTag aEqualsMinus3: aEqualsMinus3];
                [result release];
                result = tmpECPoint;
            } else if (((k1Base >> j) % 2) == 1) {
                tmpECPoint = [ECPoint projectiveAdd: result and: ecPoint1 withNISTprime: nistPrimeTag aEqualsMinus3: aEqualsMinus3];
                [result release];
                result = tmpECPoint;
            } else if (((k2Base >> j) % 2) == 1) {
                tmpECPoint = [ECPoint projectiveAdd: result and: ecPoint2 withNISTprime: nistPrimeTag aEqualsMinus3: aEqualsMinus3];
                [result release];
                result = tmpECPoint;
            }
        }
    }
    [sum release];

    [one release];
    [ecPoint1 setProjectiveZ: nil];
    [ecPoint2 setProjectiveZ: nil];
    [result makeAffine];

    return result;
}


// +(ECPoint *) add: (ECPoint *) ecPoint kTimes: (FGInt *) kFGInt {
//     ECPoint *result = [[ECPoint alloc] initInfinityWithEllpiticCurve: [ecPoint ellipticCurve]], *tmpECPoint, *tmpECPoint1;
//     FGIntOverflow kLength = [[kFGInt number] length]/4, i, j;
//     FGIntBase tmp;
//     FGIntBase* kFGIntNumber = [[kFGInt number] mutableBytes];
    
//     tmpECPoint1 = [ecPoint retain];

//     for( i = 0; i < kLength - 1; i++ ) {
//         tmp = kFGIntNumber[i];
//         for( j = 0; j < 32; ++j ) {
//             if ((tmp % 2) == 1) {
//                 tmpECPoint = [ECPoint add: result and: tmpECPoint1];
//                 [result release];
//                 result = tmpECPoint;
//             }
//             tmpECPoint = [ECPoint double: tmpECPoint1];
//             [tmpECPoint1 release];
//             tmpECPoint1 = tmpECPoint;
//             tmp >>= 1;
//         }
//     }
//     tmp = kFGIntNumber[kLength - 1];
//     while (tmp != 0) {
//         if ((tmp % 2) == 1) {
//             tmpECPoint = [ECPoint add: result and: tmpECPoint1];
//             [result release];
//             result = tmpECPoint;
//         }
//         tmp >>= 1;
//         if (tmp != 0) {
//             tmpECPoint = [ECPoint double: tmpECPoint1];
//             [tmpECPoint1 release];
//             tmpECPoint1 = tmpECPoint;
//         }
//     }

//     [tmpECPoint1 release];

//     return result;
// }


// +(ECPoint *) add: (ECPoint *) ecPoint1 k1Times: (FGInt *) k1FGInt and: (ECPoint *) ecPoint2 k2Times: (FGInt *) k2FGInt {
//     if ([[k2FGInt number] length] > [[k1FGInt number] length])
//         return [ECPoint add: ecPoint2 k1Times: k2FGInt and: ecPoint1 k2Times: k1FGInt];
        

//     ECPoint *result = [[ECPoint alloc] initInfinityWithEllpiticCurve: [ecPoint1 ellipticCurve]], *tmpECPoint, *tmpECPoint1,
//         *sum = [ECPoint add: ecPoint1 and: ecPoint2];
//     FGIntOverflow k1Length = [[k1FGInt number] length]/4, k2Length = [[k2FGInt number] length]/4, i;
//     FGIntBase* k1FGIntNumber = [[k1FGInt number] mutableBytes];
//     FGIntBase* k2FGIntNumber = [[k2FGInt number] mutableBytes];
//     FGIntBase k1Base, k2Base;

//     for( i = 0; i < k1Length; ++i ) {
//         k1Base = k1FGIntNumber[k1Length - i - 1];
//         if (k2Length > k1Length - i - 1) {
//             k2Base = k2FGIntNumber[k1Length - i - 1];
//         } else {
//             k2Base = 0;
//         }
//         for( int j = 31; j >= 0; --j ) {
//             tmpECPoint = [ECPoint double: result];
//             [result release];
//             result = tmpECPoint;
//             if ((((k1Base >> j) % 2) == 1) && (((k2Base >> j) % 2) == 1)) {
//                 tmpECPoint = [ECPoint add: result and: sum];
//                 [result release];
//                 result = tmpECPoint;
//             } else if (((k1Base >> j) % 2) == 1) {
//                 tmpECPoint = [ECPoint add: result and: ecPoint1];
//                 [result release];
//                 result = tmpECPoint;
//             } else if (((k2Base >> j) % 2) == 1) {
//                 tmpECPoint = [ECPoint add: result and: ecPoint2];
//                 [result release];
//                 result = tmpECPoint;
//             }
//         }
//     }
//     [sum release];

//     return result;
// }


+(ECPoint *) invert: (ECPoint *) ecPoint {
    if ([ecPoint infinity]) {
        return [ecPoint mutableCopy];
    }
    ECPoint *invertedPoint = [[ECPoint alloc] init];
    [invertedPoint setInfinity: NO];
    [invertedPoint setEllipticCurve: [ecPoint ellipticCurve]];
    [invertedPoint setX: [[ecPoint x] mutableCopy]];
    FGInt *invertedY = [[[ecPoint ellipticCurve] p] mutableCopy];
    [invertedY subtractWith: [ecPoint y]];
    [invertedPoint setY: invertedY];
//    [invertedY release];
    return invertedPoint;
}



+(ECPoint *) inbedNSData: (NSData *) data onEllipticCurve: (EllipticCurve *) ellipticC {
    FGIntOverflow byteLength = [[ellipticC p] byteSize];

    if (!data) {
        NSLog(@"No data available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if ([data length] == 0) {
        NSLog(@"data is empty for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    if ([data length] > byteLength - 4) {
        NSLog(@"data is too big (it needs to be %llu or less) for %s at line %d", byteLength - 3, __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    NSMutableData *tmpData = [[NSMutableData alloc] init];
    FGIntBase padLength = byteLength - 1 - [data length] - 2;
    unsigned char aBuffer[2];
    [tmpData setLength: padLength];
    [tmpData appendData: data];
    aBuffer[0] = padLength;
    aBuffer[1] = (padLength >> 8);
    [tmpData appendBytes: aBuffer length: 2];

    FGInt *x = [[FGInt alloc] initWithNSData: tmpData], *counter = [[FGInt alloc] initWithFGIntBase: 0], *MaxTries = [[FGInt alloc] initWithFGIntBase: 1], *x3;
    [MaxTries shiftLeftBy: 8 * padLength];
    [tmpData release];
    BOOL tryAgain;
    do {
        tryAgain = NO;  
        FGInt *tmpFGInt = [FGInt square: x], *ax = [FGInt multiply: x and: [ellipticC a]];
        x3 = [FGInt multiply: x and: tmpFGInt];
        [tmpFGInt release];
        [ax addWith: x3];
        [ax addWith: [ellipticC b]];
        [x3 release];
        x3 = [FGInt mod: ax by: [ellipticC p]];
        [ax release];
        if ([x3 legendreSymbolMod: [ellipticC p]] != 1) {
            [counter increment];
            [x3 release];
            if ([FGInt compareAbsoluteValueOf: counter with: MaxTries] != smaller) {
                [counter release];
                [MaxTries release];
                [x release];
                NSLog(@"inbedding failed, try again with %lu or less bytes, %s at line %d", [data length] - 1, __PRETTY_FUNCTION__, __LINE__);
                return nil;
            }
            [x increment];
            tryAgain = YES;
        }
    } while (tryAgain);
    [counter release];
    [MaxTries release];
    FGInt *y = [FGInt squareRootOf: x3 mod: [ellipticC p]];
    [x3 release];
    ECPoint *result = [[ECPoint alloc] init];
    [result setX: x];
    [result setY: y];
    [result setInfinity: NO];
    [result setEllipticCurve: ellipticC];
    return result;
}


-(NSData *) extractInbeddedNSData {
    if (!x) {
        NSLog(@"No x available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }

    @autoreleasepool{
        NSMutableData *tmpData = [[x toNSData] mutableCopy];
        FGIntOverflow byteLength = [[ellipticCurve p] byteSize];
        [tmpData setLength: byteLength - 1];
        unsigned char *bytes = [tmpData mutableBytes]; 
        FGIntOverflow padLength = bytes[[tmpData length] - 1];
        padLength <<= 8;
        padLength += bytes[[tmpData length] - 2];
        if ([tmpData length] < padLength - 2 ) {
            NSLog(@"There is no inbedded data for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
            [tmpData release];
            return nil;
        }
        NSData *result = [[NSData alloc] initWithData: [tmpData subdataWithRange: NSMakeRange(padLength, [tmpData length] - 2 - padLength)]];
        [tmpData release];
        return result;
    }
}


-(void) findNextECPoint {
    FGInt *x3, *tmpFGInt, *ax;
    EllipticCurve *ellipticC = [self ellipticCurve];
    BOOL tryAgain;

    do {
        [x increment];
        tmpFGInt = [FGInt mod: x by: [ellipticC p]];
        [x release];
        [self setX: tmpFGInt];
        tryAgain = NO;  
        tmpFGInt = [FGInt square: x]; 
        ax = [FGInt multiply: x and: [ellipticC a]];
        x3 = [FGInt multiply: x and: tmpFGInt];
        [tmpFGInt release];
        [ax addWith: x3];
        [ax addWith: [ellipticC b]];
        [x3 release];
        x3 = [FGInt mod: ax by: [ellipticC p]];
        [ax release];
        if ([x3 legendreSymbolMod: [ellipticC p]] != 1) {
            [x3 release];
            tryAgain = YES;
        }
    } while (tryAgain);
    [y release];
    [self setY: [FGInt squareRootOf: x3 mod: [ellipticC p]]];
    [x3 release];
    [self setInfinity: NO];
}


+(EllipticCurve *) constructCurveWithCMD: (unsigned char) cmd {
    EllipticCurve *result = [[EllipticCurve alloc] init];
    
    switch (cmd) {
        case 1:
            [result setA: [[FGInt alloc] initWithFGIntBase: 1]];
            [result setB: [[FGInt alloc] initWithFGIntBase: 0]];
            break;
        case 2:
            [result setA: [[FGInt alloc] initWithNegativeFGIntBase: 30]];
            [result setB: [[FGInt alloc] initWithFGIntBase: 56]];
            break;
        case 3:
            [result setA: [[FGInt alloc] initWithFGIntBase: 0]];
            [result setB: [[FGInt alloc] initWithFGIntBase: 1]];
            break;
        case 7:
            [result setA: [[FGInt alloc] initWithNegativeFGIntBase: 35]];
            [result setB: [[FGInt alloc] initWithFGIntBase: 98]];
            break;
        case 11:
            [result setA: [[FGInt alloc] initWithNegativeFGIntBase: 264]];
            [result setB: [[FGInt alloc] initWithFGIntBase: 1694]];
            break;
        case 19:
            [result setA: [[FGInt alloc] initWithNegativeFGIntBase: 152]];
            [result setB: [[FGInt alloc] initWithFGIntBase: 722]];
            break;
        case 43:
            [result setA: [[FGInt alloc] initWithNegativeFGIntBase: 3440]];
            [result setB: [[FGInt alloc] initWithFGIntBase: 77658]];
            break;
        case 67:
            [result setA: [[FGInt alloc] initWithNegativeFGIntBase: 29480]];
            [result setB: [[FGInt alloc] initWithFGIntBase: 1948226]];
            break;
        case 163:
            [result setA: [[FGInt alloc] initWithNegativeFGIntBase: 8697680]];
            [result setB: [[FGInt alloc] initWithBase10String: @"9873093538"]];
            break;
        default:
            [result release];
            result = nil;
            break;
    }
    return result;
}


+(NSDictionary *) is: (FGInt *) dFGInt aCMDmod: (FGInt *) pFGInt {
    FGInt *tmpFGInt, *tmpD, *tmpFGInt1, *tmpFGInt2, *aFGInt, *bFGInt, *cFGInt, *u1, *u2, *s11, *s121, *s22, *vFGInt = nil, *wFGInt = nil;
    tmpFGInt = [FGInt subtract: pFGInt and: dFGInt];

    if ([tmpFGInt legendreSymbolMod: pFGInt] == -1) {
        [tmpFGInt release];
        return nil;
    }
    
    bFGInt = [FGInt squareRootOf: tmpFGInt mod: pFGInt];
    [tmpFGInt release];
    aFGInt = [pFGInt mutableCopy];
    tmpFGInt = [FGInt square: bFGInt];
    [tmpFGInt addWith: dFGInt];
    NSDictionary *tmpDiv = [FGInt divide: tmpFGInt by: pFGInt];
    cFGInt = [[tmpDiv objectForKey: quotientKey] retain];
    [tmpDiv release];
    [tmpFGInt release];
    s11 = [aFGInt mutableCopy];
    s121 = [bFGInt mutableCopy];
    s22 = [cFGInt mutableCopy];
    u1 = [[FGInt alloc] initWithFGIntBase: 1];
    u2 = [[FGInt alloc] initWithFGIntBase: 0];
    tmpFGInt = [bFGInt mutableCopy];
    [tmpFGInt shiftLeft];
    
    while (([FGInt compareAbsoluteValueOf: tmpFGInt with: aFGInt] == larger) || ([FGInt compareAbsoluteValueOf: aFGInt with: cFGInt] == larger)) {
        tmpFGInt1 = [FGInt add: tmpFGInt and: cFGInt];
        [tmpFGInt release];
        tmpFGInt2 = [cFGInt mutableCopy];
        [tmpFGInt2 shiftLeft];
        NSDictionary *tmpDiv = [FGInt divide: tmpFGInt1 by: tmpFGInt2];
        [tmpFGInt1 release];
        [tmpFGInt2 release];
        tmpD = [[tmpDiv objectForKey: quotientKey] retain];
        [tmpDiv release];
        tmpFGInt1 = [FGInt multiply: tmpD and: u1];
        tmpFGInt2 = [FGInt add: tmpFGInt1 and: u2];
        [tmpFGInt1 release];
        [u2 release];
        [u1 changeSign];
        u2 = u1;
        u1 = tmpFGInt2;
        [s11 release];
        s11 = [cFGInt mutableCopy];
        tmpFGInt1 = [FGInt multiply: tmpD and: cFGInt];
        tmpFGInt2 = [FGInt subtract: tmpFGInt1 and: bFGInt];
        [tmpFGInt1 release];
        [s121 release];
        s121 = tmpFGInt2;
        tmpFGInt2 = [FGInt multiply: tmpD and: s121];
        tmpFGInt1 = [FGInt multiply: bFGInt and: tmpD];
        tmpFGInt = [FGInt subtract: tmpFGInt2 and: tmpFGInt1];
        [tmpFGInt1 release];
        [tmpFGInt2 release];
        [s22 release];
        s22 = [FGInt add: tmpFGInt and: aFGInt];
        [tmpFGInt release];
        [aFGInt release];
        [bFGInt release];
        [cFGInt release];
        aFGInt = [s11 mutableCopy];
        bFGInt = [s121 mutableCopy];
        cFGInt = [s22 mutableCopy];
        tmpFGInt = [bFGInt mutableCopy];
        [tmpFGInt shiftLeft];
        [tmpD release];
    }
    [tmpFGInt release];
    [s11 release];
    [s121 release];
    [s22 release];
    FGInt *three = [[FGInt alloc] initWithFGIntBase: 3], *eleven = [[FGInt alloc] initWithFGIntBase: 11], 
        *one = [[FGInt alloc] initWithFGIntBase: 1], *four = [[FGInt alloc] initWithFGIntBase: 4];
    if (([FGInt compareAbsoluteValueOf: dFGInt with: eleven] == equal) && ([aFGInt sign]) && ([FGInt compareAbsoluteValueOf: aFGInt with: three] == equal)) {
        tmpFGInt = u2;
        u2 = u1;
        u1 = tmpFGInt;
        [u2 changeSign];
        [bFGInt changeSign];
        tmpFGInt = aFGInt;
        aFGInt = cFGInt;
        cFGInt = tmpFGInt;
    }
    BOOL isCMD = NO;
    vFGInt = nil;
    if (([FGInt compareAbsoluteValueOf: dFGInt with: one] == equal) || ([FGInt compareAbsoluteValueOf: dFGInt with: three] == equal)) {
        isCMD = YES;
        wFGInt = [FGInt add: u1 and: u1];
        vFGInt = [FGInt add: u2 and: u2];
    } else if (([FGInt compareAbsoluteValueOf: aFGInt with: one] == equal)) {
        isCMD = YES;
        wFGInt = [FGInt add: u1 and: u1];
    }
    if (([FGInt compareAbsoluteValueOf: aFGInt with: four] == equal)) {
        isCMD = YES;
        [u1 shiftLeftBy: 2];
        tmpFGInt = [FGInt multiply: bFGInt and: u2];
        wFGInt = [FGInt add: tmpFGInt and: u1];
        [tmpFGInt release];
    }
    [one release];
    [three release];
    [four release];
    [eleven release];
    [aFGInt release];
    [bFGInt release];
    [cFGInt release];
    [u1 release];
    [u2 release];
    NSMutableDictionary *result = nil;
    if (isCMD) {
        result = [[NSMutableDictionary alloc] init];
        [result setObject: wFGInt forKey: wKey];
        [wFGInt release];
        if (vFGInt) {
            [result setObject: vFGInt forKey: vKey];
            [vFGInt release];
        }
    }
    return result;
}

+(unsigned char) findNextCMD: (unsigned char) cmd mod: (FGInt *) pFGInt {
    unsigned char candidates1[9] = { 1, 2, 3, 7, 11, 19, 43, 67, 163};
    unsigned char candidates3[8] = { 2, 3, 7, 11, 19, 43, 67, 163};
    unsigned char candidates5[8] = { 1, 3, 7, 11, 19, 43, 67, 163};
    unsigned char candidates7[7] = { 3, 7, 11, 19, 43, 67, 163};
    unsigned char nextCMD = 0, i;
    FGIntBase* numberArray = [[pFGInt number] mutableBytes];

    switch (numberArray[0] % 8) {
        case 1:
            for ( i = 0; i < 9; ++i ) {
                if (candidates1[i] > cmd) {
                    nextCMD = candidates1[i];
                    break;
                }
            }
            break;
        case 3:
            for ( i = 0; i < 8; ++i ) {
                if (candidates3[i] > cmd) {
                    nextCMD = candidates3[i];
                    break;
                }
            }
            break;
        case 5:
            for ( i = 0; i < 8; ++i ) {
                if (candidates5[i] > cmd) {
                    nextCMD = candidates5[i];
                    break;
                }
            }
            break;
        case 7:
            for ( i = 0; i < 7; ++i ) {
                if (candidates7[i] > cmd) {
                    nextCMD = candidates7[i];
                    break;
                }
            }
            break;
    }
    return nextCMD;
}


+(NSArray *) possibleCurveOrderMod: (FGInt *) pFGInt {
    NSMutableArray *result = nil;
    BOOL found = NO;
    unsigned char cmd = 0;
    while (!found) {
        cmd = [ECPoint findNextCMD: cmd mod: pFGInt];
        if (cmd == 0) {
            return nil;
        }
        FGInt *dFGInt = [[FGInt alloc] initWithFGIntBase: cmd];
        [dFGInt changeSign];
        int cmdL = [dFGInt legendreSymbolMod: pFGInt];
        [dFGInt changeSign];
        if (cmdL != -1) {
            if (cmd > 2) {
                cmdL = [pFGInt legendreSymbolMod: dFGInt];
            }
            else {
                cmdL = 1;
            }
            if (cmdL != -1) {
                NSDictionary *isCMD = [ECPoint is: dFGInt aCMDmod: pFGInt];
                if (isCMD) {
                    found = YES;
                }
                if (isCMD) {
                    FGInt *wFGInt = [isCMD objectForKey: wKey], *vFGInt = nil;
                    if ((cmd == 1) || (cmd == 3)) {
                        vFGInt = [isCMD objectForKey: vKey];
                    }
                    FGInt *tmpFGInt = [pFGInt mutableCopy], *tmpFGInt1, *tmpFGInt2;
                    [tmpFGInt increment];
                    result = [[NSMutableArray alloc] init];
                    [result addObject: [NSNumber numberWithUnsignedChar: cmd]];
                    if (cmd == 1) {
                        tmpFGInt1 = [FGInt add: tmpFGInt and: wFGInt];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                        tmpFGInt1 = [FGInt subtract: tmpFGInt and: wFGInt];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                        tmpFGInt1 = [FGInt add: tmpFGInt and: vFGInt];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                        tmpFGInt1 = [FGInt subtract: tmpFGInt and: vFGInt];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                    } else if (cmd == 3) {
                        tmpFGInt1 = [FGInt add: tmpFGInt and: wFGInt];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                        tmpFGInt1 = [FGInt subtract: tmpFGInt and: wFGInt];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];

                        [vFGInt multiplyByInt: 3];
                        tmpFGInt2 = [FGInt add: wFGInt and: vFGInt];
                        [tmpFGInt2 shiftRight];

                        tmpFGInt1 = [FGInt add: tmpFGInt and: tmpFGInt2];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                        tmpFGInt1 = [FGInt subtract: tmpFGInt and: tmpFGInt2];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                        
                        [tmpFGInt2 release];
                        tmpFGInt2 = [FGInt subtract: wFGInt and: vFGInt];
                        [tmpFGInt2 shiftRight];

                        tmpFGInt1 = [FGInt add: tmpFGInt and: tmpFGInt2];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                        tmpFGInt1 = [FGInt subtract: tmpFGInt and: tmpFGInt2];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                        
                        [tmpFGInt2 release];
                    } else {
                        tmpFGInt1 = [FGInt add: tmpFGInt and: wFGInt];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                        tmpFGInt1 = [FGInt subtract: tmpFGInt and: wFGInt];
                        [result addObject: tmpFGInt1];
                        [tmpFGInt1 release];
                    }
                    [tmpFGInt release];
                    [isCMD release];
                } 
            }
        }
        [dFGInt release];
    }
    return result;
}


+(ECPoint *) constructCurveAndPointWithOrder: (FGInt *) rFGInt andCMD: (unsigned char) cmd andCurve: (EllipticCurve *) ellipticC {
    BOOL constructed = NO;
    ECPoint *tmpG, *result = nil;
    FGInt *tmpFGInt, *tmpA, *tmpB, *xFGInt, *tmpX, *aFGInt = [ellipticC a], *bFGInt = [ellipticC b], *pFGInt = [ellipticC p];
    xFGInt = [[FGInt alloc] initWithFGIntBase: 1];

    NSDictionary *tmpDiv = [FGInt divide: [ellipticC curveOrder] by: rFGInt];
    FGInt *kFGInt = [[tmpDiv objectForKey: quotientKey] retain];
    [tmpDiv release];
    while (!constructed) {
        switch (cmd) {
            case 1:
                tmpB = [[FGInt alloc] initWithFGIntBase: 0];
                tmpFGInt = [FGInt multiply: aFGInt and: xFGInt];
                tmpA = [FGInt mod: tmpFGInt by: pFGInt];
                [tmpFGInt release];
                break;
            case 3:
                tmpA = [[FGInt alloc] initWithFGIntBase: 0];
                tmpFGInt = [FGInt multiply: bFGInt and: xFGInt];
                tmpB = [FGInt mod: tmpFGInt by: pFGInt];
                [tmpFGInt release];
                break;
            default:
                tmpFGInt = [FGInt square: xFGInt];
                tmpX = [FGInt multiply: tmpFGInt and: aFGInt];
                tmpA = [FGInt mod: tmpX by: pFGInt];
                [tmpX release];
                tmpX = [FGInt multiply: tmpFGInt and: bFGInt];
                tmpFGInt = [FGInt multiply: tmpX and: xFGInt];
                [tmpX release];
                tmpB = [FGInt mod: tmpFGInt by: pFGInt];
                [tmpFGInt release];
                break;
        }
        tmpG = [[ECPoint alloc] init];
        [tmpG setX: [[FGInt alloc] initWithFGIntBase: 1]];
        [tmpG setY: [[FGInt alloc] initWithFGIntBase: 1]];
        [tmpG setInfinity: NO];
        EllipticCurve *ec = [[EllipticCurve alloc] init];
        [ec setA: tmpA];
        [ec setB: tmpB];
        [ec setP: [pFGInt retain]];
        [ec setCurveOrder: [[ellipticC curveOrder] retain]];
        [tmpG setEllipticCurve: ec];
        [ec release];
        
        [tmpG findNextECPoint];
        result = [ECPoint add: tmpG kTimes: kFGInt];
        while ( [result infinity] ) {
            [tmpG findNextECPoint];
            [result release];
            result = [ECPoint add: tmpG kTimes: kFGInt];
        }
        tmpG = [ECPoint add: result kTimes: rFGInt];
        if ( [tmpG infinity] ) {
            constructed = YES;
            [result setPointOrder: [rFGInt retain]];
        } else {
            [result release];
        }
        [tmpG release];
        [xFGInt increment];
    }
    [kFGInt release];
    [xFGInt release];
    return result;
}



+(ECPoint *) constructCurveAndPointMod: (FGInt *) pFGInt ofLeastOrder: (FGIntOverflow) leastBitSize {
    NSArray *orders = [ECPoint possibleCurveOrderMod: pFGInt];
    if (!orders) {
        return nil;
    } 
    unsigned char cmd = [[orders objectAtIndex: 0] unsignedCharValue];
    EllipticCurve *ec = [ECPoint constructCurveWithCMD: cmd];
    [ec setP: [pFGInt retain]];
    ECPoint *result = nil;
    FGInt *rFGInt = [[orders objectAtIndex: 1] isNearlyPrimeAndAtLeast: leastBitSize];
    if (rFGInt) {
        [ec setCurveOrder: [[orders objectAtIndex: 1] retain]];
        result = [ECPoint constructCurveAndPointWithOrder: rFGInt andCMD: cmd andCurve: ec];
        [rFGInt release];
    }
    if (!result) {
        rFGInt = [[orders objectAtIndex: 2] isNearlyPrimeAndAtLeast: leastBitSize];
        if (rFGInt) {
            [ec setCurveOrder: [[orders objectAtIndex: 2] retain]];
            result = [ECPoint constructCurveAndPointWithOrder: rFGInt andCMD: cmd andCurve: ec];
            [rFGInt release];
        }
    }
    if ((!result) && ((cmd == 1) || (cmd == 3))) {
        rFGInt = [[orders objectAtIndex: 3] isNearlyPrimeAndAtLeast: leastBitSize];
        if (rFGInt) {
            [ec setCurveOrder: [[orders objectAtIndex: 3] retain]];
            result = [ECPoint constructCurveAndPointWithOrder: rFGInt andCMD: cmd andCurve: ec];
            [rFGInt release];
        }
    }
    if ((!result) && ((cmd == 1) || (cmd == 3))) {
        rFGInt = [[orders objectAtIndex: 4] isNearlyPrimeAndAtLeast: leastBitSize];
        if (rFGInt) {
            [ec setCurveOrder: [[orders objectAtIndex: 4] retain]];
            result = [ECPoint constructCurveAndPointWithOrder: rFGInt andCMD: cmd andCurve: ec];
            [rFGInt release];
        }
    }
    if ((!result) && (cmd == 3)) {
        rFGInt = [[orders objectAtIndex: 5] isNearlyPrimeAndAtLeast: leastBitSize];
        if (rFGInt) {
            [ec setCurveOrder: [[orders objectAtIndex: 5] retain]];
            result = [ECPoint constructCurveAndPointWithOrder: rFGInt andCMD: cmd andCurve: ec];
            [rFGInt release];
        }
    }
    if ((!result) && (cmd == 3)) {
        rFGInt = [[orders objectAtIndex: 6] isNearlyPrimeAndAtLeast: leastBitSize];
        if (rFGInt) {
            [ec setCurveOrder: [[orders objectAtIndex: 6] retain]];
            result = [ECPoint constructCurveAndPointWithOrder: rFGInt andCMD: cmd andCurve: ec];
            [rFGInt release];
        }
    }
    [orders release];
    [ec release];
    return result;
}


-(BOOL) verifyFieldAndCurveOrderStrength {
    FGInt *tmpFGInt = [[FGInt alloc] initWithFGIntBase: 1], *p = [[self ellipticCurve] p], *one = [[FGInt alloc] initWithFGIntBase: 1], *modN, *tmpFGInt1;

    if ([FGInt compareAbsoluteValueOf: p with: pointOrder] == equal) {
        [one release];
        [tmpFGInt release];
        return NO;
    }
    
    for ( FGIntBase i = 0; i < 100; ++i ) {
        tmpFGInt1 = [FGInt multiply: tmpFGInt and: p];
        [tmpFGInt release];
        modN = [FGInt mod: tmpFGInt1 by: [self pointOrder]];
        [tmpFGInt1 release];
        tmpFGInt = modN;
        if ([FGInt compareAbsoluteValueOf: modN with: one] == equal) {
            [one release];
            [tmpFGInt release];
            return NO;
        }
    }
    [one release];
    [tmpFGInt release];

    return YES;
}

+(ECPoint *) generateSecureCurveAndPointOfSize: (FGIntOverflow) gFpSize {
    FGIntOverflow leastOrder;

    FGInt *pFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: gFpSize];

    FGIntBase rmTests = 4;
    if (gFpSize < 460) rmTests = 7;
    if (gFpSize < 300) rmTests = 13;
    if (gFpSize < 260) rmTests = 19;
    if (gFpSize < 200) rmTests = 29;
    if (gFpSize < 160) rmTests = 37;

    ECPoint *result = nil;
    leastOrder = gFpSize - 32;
    if (gFpSize < 511) leastOrder = gFpSize - 24;
    if (gFpSize < 384) leastOrder = gFpSize - 16;
    if (gFpSize < 256) leastOrder = gFpSize - 14;
    if (gFpSize < 224) leastOrder = gFpSize - 10;

    while (!result) {
        [pFGInt findNearestLargerPrimeWithRabinMillerTests: rmTests];
        result = [ECPoint constructCurveAndPointMod: pFGInt ofLeastOrder: leastOrder];
        if ([[result ellipticCurve] isSuperSingular]) {
            [result release];
            result = nil;
        }
        if (result) {
            if (![result verifyFieldAndCurveOrderStrength]) {
                [result release];
                result = nil;
            }
        }
    }
    return result;
}


@end