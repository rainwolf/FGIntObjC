#import "BN256.h"





// quadratic non-residue -1, GFp^2 = GF(p)[X] / (X^2 + 1)
// i^2 = -1
// a + bX 


@implementation GFP2
@synthesize a, b, p;


-(id) init {
    if (self = [super init]) {
    	a = nil;
    	b = nil;
    	p = nil;
    }
    return self;
}
-(id) initOne {
    if (self = [super init]) {
    	a = [[FGInt alloc] initWithFGIntBase: 1];
    	b = [[FGInt alloc] initAsZero];
		p = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray[8] = pNumber;
		[p setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
    }
    return self;
}
-(id) initZero {
    if (self = [super init]) {
    	a = [[FGInt alloc] initAsZero];
    	b = [[FGInt alloc] initAsZero];
		p = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray[8] = pNumber;
		[p setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
    }
    return self;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 2*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSData *tmpData = [[NSData alloc] initWithBytes: &bytes[cnstLength] length: cnstLength];
    	a = [[FGInt alloc] initWithBigEndianNSData: tmpData];
    	[tmpData release];
		tmpData = [[NSData alloc] initWithBytes: bytes length: cnstLength];
    	b = [[FGInt alloc] initWithBigEndianNSData: tmpData];
    	[tmpData release];
		p = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray[8] = pNumber;
		[p setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
    }
    return self;
}
-(void) dealloc {
    [a release];
    [b release];
    [p release];
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
    GFP2 *newGFP2 = [[GFP2 allocWithZone: zone] init];

    [newGFP2 setA: [a mutableCopy]];
    [newGFP2 setB: [b mutableCopy]];
    [newGFP2 setP: [p retain]];

    return newGFP2;
}
-(void) changeSign {
	[a changeSign];
	[b changeSign];
}
-(BOOL) isZero {
	if ([a isZero] && [b isZero]) {
		return YES;
	}
	return NO;
}
-(void) conjugate {
	[b changeSign];
}

+(GFP2 *) add: (GFP2 *) p1 and: (GFP2 *) p2 {
	GFP2 *sum = [[GFP2 alloc] init];
	FGInt *p = [p1 p];

	FGInt *tmpFGInt;
	tmpFGInt = [FGInt add: [p1 a] and: [p2 a]];
	[tmpFGInt reduceBySubtracting: p atMost: 1];
	[sum setA: tmpFGInt];
	tmpFGInt = [FGInt add: [p1 b] and: [p2 b]];
	[tmpFGInt reduceBySubtracting: p atMost: 1];
	[sum setB: tmpFGInt];
	[sum setP: [p retain]];

	return sum;
}

+(GFP2 *) subtract: (GFP2 *) p1 and: (GFP2 *) p2 {
	GFP2 *sum = [[GFP2 alloc] init];
	FGInt *p = [p1 p];

	FGInt *tmpFGInt;
	tmpFGInt = [FGInt subtract: [p1 a] and: [p2 a]];
	[tmpFGInt reduceBySubtracting: p atMost: 1];
	[sum setA: tmpFGInt];
	tmpFGInt = [FGInt subtract: [p1 b] and: [p2 b]];
	[tmpFGInt reduceBySubtracting: p atMost: 1];
	[sum setB: tmpFGInt];
	[sum setP: [p retain]];

	return sum;
}

+(GFP2 *) multiply: (GFP2 *) p1 and: (GFP2 *) p2 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *product = [[GFP2 alloc] init];
	FGInt *p = [p1 p];

	FGInt *tmp = [FGInt multiply: [p1 a] and: [p2 a]];
	FGInt *v0 = [FGInt barrettMod: tmp by: p with: invertedP andPrecision: precision];
	tmp = [FGInt multiply: [p1 b] and: [p2 b]];
	FGInt *v1 = [FGInt barrettMod: tmp by: p with: invertedP andPrecision: precision],
		*tmp1 = [[FGInt add: [p1 a] and: [p1 b]] reduceBySubtracting: p atMost: 1], 
		*tmp2 = [[FGInt add: [p2 a] and: [p2 b]] reduceBySubtracting: p atMost: 1];

	tmp = [FGInt multiply: tmp1 and: tmp2];
	[tmp2 release];
	FGInt *tmp0 = [FGInt barrettMod: tmp by: p with: invertedP andPrecision: precision];
	[tmp release];
	tmp1 = [[FGInt subtract: tmp0 and: v0] reduceBySubtracting: p atMost: 1];
	[tmp0 release];

	[product setB: [[FGInt subtract: tmp1 and: v1] reduceBySubtracting: p atMost: 1]];
	[tmp1 release];
	[product setA: [[FGInt subtract: v0 and: v1] reduceBySubtracting: p atMost: 1]];
	[v0 release];
	[v1 release];
	[product setP: [p retain]];

	return product;
}

+(GFP2 *) square: (GFP2 *) p1 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *square = [[GFP2 alloc] init];
	FGInt *p = [p1 p];

	FGInt *tmp = [FGInt multiply: [p1 a] and: [p1 b]],
		*tmp1 = [[FGInt add: [p1 a] and: [p1 b]] reduceBySubtracting: p atMost: 1], *tmp2 = [[FGInt subtract: [p1 a] and: [p1 b]] reduceBySubtracting: p atMost: 1];
	FGInt *v0 = [FGInt barrettMod: tmp by: p with: invertedP andPrecision: precision];
	[tmp release];
	tmp = [FGInt multiply: tmp1 and: tmp2];
	[tmp1 release];
	[tmp2 release];

	[square setA: [FGInt barrettMod: tmp by: p with: invertedP andPrecision: precision]];
	[tmp release];

	[v0 shiftLeft];
	[square setB: [v0 reduceBySubtracting: p atMost: 1]];
	[square setP: [p retain]];

	return square;
}

+(GFP2 *) multiplyByResiduePlus3: (GFP2 *) p1 {
	GFP2 *product = [[GFP2 alloc] init];
	FGInt *p = [p1 p];

	FGInt *tmp = [[p1 a] mutableCopy];
	[tmp multiplyByInt: 3];
	[product setA: [[FGInt subtract: tmp and: [p1 b]] reduceBySubtracting: p atMost: 4]];
	[tmp release];
	tmp = [[p1 b] mutableCopy];
	[tmp multiplyByInt: 3];
	[product setB: [[FGInt add: tmp and: [p1 a]] reduceBySubtracting: p atMost: 4]];
	[product setP: [p retain]];

	return product;
}

-(void) shiftLeft {
	[a shiftLeft];
	[a reduceBySubtracting: p atMost: 1];
	[b shiftLeft];
	[b reduceBySubtracting: p atMost: 1];
}

-(void) shiftRight {
	if (![a isEven]) {
		[a addWith: p];
	}
	[a shiftRight];
	if (![b isEven]) {
		[b addWith: p];
	}
	[b shiftRight];
}

-(void) multiplyByInt: (unsigned char) c {
	[a multiplyByInt: c];
	[a reduceBySubtracting: p atMost: c];
	[b multiplyByInt: c];
	[b reduceBySubtracting: p atMost: c];
}

-(void) multiplyByFGInt: (FGInt *) fGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *tmp = [FGInt multiply: a and: fGInt];
	[a release];
	a = [FGInt barrettMod: tmp by: p with: invertedP andPrecision: precision];
	[tmp release];
	tmp = [FGInt multiply: b and: fGInt];
	[b release];
	b = [FGInt barrettMod: tmp by: p with: invertedP andPrecision: precision];
	[tmp release];
}


-(GFP2 *) invertWithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGInt *tmp1 = [FGInt square: a];
	FGInt* tmp2 = [FGInt barrettMod: tmp1 by: p with: invertedP andPrecision: precision];
	[tmp1 release];

	tmp1 = [FGInt square: b];
	FGInt* tmp = [FGInt barrettMod: tmp1 by: p with: invertedP andPrecision: precision];
	[tmp1 release];

	[tmp addWith: tmp2];
	[tmp2 release];
	[tmp reduceBySubtracting: p atMost: 1];

	FGInt *denominator = [FGInt invert: tmp moduloPrime: p];
	[tmp release];

	tmp = [FGInt multiply: a and: denominator];

	GFP2 *inverted = [[GFP2 alloc] init];
	[inverted setA: [FGInt barrettMod: tmp by: p with: invertedP andPrecision: precision]];
	[tmp release];

	tmp = [FGInt multiply: b and: denominator];
	[tmp changeSign];
	[inverted setB: [FGInt barrettMod: tmp by: p with: invertedP andPrecision: precision]];
	[tmp release];

	[inverted setP: [p retain]];

	return inverted;
}



+(GFP2 *) raise: (GFP2 *) gfp2 toThePower: (FGInt *) fGIntN withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    GFP2 *power = [[GFP2 alloc] initOne];
    FGIntOverflow nLength = [[fGIntN number] length]/4;
    FGIntBase tmpWord;
    GFP2 *tmp1, *tmp;
    FGIntBase* nFGIntNumber = [[fGIntN number] mutableBytes];

    tmp1 = [gfp2 retain];

    for( FGIntIndex i = 0; i < nLength - 1; i++ ) {
        tmpWord = nFGIntNumber[i];
        for( FGIntIndex j = 0; j < 32; ++j ) {
            if ((tmpWord % 2) == 1) {
                tmp = [GFP2 multiply: power and: tmp1 withInvertedP: invertedP andPrecision: precision];
                [power release];
                power = tmp;
            }
            tmp = [GFP2 square: tmp1 withInvertedP: invertedP andPrecision: precision];
            [tmp1 release];
            tmp1 = tmp;
            tmpWord >>= 1;
        }
    }
    tmpWord = nFGIntNumber[nLength - 1];
    while(tmpWord != 0) {
        if ((tmpWord % 2) == 1) {
            tmp = [GFP2 multiply: power and: tmp1 withInvertedP: invertedP andPrecision: precision];
            [power release];
            power = tmp;
        }
        tmpWord >>= 1;
        if (tmpWord != 0) {
            tmp = [GFP2 square: tmp1 withInvertedP: invertedP andPrecision: precision];
            [tmp1 release];
            tmp1 = tmp;
        }
    }
    
    [tmp1 release];
    
    return power;
}


-(NSString *) toBase10String {
	NSMutableString *base10String = [[NSMutableString alloc] init];
	FGInt *tmp = [FGInt longDivisionMod: a by: p];
	NSString *tmpStr = [tmp toBase10String];
	// [tmp release];
	[a release];
	a = tmp;
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @" + "];
	tmp = [FGInt longDivisionMod: b by: p];
	tmpStr = [tmp toBase10String];
	[b release];
	b = tmp;
	// [tmp release];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @"i"];

	return base10String;	
}

-(NSData *) marshal {
	if ((a == nil) || (b == nil)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] init];
	FGInt *tmp = [FGInt longDivisionMod: b by: p];
	NSData *tmpData = [tmp toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];
	tmp = [FGInt longDivisionMod: a by: p];
	tmpData = [tmp toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}


@end







// cubic non-residue b = i+3, GFp^6 = GFp^2[X] / (X^3 - b)
// a + bX + cX^2


@implementation GFP6
@synthesize a, b, c;


-(id) init {
    if (self = [super init]) {
    	a = nil;
    	b = nil;
    	c = nil;
    }
    return self;
}
-(id) initOne {
    if (self = [super init]) {
    	a = [[GFP2 alloc] initOne];
    	b = [[GFP2 alloc] initZero];
    	c = [[GFP2 alloc] initZero];
    }
    return self;
}
-(id) initZero {
    if (self = [super init]) {
    	a = [[GFP2 alloc] initZero];
    	b = [[GFP2 alloc] initZero];
    	c = [[GFP2 alloc] initZero];
    }
    return self;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 6*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: &bytes[4*cnstLength] length: 2*cnstLength];
    	a = [[GFP2 alloc] unMarshal: tmpData];
		[tmpData release];
    	tmpData = [[NSMutableData alloc] initWithBytes: &bytes[2*cnstLength] length: 2*cnstLength];
    	b = [[GFP2 alloc] unMarshal: tmpData];
		[tmpData release];
		tmpData = [[NSMutableData alloc] initWithBytes: bytes length: 2*cnstLength];
    	c = [[GFP2 alloc] unMarshal: tmpData];
		[tmpData release];
    }
    return self;
}
-(void) dealloc {
    [a release];
    [b release];
    [c release];
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
    GFP6 *newGFP6 = [[GFP6 allocWithZone: zone] init];

    [newGFP6 setA: [a mutableCopy]];
    [newGFP6 setB: [b mutableCopy]];
    [newGFP6 setC: [c mutableCopy]];

    return newGFP6;
}
-(void) changeSign {
	[a changeSign];
	[b changeSign];
	[c changeSign];
}
-(BOOL) isZero {
	if ([a isZero] && [b isZero] && [c isZero]) {
		return YES;
	}
	return NO;
}


+(GFP6 *) add: (GFP6 *) p1 and: (GFP6 *) p2 {
	GFP6 *sum = [[GFP6 alloc] init];

	GFP2 *tmp;
	tmp = [GFP2 add: [p1 a] and: [p2 a]];
	[sum setA: tmp];
	tmp = [GFP2 add: [p1 b] and: [p2 b]];
	[sum setB: tmp];
	tmp = [GFP2 add: [p1 c] and: [p2 c]];
	[sum setC: tmp];

	return sum;
}

+(GFP6 *) subtract: (GFP6 *) p1 and: (GFP6 *) p2 {
	GFP6 *sum = [[GFP6 alloc] init];

	GFP2 *tmp;
	tmp = [GFP2 subtract: [p1 a] and: [p2 a]];
	[sum setA: tmp];
	tmp = [GFP2 subtract: [p1 b] and: [p2 b]];
	[sum setB: tmp];
	tmp = [GFP2 subtract: [p1 c] and: [p2 c]];
	[sum setC: tmp];

	return sum;
}

+(GFP6 *) multiply: (GFP6 *) p1 and: (GFP6 *) p2 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP6 *product = [[GFP6 alloc] init];

	GFP2 *v0 = [GFP2 multiply: [p1 a] and: [p2 a] withInvertedP: invertedP andPrecision: precision];
	GFP2 *v1 = [GFP2 multiply: [p1 b] and: [p2 b] withInvertedP: invertedP andPrecision: precision];
	GFP2 *v2 = [GFP2 multiply: [p1 c] and: [p2 c] withInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp1 = [GFP2 add: [p1 b] and: [p1 c]];
	GFP2 *tmp2 = [GFP2 add: [p2 b] and: [p2 c]];
	GFP2 *tmp = [GFP2 multiply: tmp1 and: tmp2 withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP2 subtract: tmp and: v1];
	[tmp release];
	tmp2 = [GFP2 subtract: tmp1 and: v2];
	[tmp1 release];
	tmp = [GFP2 multiplyByResiduePlus3: tmp2];
	[tmp2 release];
	[product setA: [GFP2 add: v0 and: tmp]];
	[tmp release];

	tmp1 = [GFP2 add: [p1 b] and: [p1 a]];
	tmp2 = [GFP2 add: [p2 b] and: [p2 a]];
	tmp = [GFP2 multiply: tmp1 and: tmp2 withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP2 subtract: tmp and: v1];
	[tmp release];
	tmp2 = [GFP2 subtract: tmp1 and: v0];
	[tmp1 release];
	tmp = [GFP2 multiplyByResiduePlus3: v2];
	[product setB: [GFP2 add: tmp2 and: tmp]];
	[tmp2 release];
	[tmp release];

	tmp1 = [GFP2 add: [p1 c] and: [p1 a]];
	tmp2 = [GFP2 add: [p2 c] and: [p2 a]];
	tmp = [GFP2 multiply: tmp1 and: tmp2 withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP2 subtract: tmp and: v2];
	[tmp release];
	tmp2 = [GFP2 subtract: tmp1 and: v0];
	[tmp1 release];
	[product setC: [GFP2 add: tmp2 and: v1]];
	[tmp2 release];

	[v0 release];
	[v1 release];
	[v2 release];

	return product;
}

+(GFP6 *) square: (GFP6 *) p1 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP6 *square = [[GFP6 alloc] init];

	GFP2 *p1a = [p1 a], *p1b = [p1 b], *p1c = [p1 c];

	GFP2 *s0 = [GFP2 square: p1a withInvertedP: invertedP andPrecision: precision];
	GFP2 *s4 = [GFP2 square: p1c withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp1 = [GFP2 add: p1a and: p1c];
	GFP2 *tmp2 = [GFP2 add: tmp1 and: p1b];
	GFP2 *s1 = [GFP2 square: tmp2 withInvertedP: invertedP andPrecision: precision];
	[tmp2 release];
	tmp2 = [GFP2 subtract: tmp1 and: p1b];
	GFP2 *s2 = [GFP2 square: tmp2 withInvertedP: invertedP andPrecision: precision];
	[tmp2 release];
	[tmp1 release];
	GFP2 *s3 = [GFP2 multiply: p1b and: p1c withInvertedP: invertedP andPrecision: precision];
	[s3 shiftLeft];
	GFP2 *t1 = [GFP2 add: s1 and: s2];
	[t1 shiftRight];

	tmp1 = [GFP2 multiplyByResiduePlus3: s3];
	[square setA: [GFP2 add: tmp1 and: s0]];
	[tmp1 release];

	tmp1 = [GFP2 multiplyByResiduePlus3: s4];
	tmp2 = [GFP2 add: tmp1 and: s1];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp2 and: s3];
	[tmp2 release];
	[square setB: [GFP2 subtract: tmp1 and: t1]];
	[tmp1 release];

	tmp1 = [GFP2 subtract: t1 and: s0];
	[square setC: [GFP2 subtract: tmp1 and: s4]];
	[tmp1 release];

	[s0 release];
	[s1 release];
	[s2 release];
	[s3 release];
	[s4 release];
	[t1 release];

	return square;
}


-(GFP6 *) multiplyByRoot {
	GFP2 *tmp = [GFP2 multiplyByResiduePlus3: c];
	[c release];
	c = b;
	b = a;
	a = tmp;

	return self;
}

-(void) shiftLeft {
	[a shiftLeft];
	[b shiftLeft];
	[c shiftLeft];
}

-(void) multiplyByFGInt: (FGInt *) fGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a multiplyByFGInt: fGInt withInvertedP: invertedP andPrecision: precision];
	[b multiplyByFGInt: fGInt withInvertedP: invertedP andPrecision: precision];
	[c multiplyByFGInt: fGInt withInvertedP: invertedP andPrecision: precision];
}

-(void) multiplyByGFP2: (GFP2 *) gfp2 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *tmp = [GFP2 multiply: a and: gfp2 withInvertedP: invertedP andPrecision: precision];
	[a release];
	a = tmp;
	tmp = [GFP2 multiply: b and: gfp2 withInvertedP: invertedP andPrecision: precision];
	[b release];
	b = tmp;
	tmp = [GFP2 multiply: c and: gfp2 withInvertedP: invertedP andPrecision: precision];
	[c release];
	c = tmp;
}


-(GFP6 *) invertWithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP6 *iGFP6 = [[GFP6 alloc] init];

	GFP2 *tmp = [GFP2 square: a withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp1 = [GFP2 multiply: c and: b withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp2 = [GFP2 multiplyByResiduePlus3: tmp1];
	[tmp1 release];
	[iGFP6 setA: [GFP2 subtract: tmp and: tmp2]];
	[tmp release];
	[tmp2 release];

	tmp = [GFP2 square: c withInvertedP: invertedP andPrecision: precision];
	tmp2 = [GFP2 multiplyByResiduePlus3: tmp];
	[tmp release];
	tmp1 = [GFP2 multiply: a and: b withInvertedP: invertedP andPrecision: precision];
	[iGFP6 setB: [GFP2 subtract: tmp2 and: tmp1]];
	[tmp1 release];
	[tmp2 release];

	tmp = [GFP2 square: b withInvertedP: invertedP andPrecision: precision];
	tmp1 = [GFP2 multiply: a and: c withInvertedP: invertedP andPrecision: precision];
	[iGFP6 setC: [GFP2 subtract: tmp and: tmp1]];
	[tmp release];
	[tmp1 release];

	tmp1 = [GFP2 multiply: a and: [iGFP6 a] withInvertedP: invertedP andPrecision: precision];
	tmp2 = [GFP2 multiply: c and: [iGFP6 b] withInvertedP: invertedP andPrecision: precision];
	tmp = [GFP2 multiplyByResiduePlus3: tmp2];
	[tmp2 release];
	tmp2 = [GFP2 add: tmp1 and: tmp];
	[tmp release];
	[tmp1 release];
	tmp1 = [GFP2 multiply: b and: [iGFP6 c] withInvertedP: invertedP andPrecision: precision];
	tmp = [GFP2 multiplyByResiduePlus3: tmp1];
	[tmp1 release];
	tmp1 = [GFP2 add: tmp2 and: tmp];
	[tmp2 release];
	[tmp release];
	tmp = [tmp1 invertWithInvertedP: invertedP andPrecision: precision];
	[tmp1 release];

	tmp1 = [GFP2 multiply: [iGFP6 a] and: tmp withInvertedP: invertedP andPrecision: precision];
	[[iGFP6 a] release];
	[iGFP6 setA: tmp1];
	tmp1 = [GFP2 multiply: [iGFP6 b] and: tmp withInvertedP: invertedP andPrecision: precision];
	[[iGFP6 b] release];
	[iGFP6 setB: tmp1];
	tmp1 = [GFP2 multiply: [iGFP6 c] and: tmp withInvertedP: invertedP andPrecision: precision];
	[[iGFP6 c] release];
	[iGFP6 setC: tmp1];

	[tmp release];

	return iGFP6;
}


-(void) frobeniusWithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a conjugate];
	[b conjugate];
	[c conjugate];

	GFP2 *tmp = [[GFP2 alloc] init];
	FGIntBase numberArray1[8] = iPlus3To2Pm2o3aNumber;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray2[8] = iPlus3To2Pm2o3bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
	[tmp setB: tmpFGInt];
	[tmp setP: [[a p] retain]];

	GFP2 *tmp0 = [GFP2 multiply: c and: tmp withInvertedP: invertedP andPrecision: precision];
	[tmp release];
	[c release];
	c = tmp0;

	tmp = [[GFP2 alloc] init];
	FGIntBase numberArray3[8] = iPlus3ToPm1o3aNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray3 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray4[8] = iPlus3ToPm1o3bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray4 length: cnstLength]];
	[tmp setB: tmpFGInt];
	[tmp setP: [[a p] retain]];

	tmp0 = [GFP2 multiply: b and: tmp withInvertedP: invertedP andPrecision: precision];
	[tmp release];
	[b release];
	b = tmp0;
}

-(void) frobenius2WithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	FGIntBase numberArray1[8] = iPlus3To2Psm2o3Number;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: cnstLength]];
	[c multiplyByFGInt: tmpFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];

	FGIntBase numberArray2[8] = iPlus3ToPsm1o3Number;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
	[b multiplyByFGInt: tmpFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];
}



-(NSString *) toBase10String {
	NSMutableString *base10String = [[NSMutableString alloc] init];
	NSString *tmpStr = [a toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @"\n + ("];
	tmpStr = [b toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")b\n + ("];
	tmpStr = [c toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")b^2"];

	return base10String;	
}


-(NSData *) marshal {
	if ((a == nil) || (b == nil) || (c == nil)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [c marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [b marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [a marshal];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}




@end









// a + bX 


@implementation GFP12
@synthesize a, b;


-(id) init {
    if (self = [super init]) {
    	a = nil;
    	b = nil;
    }
    return self;
}
-(id) initOne {
    if (self = [super init]) {
    	a = [[GFP6 alloc] initOne];
    	b = [[GFP6 alloc] initZero];
    }
    return self;
}
-(id) initZero {
    if (self = [super init]) {
    	a = [[GFP6 alloc] initZero];
    	b = [[GFP6 alloc] initZero];
    }
    return self;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 12*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: &bytes[6*cnstLength] length: 6*cnstLength];
    	a = [[GFP6 alloc] unMarshal: tmpData];
		[tmpData release];
		tmpData = [[NSMutableData alloc] initWithBytes: bytes length: 6*cnstLength];
    	b = [[GFP6 alloc] unMarshal: tmpData];
		[tmpData release];
    }
    return self;
}
-(void) dealloc {
    [a release];
    [b release];
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
    GFP12 *newGFP12 = [[GFP12 allocWithZone: zone] init];

    [newGFP12 setA: [a mutableCopy]];
    [newGFP12 setB: [b mutableCopy]];

    return newGFP12;
}
-(void) conjugate {
	[b changeSign];
}
-(void) changeSign {
	[a changeSign];
	[b changeSign];
}
-(BOOL) isZero {
	if ([a isZero] && [b isZero]) {
		return YES;
	}
	return NO;
}

+(GFP12 *) add: (GFP12 *) p1 and: (GFP12 *) p2 {
	GFP12 *sum = [[GFP12 alloc] init];

	[sum setA: [GFP6 add: [p1 a] and: [p2 a]]];
	[sum setB: [GFP6 add: [p1 b] and: [p2 b]]];

	return sum;
}

+(GFP12 *) subtract: (GFP12 *) p1 and: (GFP12 *) p2 {
	GFP12 *sum = [[GFP12 alloc] init];

	[sum setA: [GFP6 subtract: [p1 a] and: [p2 a]]];
	[sum setB: [GFP6 subtract: [p1 b] and: [p2 b]]];

	return sum;
}

+(GFP12 *) multiply: (GFP12 *) p1 and: (GFP12 *) p2 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP12 *product = [[GFP12 alloc] init];

	GFP6 *v0 = [GFP6 multiply: [p1 a] and: [p2 a] withInvertedP: invertedP andPrecision: precision];
	GFP6 *v1 = [GFP6 multiply: [p1 b] and: [p2 b] withInvertedP: invertedP andPrecision: precision];
	GFP6 *tmp1 = [GFP6 add: [p1 a] and: [p1 b]], *tmp2 = [GFP6 add: [p2 a] and: [p2 b]];

	GFP6 *tmp = [GFP6 multiply: tmp1 and: tmp2 withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP6 subtract: tmp and: v0];
	[tmp release];
	[product setB: [GFP6 subtract: tmp1 and: v1]];
	[tmp1 release];

	[v1 multiplyByRoot];
	[product setA: [GFP6 add: v0 and: v1]];
	[v0 release];
	[v1 release];

	return product;
}

-(void) multiplyByFGInt: (FGInt *) fGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a multiplyByFGInt: fGInt withInvertedP: invertedP andPrecision: precision];
	[b multiplyByFGInt: fGInt withInvertedP: invertedP andPrecision: precision];
}


+(GFP12 *) square: (GFP12 *) p1 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP12 *square = [[GFP12 alloc] init];

	GFP6 *p1a = [p1 a], *p1b = [p1 b];

	GFP6 *v0 = [GFP6 multiply: p1a and: p1b withInvertedP: invertedP andPrecision: precision],
		*tmp1 = [GFP6 add: p1a and: p1b], *tmp = [p1b mutableCopy];
	[tmp multiplyByRoot];
	GFP6 *tmp2 = [GFP6 add: p1a and: tmp];
	[tmp release];
	tmp = [GFP6 multiply: tmp1 and: tmp2 withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp2 release];
	tmp1 = [GFP6 subtract: tmp and: v0];
	[tmp release];
	tmp = [v0 mutableCopy];
	[tmp multiplyByRoot];

	[square setA: [GFP6 subtract: tmp1 and: tmp]];
	[tmp1 release];
	[tmp release];

	[v0 shiftLeft];
	[square setB: v0];

	return square;
}

-(void) frobeniusWithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a frobeniusWithInvertedP: invertedP andPrecision: precision];
	[b frobeniusWithInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp = [[GFP2 alloc] init];
	FGIntBase numberArray1[8] = iPlus3ToPm1o6aNumber;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray2[8] = iPlus3ToPm1o6bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
	[tmp setB: tmpFGInt];
	[tmp setP: [[[a a] p] retain]];

	[b multiplyByGFP2: tmp withInvertedP: invertedP andPrecision: precision];
	[tmp release];
}

-(void) frobenius2WithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	[a frobenius2WithInvertedP: invertedP andPrecision: precision];
	[b frobenius2WithInvertedP: invertedP andPrecision: precision];

	FGIntBase numberArray[8] = iPlus3ToPsm1o6Number;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
	[b multiplyByFGInt: tmpFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];
}

-(GFP12 *) invertWithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP12 *iGFP12 = [[GFP12 alloc] init];

	GFP6 *tmp1 = [GFP6 square: a withInvertedP: invertedP andPrecision: precision];
	GFP6 *tmp2 = [GFP6 square: b withInvertedP: invertedP andPrecision: precision];
	[tmp2 multiplyByRoot];

	GFP6 *tmp = [GFP6 subtract: tmp1 and: tmp2];
	[tmp1 release];
	[tmp2 release];
	GFP6 *denominator = [tmp invertWithInvertedP: invertedP andPrecision: precision];
	[tmp release];

	tmp = [GFP6 multiply: a and: denominator withInvertedP: invertedP andPrecision: precision];
	[iGFP12 setA: tmp];
	tmp = [GFP6 multiply: b and: denominator withInvertedP: invertedP andPrecision: precision];
	[tmp changeSign];
	[iGFP12 setB: tmp];

	return iGFP12;
}
-(GFP12 *) invert {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArrayP[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength + 4]];

	GFP12 *tmp = [self invertWithInvertedP: invertedP andPrecision: precision];
	[invertedP release];

	return tmp;
}

+(GFP12 *) raise: (GFP12 *) gfp12 toThePower: (FGInt *) fGIntN withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    GFP12 *power = [[GFP12 alloc] initOne];
    FGIntOverflow nLength = [[fGIntN number] length]/4;
    FGIntBase tmpWord;
    GFP12 *tmp1, *tmp;
    FGIntBase* nFGIntNumber = [[fGIntN number] mutableBytes];

    tmp1 = [gfp12 retain];

    for( FGIntIndex i = 0; i < nLength - 1; i++ ) {
        tmpWord = nFGIntNumber[i];
        for( FGIntIndex j = 0; j < 32; ++j ) {
            if ((tmpWord % 2) == 1) {
                tmp = [GFP12 multiply: power and: tmp1 withInvertedP: invertedP andPrecision: precision];
                [power release];
                power = tmp;
            }
            tmp = [GFP12 square: tmp1 withInvertedP: invertedP andPrecision: precision];
            [tmp1 release];
            tmp1 = tmp;
            tmpWord >>= 1;
        }
    }
    tmpWord = nFGIntNumber[nLength - 1];
    while(tmpWord != 0) {
        if ((tmpWord % 2) == 1) {
            tmp = [GFP12 multiply: power and: tmp1 withInvertedP: invertedP andPrecision: precision];
            [power release];
            power = tmp;
        }
        tmpWord >>= 1;
        if (tmpWord != 0) {
            tmp = [GFP12 square: tmp1 withInvertedP: invertedP andPrecision: precision];
            [tmp1 release];
            tmp1 = tmp;
        }
    }
    
    [tmp1 release];
    
    return power;
}



-(NSString *) toBase10String {
	NSMutableString *base10String = [[NSMutableString alloc] init];
	NSString *tmpStr = [a toBase10String];
	[base10String appendString: @"("];
	[base10String appendString: tmpStr];
	[base10String appendString: @")"];
	[tmpStr release];
	[base10String appendString: @"\n + ("];
	tmpStr = [b toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")w"];

	return base10String;	
}

-(NSData *) marshal {
	if ((a == nil) || (b == nil)) {
		return nil;
	}
	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [b marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [a marshal];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}


@end











@implementation G2Point
@synthesize x, y, z, t;
@synthesize infinity;


-(id) init {
    if (self = [super init]) {
    	x = nil;
    	y = nil;
    	z = nil;
    	t = nil;
    	infinity = NO;
    }
    return self;
}
-(id) initInfinity {
    if (self = [super init]) {
    	x = nil;
    	y = nil;
    	z = nil;
    	t = nil;
    	infinity = YES;
    }
    return self;
}
-(id) initGenerator {
    if (self = [super init]) {
    	FGInt *p = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray[] = pNumber;
		[p setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

		FGInt *tmpFGInt;
		x = [[GFP2 alloc] init];
		tmpFGInt = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray1[] = {395465548u, 730492372u, 1573759699u, 3111621141u, 2921370308u, 2170125669u, 1925793323u, 2401581167u};
		[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: cnstLength]];
		[x setA: tmpFGInt];
		tmpFGInt = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray2[] = {3273939312u, 938160865u, 3406146634u, 3157767012u, 1551183656u, 63401627u, 4285480269u, 785163334u};
		[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
		[x setB: tmpFGInt];
		[x setP: [p retain]];
		y = [[GFP2 alloc] init];
		tmpFGInt = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray3[] = {3190851493u, 1766072483u, 3258878351u, 789467123u, 2581297586u, 924241030u, 3905616588u, 659445575u};
		[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray3 length: cnstLength]];
		[y setA: tmpFGInt];
		tmpFGInt = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray4[] = {2402402066u, 3751226898u, 4082187586u, 3185580628u, 2763768501u, 2519441126u, 591073251u, 766578421u};
		[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray4 length: cnstLength]];
		[y setB: tmpFGInt];
		[y setP: [p retain]];
    	z = nil;
    	infinity = NO;
    }
    return self;
}
-(id) initRandomPoint {
	FGInt *order = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = nNumber;
	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	FGInt *tmpFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: cnstLength*8];
	FGInt *tmpModOrder = nil;
	if (tmpFGInt != nil) {
		tmpModOrder = [FGInt longDivisionMod: tmpFGInt by: order];
	} else {
		[order release];
		return nil;
	}

	G2Point *result = [G2Point addGeneratorKTimes: tmpModOrder];

	[tmpModOrder release];
	[order release];

	return result;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 4*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	const unsigned char* bytes = [marshalData bytes];
    	NSMutableData *tmpData = [[NSMutableData alloc] initWithBytes: &bytes[2*cnstLength] length: 2*cnstLength];
    	y = [[GFP2 alloc] unMarshal: tmpData];
		[tmpData release];
		tmpData = [[NSMutableData alloc] initWithBytes: bytes length: 2*cnstLength];
    	x = [[GFP2 alloc] unMarshal: tmpData];
		z = nil;
		[tmpData release];
		if ([x isZero] && [y isZero]) {
			infinity = YES;
		} else {
			infinity = NO;
		}
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
    if (z != nil) {
	    [z release];
    }
    if (t != nil) {
	    [t release];
    }
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
	if (infinity) {
		return [[G2Point alloc] initInfinity];
	}

    G2Point *newG2Point = [[G2Point allocWithZone: zone] init];

    [newG2Point setX: [x mutableCopy]];
    [newG2Point setY: [y mutableCopy]];
    if (z != nil) {
    	[newG2Point setZ: [z mutableCopy]];
    }
    if (t != nil) {
    	[newG2Point setT: [t mutableCopy]];
    }

    return newG2Point;
}
-(void) changeSign {
	if (!infinity) {
		[y changeSign];
	}
}
-(void) makeProjective {
	if (!infinity) {
		z = [[GFP2 alloc] initOne];
	}
}
-(void) makeExtendedProjective {
	if (!infinity) {
		z = [[GFP2 alloc] initOne];
		t = [z mutableCopy];
	}
}


+(G2Point *) add: (G2Point *) p1 and: (G2Point *) p2 {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength + 4]];

	G2Point *tmp0G2 = [p1 mutableCopy], *tmp1G2 = [p2 mutableCopy];
	[tmp0G2 makeProjective];
	[tmp1G2 makeProjective];

	G2Point *result = [G2Point projectiveAdd: tmp0G2 and: tmp1G2 withInvertedP: invertedP andPrecision: precision];
	[result makeAffineWithInvertedP: invertedP andPrecision: precision];

    [invertedP release];
    [tmp0G2 release];
    [tmp1G2 release];

    return result;
}


+(G2Point *) projectiveAdd: (G2Point *) p1 and: (G2Point *) p2 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([p1 infinity]) {
		return [p2 mutableCopy];
	}
	if ([p2 infinity]) {
		return [p1 mutableCopy];
	}

	G2Point *sum = [[G2Point alloc] init];

	GFP2 *z1z1 = [GFP2 square: [p1 z] withInvertedP: invertedP andPrecision: precision], 
		*z2z2 = [GFP2 square: [p2 z] withInvertedP: invertedP andPrecision: precision];
	GFP2 *u1 = [GFP2 multiply: z2z2 and: [p1 x] withInvertedP: invertedP andPrecision: precision], 
		*u2 = [GFP2 multiply: z1z1 and: [p2 x] withInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp = [GFP2 multiply: [p1 y] and: [p2 z] withInvertedP: invertedP andPrecision: precision];
	GFP2 *s1 = [GFP2 multiply: tmp and: z2z2 withInvertedP: invertedP andPrecision: precision];
	[tmp release];
	tmp = [GFP2 multiply: [p2 y] and: [p1 z] withInvertedP: invertedP andPrecision: precision];
	GFP2 *s2 = [GFP2 multiply: tmp and: z1z1 withInvertedP: invertedP andPrecision: precision];
	[tmp release];

	GFP2 *h = [GFP2 subtract: u2 and: u1];
	tmp = [h mutableCopy];
	[tmp shiftLeft];
	GFP2 *i = [GFP2 square: tmp withInvertedP: invertedP andPrecision: precision];
	[tmp release];
	GFP2 *j = [GFP2 multiply: i and: h withInvertedP: invertedP andPrecision: precision];
	GFP2 *r = [GFP2 subtract: s2 and: s1];
	if ([h isZero] && [r isZero]) {
		[z1z1 release];
		[z2z2 release];
		[u1 release];
		[u2 release];
		[s1 release];
		[s2 release];
		[h release];
		[i release];
		[j release];
		[r release];

		return [G2Point projectiveDouble: p1 withInvertedP: invertedP andPrecision: precision];
	}
	[r shiftLeft];
	GFP2 *v = [GFP2 multiply: u1 and: i withInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp1 = [GFP2 square: r withInvertedP: invertedP andPrecision: precision];
	tmp = [GFP2 subtract: tmp1 and: j];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp and: v];
	[tmp release];
	[sum setX: [GFP2 subtract: tmp1 and: v]];
	[tmp1 release];

	tmp1 = [GFP2 subtract: v and: [sum x]];
	tmp = [GFP2 multiply: r and: tmp1 withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	tmp1 = [GFP2 multiply: s1 and: j withInvertedP: invertedP andPrecision: precision];
	[tmp1 shiftLeft];
	[sum setY: [GFP2 subtract: tmp and: tmp1]];
	[tmp release];
	[tmp1 release];

	tmp1 = [GFP2 add: [p1 z] and: [p2 z]];
	tmp = [GFP2 square: tmp1 withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp and: z1z1];
	[tmp release];
	tmp = [GFP2 subtract: tmp1 and: z2z2];
	[tmp1 release];
	[sum setZ: [GFP2 multiply: tmp and: h withInvertedP: invertedP andPrecision: precision]];
	[tmp release];

	[z1z1 release];
	[z2z2 release];
	[u1 release];
	[u2 release];
	[s1 release];
	[s2 release];
	[h release];
	[i release];
	[j release];
	[r release];
	[v release];

	if ([[sum z] isZero]) {
		[sum release];
		sum = [[G2Point alloc] initInfinity];
	}

	return sum;
}


+(G2Point *) projectiveDouble: (G2Point *) p1 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([p1 infinity]) {
		return [[G2Point alloc] initInfinity];
	}

	G2Point *sum = [[G2Point alloc] init];

	GFP2 *a = [GFP2 square: [p1 x] withInvertedP: invertedP andPrecision: precision], 
		*b = [GFP2 square: [p1 y] withInvertedP: invertedP andPrecision: precision];
	GFP2 *c = [GFP2 square: b withInvertedP: invertedP andPrecision: precision];

	GFP2 *tmp1 = [GFP2 add: [p1 x] and: b];
	GFP2 *tmp = [GFP2 square: tmp1 withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp and: a];
	[tmp release];
	GFP2 *d = [GFP2 subtract: tmp1 and: c];
	[tmp1 release];
	[d shiftLeft];
	[a multiplyByInt: 3];
	GFP2 *f = [GFP2 square: a withInvertedP: invertedP andPrecision: precision];

	tmp = [GFP2 subtract: f and: d];
	[sum setX: [GFP2 subtract: tmp and: d]];
	[tmp release];

	[c multiplyByInt: 8];
	tmp1 = [GFP2 subtract: d and: [sum x]];
	tmp = [GFP2 multiply: tmp1 and: a withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[sum setY: [GFP2 subtract: tmp and: c]];
	[tmp release];

	tmp = [GFP2 multiply: [p1 y] and: [p1 z] withInvertedP: invertedP andPrecision: precision];
	[tmp shiftLeft];
	[sum setZ: tmp];

	[a release];
	[b release];
	[c release];
	[d release];
	[f release];

	return sum;
}

-(void) makeAffineWithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if (z == nil) {
		return;
	}
	GFP2 *tmp = [z invertWithInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp1 = [GFP2 square: tmp withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp2 = [GFP2 multiply: x and: tmp1 withInvertedP: invertedP andPrecision: precision];
	[x release];
	x = tmp2;
	tmp2 = [GFP2 multiply: tmp and: tmp1 withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	[tmp release];
	tmp = [GFP2 multiply: y and: tmp2 withInvertedP: invertedP andPrecision: precision];
	[tmp2 release];
	[y release];
	y = tmp;
	[z release];
	z = nil;
}
-(void) makeAffine {
	if (z == nil) {
		return;
	}
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength + 4]];

	[self makeAffineWithInvertedP: invertedP andPrecision: precision];

	[invertedP release];
}


+(G2Point *) add: (G2Point *) g2Point kTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    G2Point *result = [[G2Point alloc] initInfinity], *tmpECPoint, *tmpECPoint1;

    FGIntOverflow kLength = [[kFGInt number] length]/4, i, j;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kFGInt number] mutableBytes];
    
    tmpECPoint1 = [g2Point retain];
    [tmpECPoint1 makeProjective];
    [result makeProjective];

    for( i = 0; i < kLength - 1; i++ ) {
        tmp = kFGIntNumber[i];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpECPoint = [G2Point projectiveAdd: result and: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
                [result release];
                result = tmpECPoint;
            }
            tmpECPoint = [G2Point projectiveDouble: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
            tmp >>= 1;
        }
    }
    tmp = kFGIntNumber[kLength - 1];
    while (tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpECPoint = [G2Point projectiveAdd: result and: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
            [result release];
            result = tmpECPoint;
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpECPoint = [G2Point projectiveDouble: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
        }
    }

    [tmpECPoint1 release];
    [result makeAffineWithInvertedP: invertedP andPrecision: precision];

    return result;
}
+(G2Point *) add: (G2Point *) g2Point kTimes: (FGInt *) kFGInt {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength + 4]];

	G2Point *result = [G2Point add: g2Point kTimes: kFGInt withInvertedP: invertedP andPrecision: precisionBits];

	[invertedP release];

    return result;
}

+(G2Point *) addGeneratorKTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	G2Point * g2gen = [[G2Point alloc] initGenerator];

    G2Point *result = [G2Point add: g2gen kTimes: kFGInt withInvertedP: invertedP andPrecision: precision];

    [g2gen release];

    return result;
}
+(G2Point *) addGeneratorKTimes: (FGInt *) kFGInt {
	G2Point * generator = [[G2Point alloc] initGenerator];
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength + 4]];

    G2Point *result = [G2Point add: generator kTimes: kFGInt withInvertedP: invertedP andPrecision: precision];

    [generator release];
    [invertedP release];

    return result;
}


-(NSString *) toBase10String {
	NSMutableString *base10String = [[NSMutableString alloc] init];
	if (infinity) {
		[base10String appendString: @"infinity"];
		return base10String;
	}
	NSString *tmpStr = [x toBase10String];
	[base10String appendString: @"("];
	[base10String appendString: tmpStr];
	[base10String appendString: @", \n"];
	[tmpStr release];
	tmpStr = [y toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")"];

	return base10String;	
}

-(NSData *) marshal {
	if (infinity) {
		return [[NSMutableData alloc] initWithLength: 4*cnstLength];
	}
	if ((x == nil) || (y == nil)) {
		return nil;
	}

	NSMutableData *result = [[NSMutableData alloc] init];
	NSData *tmpData = [x marshal];
	[result appendData: tmpData];
	[tmpData release];
	tmpData = [y marshal];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}



@end












@implementation G1Point
@synthesize x, y, z, p;
@synthesize infinity;


-(id) init {
    if (self = [super init]) {
    	x = nil;
    	y = nil;
    	z = nil;
    	p = nil;
    	infinity = NO;
    }
    return self;
}
-(id) initInfinityWithP: (FGInt *) pFGInt {
    if (self = [super init]) {
    	x = nil;
    	y = nil;
    	z = nil;
    	p = [pFGInt retain];
    	infinity = YES;
    }
    return self;
}
-(id) initGenerator {
    if (self = [super init]) {
		p = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray[8] = pNumber;
		[p setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];
		x = [[FGInt alloc] initWithFGIntBase: 1];
		y = [[FGInt alloc] initWithFGIntBase: 2];
		[y changeSign];
    	z = nil;
    	infinity = NO;
    }
    return self;
}
-(id) initRandomPoint {
	FGInt *order = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = nNumber;
	[order setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

	FGInt *tmpFGInt = [[FGInt alloc] initWithRandomNumberOfBitSize: cnstLength*8];
	if (tmpFGInt != nil) {
		[tmpFGInt reduceBySubtracting: order atMost: 1];
	} else {
		[order release];
		return nil;
	}

	G1Point *result = [G1Point addGeneratorKTimes: tmpFGInt];

	[tmpFGInt release];
	[order release];

	return result;
}
-(id) unMarshal: (NSData *) marshalData {
	if ([marshalData length] != 2*cnstLength) {
		return nil;
	}
    if (self = [super init]) {
    	p = [[FGInt alloc] initWithoutNumber];
		FGIntBase numberArray[] = pNumber;
		[p setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength]];

    	const unsigned char* bytes = [marshalData bytes];
    	NSData *tmpData = [[NSData alloc] initWithBytes: &bytes[cnstLength] length: cnstLength];
    	y = [[FGInt alloc] initWithBigEndianNSData: tmpData];
    	[tmpData release];
		tmpData = [[NSData alloc] initWithBytes: bytes length: cnstLength];
    	x = [[FGInt alloc] initWithBigEndianNSData: tmpData];
    	[tmpData release];
		z = nil;
		if ([x isZero] && [y isZero]) {
			infinity = YES;
		} else {
			infinity = NO;
		}
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
	if (z != nil) {
	    [z release];
	}
    [super dealloc];
}
-(id) mutableCopyWithZone: (NSZone *) zone {
	if (infinity) {
		return [[G1Point alloc] initInfinityWithP: p];
	}

    G1Point *newG1Point = [[G1Point allocWithZone: zone] init];

    [newG1Point setX: [x mutableCopy]];
    [newG1Point setY: [y mutableCopy]];
    [newG1Point setZ: [z mutableCopy]];
    [newG1Point setP: [p retain]];

    return newG1Point;
}
-(void) changeSign {
	if (!infinity) {
		[y changeSign];
	}
}
-(void) makeProjective {
	if (!infinity) {
		z = [[FGInt alloc] initWithFGIntBase: 1];
	}
}

+(G1Point *) add: (G1Point *) p1 and: (G1Point *) p2 {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength + 4]];

	G1Point *tmp0G2 = [p1 mutableCopy], *tmp1G2 = [p2 mutableCopy];
	[tmp0G2 makeProjective];
	[tmp1G2 makeProjective];

	G1Point *result = [G1Point projectiveAdd: tmp0G2 and: tmp1G2 withInvertedP: invertedP andPrecision: precision];
	[result makeAffineWithInvertedP: invertedP andPrecision: precision];

    [invertedP release];
    [tmp0G2 release];
    [tmp1G2 release];

    return result;
}


+(G1Point *) projectiveAdd: (G1Point *) p1 and: (G1Point *) p2 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([p1 infinity]) {
		return [p2 mutableCopy];
	}
	if ([p2 infinity]) {
		return [p1 mutableCopy];
	}

	G1Point *sum = [[G1Point alloc] init];

	FGInt *tmpBarrett, *p = nil;
	if ([p1 p] != nil) {
		p = [p1 p];
	} else 	if ([p2 p] != nil) {
		p = [p2 p];
	}


	tmpBarrett = [FGInt square: [p1 z]];
	FGInt *z1z1 =  [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt square: [p2 z]];
	FGInt *z2z2 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt multiply: z2z2 and: [p1 x]];
	FGInt *u1 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt multiply: z1z1 and: [p2 x] ];
	FGInt *u2 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];

	tmpBarrett = [FGInt multiply: [p1 y] and: [p2 z]];
	FGInt *tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt multiply: tmp and: z2z2];	
	FGInt *s1 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp release];
	tmpBarrett = [FGInt multiply: [p2 y] and: [p1 z]];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt multiply: tmp and: z1z1];
	FGInt *s2 =  [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp release];

	FGInt *h = [FGInt subtract: u2 and: u1];
	[h reduceBySubtracting: p atMost: 1];
	tmp = [h mutableCopy];
	[tmp shiftLeft];
	[tmp reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt square: tmp];
	FGInt *i = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp release];
	tmpBarrett = [FGInt multiply: i and: h];
	FGInt *j = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	FGInt *r = [FGInt subtract: s2 and: s1];
	if ([h isZero] && [r isZero]) {
		[z1z1 release];
		[z2z2 release];
		[u1 release];
		[u2 release];
		[s1 release];
		[s2 release];
		[h release];
		[i release];
		[j release];
		[r release];

		return [G1Point projectiveDouble: p1 withInvertedP: invertedP andPrecision: precision];
	}
	[r shiftLeft];
	[r reduceBySubtracting: p atMost: 4];
	tmpBarrett = [FGInt multiply: u1 and: i];
	FGInt *v = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];

	tmpBarrett = [FGInt square: r];
	FGInt *tmp1 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmp = [FGInt subtract: tmp1 and: j];
	[tmp1 release];
	tmp1 = [FGInt subtract: tmp and: v];
	[tmp release];
	tmp = [FGInt subtract: tmp1 and: v];
	[tmp reduceBySubtracting: p atMost: 3];
	[sum setX: tmp];
	[tmp1 release];

	tmp1 = [FGInt subtract: v and: [sum x]];
	[tmp1 reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt multiply: r and: tmp1];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	tmpBarrett = [FGInt multiply: s1 and: j];
	tmp1 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 shiftLeft];
	tmpBarrett = [FGInt subtract: tmp and: tmp1];
	[tmpBarrett reduceBySubtracting: p atMost: 3];
	[sum setY: tmpBarrett];
	[tmp release];
	[tmp1 release];

	tmp1 = [FGInt add: [p1 z] and: [p2 z]];
	[tmp1 reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt square: tmp1];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	tmp1 = [FGInt subtract: tmp and: z1z1];
	[tmp1 reduceBySubtracting: p atMost: 1];
	[tmp release];
	tmp = [FGInt subtract: tmp1 and: z2z2];
	[tmp reduceBySubtracting: p atMost: 1];
	[tmp1 release];
	tmpBarrett = [FGInt multiply: tmp and: h];
	[sum setZ: [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision]];
	[tmpBarrett release];
	[tmp release];

	[z1z1 release];
	[z2z2 release];
	[u1 release];
	[u2 release];
	[s1 release];
	[s2 release];
	[h release];
	[i release];
	[j release];
	[r release];
	[v release];

	if ([[sum z] isZero]) {
		[sum release];
		if ([p1 p] != nil) {
			p = [p1 p];
		} else 	if ([p2 p] != nil) {
			p = [p2 p];
		}
		sum = [[G1Point alloc] initInfinityWithP: p];
	}

	[sum setP: [p retain]];

	return sum;
}


+(G1Point *) projectiveDouble: (G1Point *) p1 withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([p1 infinity]) {
		return [[G1Point alloc] initInfinityWithP: [p1 p]];
	}

	G1Point *sum = [[G1Point alloc] init];

	FGInt *tmpBarrett, *p = nil;
	if ([p1 p] != nil) {
		p = [p1 p];
	} 
	// else {
	// 	NSLog(@"uh-oh");
	// 	p = [[FGInt alloc] initWithBase10String: @"65000549695646603732796438742359905742825358107623003571877145026864184071783"];
	// }

	tmpBarrett = [FGInt square: [p1 x]];
	FGInt *a = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt square: [p1 y]];
	FGInt *b = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt square: b];
	FGInt *c = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];

	FGInt *tmp1 = [FGInt add: [p1 x] and: b];
	[tmp1 reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt square: tmp1];
	FGInt *tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	tmp1 = [FGInt subtract: tmp and: a];
	[tmp release];
	FGInt *d = [FGInt subtract: tmp1 and: c];
	[tmp1 release];
	[d shiftLeft];
	[d reduceBySubtracting: p atMost: 5];
	[a multiplyByInt: 3];
	[a reduceBySubtracting: p atMost: 3];
	tmpBarrett = [FGInt square: a]; 
	FGInt *f = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];

	tmp = [FGInt subtract: f and: d];
	tmpBarrett = [FGInt subtract: tmp and: d];
	[tmpBarrett reduceBySubtracting: p atMost: 2];
	[sum setX: tmpBarrett];
	[tmp release];

	[c multiplyByInt: 8];
	tmp1 = [FGInt subtract: d and: [sum x]];
	[tmp1 reduceBySubtracting: p atMost: 1];
	tmpBarrett = [FGInt multiply: tmp1 and: a];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	tmp1 = [FGInt subtract: tmp and: c];
	[tmp1 reduceBySubtracting: p atMost: 9];
	[sum setY: tmp1];
	[tmp release];

	tmpBarrett = [FGInt multiply: [p1 y] and: [p1 z]];
	tmp = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp shiftLeft];
	[tmp reduceBySubtracting: p atMost: 1];
	[sum setZ: tmp];

	[a release];
	[b release];
	[c release];
	[d release];
	[f release];

	[sum setP: [p retain]];

	return sum;
}

-(void) makeAffineWithInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if (z == nil) {
		return;
	}
	FGInt *tmp = [FGInt invert: z moduloPrime: p];
	FGInt *tmpBarrett = [FGInt square: tmp];
	FGInt *tmp1 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	tmpBarrett = [FGInt multiply: x and: tmp1];
	FGInt *tmp2 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[x release];
	x = tmp2;
	tmpBarrett = [FGInt multiply: tmp and: tmp1];
	tmp2 = [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp1 release];
	[tmp release];
	tmpBarrett = [FGInt multiply: y and: tmp2];
	tmp =  [FGInt barrettMod: tmpBarrett by: p with: invertedP andPrecision: precision];
	[tmpBarrett release];
	[tmp2 release];
	[y release];
	y = tmp;
	[z release];
	z = nil;
}


+(G1Point *) add: (G1Point *) g1Point kTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
    G1Point *result = [[G1Point alloc] initInfinityWithP: [g1Point p]], *tmpECPoint, *tmpECPoint1;

    FGIntOverflow kLength = [[kFGInt number] length]/4, i, j;
    FGIntBase tmp;
    FGIntBase* kFGIntNumber = [[kFGInt number] mutableBytes];
    
    tmpECPoint1 = [g1Point retain];
    [tmpECPoint1 makeProjective];
    [result makeProjective];

    for( i = 0; i < kLength - 1; i++ ) {
        tmp = kFGIntNumber[i];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpECPoint = [G1Point projectiveAdd: result and: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
                [result release];
                result = tmpECPoint;
            }
            tmpECPoint = [G1Point projectiveDouble: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
            tmp >>= 1;
        }
    }
    tmp = kFGIntNumber[kLength - 1];
    while (tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpECPoint = [G1Point projectiveAdd: result and: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
            [result release];
            result = tmpECPoint;
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpECPoint = [G1Point projectiveDouble: tmpECPoint1 withInvertedP: invertedP andPrecision: precision];
            [tmpECPoint1 release];
            tmpECPoint1 = tmpECPoint;
        }
    }

    [tmpECPoint1 release];
    [result makeAffineWithInvertedP: invertedP andPrecision: precision];

    return result;
}
+(G1Point *) add: (G1Point *) g1Point kTimes: (FGInt *) kFGInt {
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength + 4]];

	G1Point *result = [G1Point add: g1Point kTimes: kFGInt withInvertedP: invertedP andPrecision: precisionBits];

	[invertedP release];
    return result;
}

+(G1Point *) addGeneratorKTimes: (FGInt *) kFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	G1Point * g1gen = [[G1Point alloc] initGenerator];

    G1Point *result = [G1Point add: g1gen kTimes: kFGInt withInvertedP: invertedP andPrecision: precision];

    [g1gen release];

    return result;
}
+(G1Point *) addGeneratorKTimes: (FGInt *) kFGInt {
	G1Point *generator = [[G1Point alloc] initGenerator];
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength + 4]];

    G1Point *result = [G1Point add: generator kTimes: kFGInt withInvertedP: invertedP andPrecision: precision];

    [generator release];
    [invertedP release];

    return result;
}



-(NSString *) toBase10String {
	NSMutableString *base10String = [[NSMutableString alloc] init];
	if (infinity) {
		[base10String appendString: @"infinity"];
		return base10String;
	}
	NSString *tmpStr = [x toBase10String];
	[base10String appendString: @"("];
	[base10String appendString: tmpStr];
	[base10String appendString: @", "];
	[tmpStr release];
	tmpStr = [y toBase10String];
	[base10String appendString: tmpStr];
	[tmpStr release];
	[base10String appendString: @")"];

	return base10String;	
}

-(NSData *) marshal {
	if (infinity) {
		return [[NSMutableData alloc] initWithLength: 2*cnstLength];
	}
	if ((x == nil) || (y == nil)) {
		return nil;
	}

	if (![x sign] || ![y sign]) {
		NSLog(@"uh-oh");
	}

	NSMutableData *result = [[NSMutableData alloc] init];
	// NSData *tmpData = [x toBigEndianNSDataOfLength: cnstLength];
	NSData *tmpData = [[FGInt longDivisionMod: x by: p] toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];
	// tmpData = [y toBigEndianNSDataOfLength: cnstLength];
	tmpData = [[FGInt longDivisionMod: y by: p] toBigEndianNSDataOfLength: cnstLength];
	[result appendData: tmpData];
	[tmpData release];

	return result;
}



@end







@implementation BN256





// mixed addition
//		g2p in projective coordinates X1, Y1, T1, Z1
//		g2q in affine coordinates x2, y2 and constant throughout up to a sign
//		cachedR2 is y1^2 and constant
//		g1Point is constant, xq,yq and where the line is evaluated in

+(void) add: (G2Point **) g2p and: (G2Point *) g2q with: (GFP2 *) cachedR2 evaluateLineIn: (G1Point *) g1Point andMultiply: (GFP12 **) f withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *tmp0, *tmp1, *tmp2;

	GFP2 *b = [GFP2 multiply: [g2q x] and: [*g2p t] withInvertedP: invertedP andPrecision: precision];
	tmp0 = [GFP2 add: [*g2p z] and: [g2q y]];
	tmp1 = [GFP2 square: tmp0 withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: cachedR2];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp0 and: [*g2p t]];
	[tmp0 release];
	GFP2 *d = [GFP2 multiply: tmp1 and: [*g2p t] withInvertedP: invertedP andPrecision: precision];
	[tmp1 release];
	GFP2 *h = [GFP2 subtract: b and: [*g2p x]];
	GFP2 *i = [GFP2 square: h withInvertedP: invertedP andPrecision: precision];
	GFP2 *e = [i mutableCopy];
	[e multiplyByInt: 4];
	GFP2 *j = [GFP2 multiply: h and: e withInvertedP: invertedP andPrecision: precision];
	tmp0 = [GFP2 subtract: d and: [*g2p y]];
	GFP2 *l1 = [GFP2 subtract: tmp0 and: [*g2p y]];
	[tmp0 release];
	if ([h isZero] && [l1 isZero]) {
		[b release];
		[d release];
		[h release];
		[i release];
		[e release];
		[j release];
		[l1 release];
		return [BN256 double: g2p evaluateLineIn: g1Point andMultiply: f withInvertedP: invertedP andPrecision: precision];
	}

	GFP2 *v = [GFP2 multiply: [*g2p x] and: e withInvertedP: invertedP andPrecision: precision];
	tmp0 = [GFP2 square: l1 withInvertedP: invertedP andPrecision: precision];
	tmp1 = [GFP2 subtract: tmp0 and: j];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: v];
	[tmp1 release];
	G2Point *sum = [[G2Point alloc] init];
	[sum setX: [GFP2 subtract: tmp0 and: v]];
	[tmp0 release];

	tmp0 = [GFP2 subtract: v and: [sum x]];
	tmp1 = [GFP2 multiply: tmp0 and: l1 withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 multiply: [*g2p y] and: j withInvertedP: invertedP andPrecision: precision];
	[tmp0 shiftLeft];
	[sum setY: [GFP2 subtract: tmp1 and: tmp0]];
	[tmp1 release];
	[tmp0 release];

	tmp0 = [GFP2 add: h and: [*g2p z]];
	tmp1 = [GFP2 square: tmp0 withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: [*g2p t]];
	[tmp1 release];
	[sum setZ: [GFP2 subtract: tmp0 and: i]];
	[tmp0 release];

	[sum setT: [GFP2 square: [sum z] withInvertedP: invertedP andPrecision: precision]];

	GFP2 *c0 = [[sum z] mutableCopy];
	[c0 multiplyByFGInt: [g1Point y] withInvertedP: invertedP andPrecision: precision];
	[c0 shiftLeft];

	GFP2 *b0 = [l1 mutableCopy];
	[b0 multiplyByFGInt: [g1Point x] withInvertedP: invertedP andPrecision: precision];
	[b0 shiftLeft];
	[b0 changeSign];

	tmp0 = [GFP2 add: [sum z] and: [g2q y]];
	tmp1 = [GFP2 square: tmp0 withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: cachedR2 and: tmp1];
	[tmp1 release];
	tmp1 = [GFP2 add: tmp0 and: [sum t]];
	[tmp0 release];
	tmp0 = [GFP2 multiply: l1 and: [g2q x] withInvertedP: invertedP andPrecision: precision];
	[tmp0 shiftLeft];
	GFP2 *a0 = [GFP2 add: tmp1 and: tmp0];
	[tmp0 release];
	[tmp1 release];


	GFP6 *a2 = [[GFP6 alloc] init];
	[a2 setC: [[GFP2 alloc] initZero]];
	[a2 setB: [a0 retain]];
	[a2 setA: [b0 retain]];
	GFP6 *tmp6 = [GFP6 multiply: a2 and: [*f b] withInvertedP: invertedP andPrecision: precision];
	[a2 release];
	a2 = tmp6;
	tmp6 = [[*f a] mutableCopy];
	[tmp6 multiplyByGFP2: c0 withInvertedP: invertedP andPrecision: precision];

	GFP6 *tmp7 = [[GFP6 alloc] init];
	[tmp7 setA: [GFP2 add: b0 and: c0]];
	[tmp7 setB: [a0 retain]];
	[tmp7 setC: [[GFP2 alloc] initZero]];

	GFP6 *tmp8 = [GFP6 add: [*f a] and: [*f b]];
	[[*f b] release];
	[[*f a] release];
	[*f setB: tmp8];
	[*f setA: tmp6];

	tmp6 = [GFP6 multiply: [*f b] and: tmp7 withInvertedP: invertedP andPrecision: precision];
	[[*f b] release];
	[tmp7 release];
	tmp7 = [GFP6 subtract: tmp6 and: a2];
	[tmp6 release];
	[*f setB: [GFP6 subtract: tmp7 and: [*f a]]];
	[tmp7 release];
	[a2 multiplyByRoot];
	tmp6 = [GFP6 add: [*f a] and: a2];
	[[*f a] release];
	[*f setA: tmp6];


	[a0 release];
	[a2 release];
	[b0 release];
	[c0 release];

	[b release];
	[d release];
	[h release];
	[i release];
	[e release];
	[j release];
	[l1 release];
	[v release];

	[*g2p release];
	*g2p = sum;
}



+(void) double: (G2Point **) g2p evaluateLineIn: (G1Point *) g1Point andMultiply: (GFP12 **) f withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	GFP2 *a = [GFP2 square: [*g2p x] withInvertedP: invertedP andPrecision: precision];
	GFP2 *b = [GFP2 square: [*g2p y] withInvertedP: invertedP andPrecision: precision];
	GFP2 *c = [GFP2 square: b withInvertedP: invertedP andPrecision: precision];
	GFP2 *tmp0 = [GFP2 add: [*g2p x] and: b];
	GFP2 *tmp1 = [GFP2 square: tmp0 withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: a];
	[tmp1 release];
	GFP2 *d = [GFP2 subtract: tmp0 and: c];
	[tmp0 release];
	[d shiftLeft];
	GFP2 *e = [a mutableCopy];
	[e multiplyByInt: 3];
	GFP2 *g = [GFP2 square: e withInvertedP: invertedP andPrecision: precision];

	G2Point *sum = [[G2Point alloc] init];
	tmp0 = [GFP2 subtract: g and: d];
	[sum setX: [GFP2 subtract: tmp0 and: d]];
	[tmp0 release];

	tmp0 = [GFP2 subtract: d and: [sum x]];
	tmp1 = [GFP2 multiply: tmp0 and: e withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [c mutableCopy];
	[tmp0 multiplyByInt: 8];
	[sum setY: [GFP2 subtract: tmp1 and: tmp0]];
	[tmp0 release];
	[tmp1 release];

	tmp0 = [GFP2 add: [*g2p y] and: [*g2p z]];
	tmp1 = [GFP2 square: tmp0 withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: b];
	[tmp1 release];
	[sum setZ: [GFP2 subtract: tmp0 and: [*g2p t]]];
	[tmp0 release];

	[sum setT: [GFP2 square: [sum z] withInvertedP: invertedP andPrecision: precision]];

	GFP2 *c0 = [GFP2 multiply: [sum z] and: [*g2p t] withInvertedP: invertedP andPrecision: precision];
	[c0 multiplyByFGInt: [g1Point y] withInvertedP: invertedP andPrecision: precision];
	[c0 shiftLeft];

	GFP2 *b0 = [GFP2 multiply: [*g2p t] and: e withInvertedP: invertedP andPrecision: precision];
	[b0 multiplyByFGInt: [g1Point x] withInvertedP: invertedP andPrecision: precision];
	[b0 shiftLeft];
	[b0 changeSign];

	tmp0 = [GFP2 add: e and: [*g2p x]];
	tmp1 = [GFP2 square: tmp0 withInvertedP: invertedP andPrecision: precision];
	[tmp0 release];
	tmp0 = [GFP2 subtract: tmp1 and: a];
	[tmp1 release];
	tmp1 = [GFP2 subtract: tmp0 and: g];
	[tmp0 release];
	[b multiplyByInt: 4];
	GFP2 *a0 = [GFP2 subtract: tmp1 and: b];
	[tmp1 release];


	GFP6 *a2 = [[GFP6 alloc] init];
	[a2 setC: [[GFP2 alloc] initZero]];
	[a2 setB: [a0 retain]];
	[a2 setA: [b0 retain]];
	GFP6 *tmp6 = [GFP6 multiply: a2 and: [*f b] withInvertedP: invertedP andPrecision: precision];
	[a2 release];
	a2 = tmp6;
	tmp6 = [[*f a] mutableCopy];
	[tmp6 multiplyByGFP2: c0 withInvertedP: invertedP andPrecision: precision];

	GFP6 *tmp7 = [[GFP6 alloc] init];
	[tmp7 setA: [GFP2 add: b0 and: c0]];
	[tmp7 setB: [a0 retain]];
	[tmp7 setC: [[GFP2 alloc] initZero]];

	GFP6 *tmp8 = [GFP6 add: [*f a] and: [*f b]];
	[[*f b] release];
	[*f setB: tmp8];
	[[*f a] release];
	[*f setA: tmp6];

	tmp6 = [GFP6 multiply: [*f b] and: tmp7 withInvertedP: invertedP andPrecision: precision];
	[[*f b] release];
	[tmp7 release];
	tmp7 = [GFP6 subtract: tmp6 and: a2];
	[tmp6 release];
	[*f setB: [GFP6 subtract: tmp7 and: [*f a]]];
	[tmp7 release];
	[a2 multiplyByRoot];
	tmp6 = [GFP6 add: [*f a] and: a2];
	[[*f a] release];
	[*f setA: tmp6];

	[a2 release];

	[a0 release];
	[b0 release];
	[c0 release];
	[a release];
	[b release];
	[c release];
	[d release];
	[e release];
	[g release];

	[*g2p release];
	*g2p = sum;
}



+(GFP12 *) optimalAtePairing: (G2Point *) q and: (G1Point *) p withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision {
	if ([q infinity] || [p infinity]) {
		return [[GFP12 alloc] initOne];
	}

	int nafLength = 66;
	char naf6up2[] = {0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, -1, 0, 1, 0, 0, 0, 1, 0, -1, 0, 0, 0, -1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, -1, 0, -1, 0, 0, 0, 0, 1, 0, 0, 0, 1};

	GFP12 *f = [[GFP12 alloc] initOne];
	GFP12 *tmpF;
	G2Point *r = [q mutableCopy];
	G2Point *minusQ = [q mutableCopy];
	[minusQ changeSign];
	[r makeExtendedProjective];

	GFP2 *cachedR2 = [GFP2 square: [q y] withInvertedP: invertedP andPrecision: precision];


	for ( int i = nafLength - 1; i > 0; --i ) {
		tmpF = [GFP12 square: f withInvertedP: invertedP andPrecision: precision];
		[f release];
		f = tmpF;
		[BN256 double: &r evaluateLineIn: p andMultiply: &f withInvertedP: invertedP andPrecision: precision];

		if (naf6up2[i - 1] == 1) {
			[BN256 add: &r and: q with: cachedR2 evaluateLineIn: p andMultiply: &f withInvertedP: invertedP andPrecision: precision];
		} else if (naf6up2[i - 1] == -1) {
			[BN256 add: &r and: minusQ with: cachedR2 evaluateLineIn: p andMultiply: &f withInvertedP: invertedP andPrecision: precision];
		}
	}

	G2Point *q1 = [[G2Point alloc] init];
	GFP2 *tmp0 = [[q x] mutableCopy];
	[tmp0 conjugate];
	GFP2 *tmp = [[GFP2 alloc] init];
	FGIntBase numberArray3[8] = iPlus3ToPm1o3aNumber;
	FGInt *tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray3 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray4[8] = iPlus3ToPm1o3bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray4 length: cnstLength]];
	[tmp setB: tmpFGInt];
	[tmp setP: [[tmp0 p] retain]];
	[q1 setX: [GFP2 multiply: tmp0 and: tmp withInvertedP: invertedP andPrecision: precision]];
	[tmp release];
	[tmp0 release];
	tmp0 = [[q y] mutableCopy];
	[tmp0 conjugate];
	tmp = [[GFP2 alloc] init];
	FGIntBase numberArray5[8] = iPlus3ToPm1o2aNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray5 length: cnstLength]];
	[tmp setA: tmpFGInt];
	FGIntBase numberArray6[8] = iPlus3ToPm1o2bNumber;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray6 length: cnstLength]];
	[tmp setB: tmpFGInt];
	[tmp setP: [[tmp0 p] retain]];
	[q1 setY: [GFP2 multiply: tmp0 and: tmp withInvertedP: invertedP andPrecision: precision]];
	[tmp release];
	[tmp0 release];

	G2Point *q2 = [[G2Point alloc] init];
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray2[8] = iPlus3ToPsm1o3Number;
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray2 length: cnstLength]];
	tmp = [[q x] mutableCopy];
	[tmp multiplyByFGInt: tmpFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];
	[q2 setX: tmp];
	[q2 setY: [[q y] retain]];

	[cachedR2 release];
	cachedR2 = [GFP2 square: [q1 y] withInvertedP: invertedP andPrecision: precision];
	[BN256 add: &r and: q1 with: cachedR2 evaluateLineIn: p andMultiply: &f withInvertedP: invertedP andPrecision: precision];
	[cachedR2 release];
	cachedR2 = [GFP2 square: [q2 y] withInvertedP: invertedP andPrecision: precision];
	[BN256 add: &r and: q2 with: cachedR2 evaluateLineIn: p andMultiply: &f withInvertedP: invertedP andPrecision: precision];

	[r release];
	[minusQ release];
	[cachedR2 release];
	[q1 release];
	[q2 release];


	// FGInt *prime = [[FGInt alloc] initWithoutNumber];
	// FGIntBase numberArrayP[8] = pNumber;
	// [prime setNumber: [[NSMutableData alloc] initWithBytes: numberArrayP length: cnstLength]];
	// FGInt *n = [[FGInt alloc] initWithoutNumber];
	// FGIntBase numberArrayN[8] = nNumber;
	// [n setNumber: [[NSMutableData alloc] initWithBytes: numberArrayN length: cnstLength]];
	// FGInt *p12 = [FGInt raise: prime toThePower: [[FGInt alloc] initWithFGIntBase: 12]];
	// [p12 decrement];
	// NSDictionary *divmod = [FGInt divide: p12 by: n];
	// tmpFGInt = [divmod objectForKey: quotientKey];

	// return [GFP12 raise: f toThePower: tmpFGInt withInvertedP: invertedP andPrecision: precision];


	// final exponentiation

	GFP12 *t1 = [f mutableCopy];
	[[t1 b] changeSign];
	GFP12 *fInv = [f invertWithInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t1 and: fInv withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	[fInv release];
	t1 = tmpF;

	GFP12 *t2 = [t1 mutableCopy];
	[t2 frobenius2WithInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t1 and: t2 withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = tmpF;

	GFP12 *fp = [t1 mutableCopy], *fp2 = [t1 mutableCopy], *fp3;
	[fp frobeniusWithInvertedP: invertedP andPrecision: precision];
	[fp2 frobenius2WithInvertedP: invertedP andPrecision: precision];
	fp3 = [fp2 mutableCopy];
	[fp3 frobeniusWithInvertedP: invertedP andPrecision: precision];

	GFP12 *fu, *fu2, *fu3;
	tmpFGInt = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray1[2] = {3965223681u, 1517727386u};
	[tmpFGInt setNumber: [[NSMutableData alloc] initWithBytes: numberArray1 length: 8]];
	fu = [GFP12 raise: t1 toThePower: tmpFGInt withInvertedP: invertedP andPrecision: precision];
	fu2 = [GFP12 raise: fu toThePower: tmpFGInt withInvertedP: invertedP andPrecision: precision];
	fu3 = [GFP12 raise: fu2 toThePower: tmpFGInt withInvertedP: invertedP andPrecision: precision];
	[tmpFGInt release];

	GFP12 *y3 = [fu mutableCopy], *fu2p = [fu2 mutableCopy], *fu3p = [fu3 mutableCopy], *y2;
	[y3 frobeniusWithInvertedP: invertedP andPrecision: precision];
	[fu2p frobeniusWithInvertedP: invertedP andPrecision: precision];
	[fu3p frobeniusWithInvertedP: invertedP andPrecision: precision];
	y2 = [fu2 mutableCopy];
	[y2 frobenius2WithInvertedP: invertedP andPrecision: precision];

	GFP12 *y0 = [GFP12 multiply: fp and: fp2 withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: y0 and: fp3 withInvertedP: invertedP andPrecision: precision];
	[y0 release];
	y0 = tmpF;

	GFP12 *y1 = [t1 mutableCopy], *y4 = [GFP12 multiply: fu and: fu2p withInvertedP: invertedP andPrecision: precision], 
			*y5 = [fu2 mutableCopy];
	[y1 conjugate];
	[y5 conjugate];
	[y3 conjugate];
	[y4 conjugate];

	GFP12 *y6 = [GFP12 multiply: fu3 and: fu3p withInvertedP: invertedP andPrecision: precision];
	[y6 conjugate];

	GFP12 *t0 = [GFP12 square: y6 withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t0 and: y4 withInvertedP: invertedP andPrecision: precision];
	[t0 release];
	t0 = [GFP12 multiply: tmpF and: y5 withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = [GFP12 multiply: y3 and: y5 withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t0 and: t1 withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = tmpF;
	tmpF = [GFP12 multiply: t0 and: y2 withInvertedP: invertedP andPrecision: precision];
	[t0 release];
	t0 = tmpF;
	tmpF = [GFP12 square: t1 withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = [GFP12 multiply: t0 and: tmpF withInvertedP: invertedP andPrecision: precision];
	[tmpF release];
	tmpF = [GFP12 square: t1 withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = tmpF;
	[t0 release];
	t0 = [GFP12 multiply: t1 and: y1 withInvertedP: invertedP andPrecision: precision];
	tmpF = [GFP12 multiply: t1 and: y0 withInvertedP: invertedP andPrecision: precision];
	[t1 release];
	t1 = tmpF;
	tmpF = [GFP12 square: t0 withInvertedP: invertedP andPrecision: precision];
	f = [GFP12 multiply: t1 and: tmpF withInvertedP: invertedP andPrecision: precision];

	[t0 release];
	[t1 release];
	[y0 release];
	[y1 release];
	[y2 release];
	[y3 release];
	[y4 release];
	[y5 release];
	[y6 release];
	[fu release];
	[fu2 release];
	[fu3 release];
	[fp release];
	[fp2 release];
	[fp3 release];
	[fu2p release];
	[fu3p release];

	return f;
}


+(GFP12 *) optimalAtePairing: (G2Point *) q and: (G1Point *) p {
	if ([q infinity] || [p infinity]) {
		return [[GFP12 alloc] initOne];
	}
	FGIntOverflow precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength + 4]];

	GFP12 *result = [BN256 optimalAtePairing: q and: p withInvertedP: invertedP andPrecision: precision];
	[invertedP release];

	return result;
}


+(BOOL) testPairing {
	FGInt *p = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray0[] = pNumber;
	[p setNumber: [[NSMutableData alloc] initWithBytes: numberArray0 length: cnstLength]];
	FGIntBase precision = precisionBits;
	FGInt *invertedP = [[FGInt alloc] initWithoutNumber];
	FGIntBase numberArray[] = invertedPnumber;
	[invertedP setNumber: [[NSMutableData alloc] initWithBytes: numberArray length: cnstLength + 4]];

	FGInt *tmpFGInt1 = [[FGInt alloc] initWithRandomNumberOfBitSize: precision - 1], 
			*tmpFGInt2 = [[FGInt alloc] initWithRandomNumberOfBitSize: precision - 1], 
			*tmpFGInt3 = [[FGInt alloc] initWithRandomNumberOfBitSize: precision - 1];
	G1Point *g1gen = [[G1Point alloc] initGenerator];
	G1Point *g1_1 = [G1Point add: g1gen kTimes: tmpFGInt1 withInvertedP: invertedP andPrecision: precision];
	G1Point *g1_2 = [G1Point add: g1gen kTimes: tmpFGInt2 withInvertedP: invertedP andPrecision: precision];
	G1Point *g1_3 = [G1Point add: g1gen kTimes: tmpFGInt3 withInvertedP: invertedP andPrecision: precision];
	G2Point *g2gen = [[G2Point alloc] initGenerator];
	G2Point *g2_1 = [G2Point add: g2gen kTimes: tmpFGInt1 withInvertedP: invertedP andPrecision: precision];
	G2Point *g2_2 = [G2Point add: g2gen kTimes: tmpFGInt2 withInvertedP: invertedP andPrecision: precision];
	G2Point *g2_3 = [G2Point add: g2gen kTimes: tmpFGInt3 withInvertedP: invertedP andPrecision: precision];

	GFP12 *gfp12_1, *gfp12_2, *gfp12_3, *tmpGFP12;

	NSDate *date1;
	double timePassed_ms1;
	// g2_1 = [[G2Point alloc] unMarshal: [g2_1 marshal]];
	// g1_2 = [[G1Point alloc] unMarshal: [g1_2 marshal]];
	date1 = [NSDate date];
	tmpGFP12 = [BN256 optimalAtePairing: g2_1 and: g1_2 withInvertedP: invertedP andPrecision: precision];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	NSLog(@"1st pairing took %fms", timePassed_ms1);
	gfp12_1 = [GFP12 raise: tmpGFP12 toThePower: tmpFGInt3 withInvertedP: invertedP andPrecision: precision];
	[tmpGFP12 release];

	// g2_2 = [[G2Point alloc] unMarshal: [g2_2 marshal]];
	// g1_3 = [[G1Point alloc] unMarshal: [g1_3 marshal]];
	date1 = [NSDate date];
	tmpGFP12 = [BN256 optimalAtePairing: g2_2 and: g1_3 withInvertedP: invertedP andPrecision: precision];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	NSLog(@"2nd pairing took %fms", timePassed_ms1);
	gfp12_2 = [GFP12 raise: tmpGFP12 toThePower: tmpFGInt1 withInvertedP: invertedP andPrecision: precision];
	[tmpGFP12 release];

	// g2_3 = [[G2Point alloc] unMarshal: [g2_3 marshal]];
	// g1_1 = [[G1Point alloc] unMarshal: [g1_1 marshal]];
	date1 = [NSDate date];
	tmpGFP12 = [BN256 optimalAtePairing: g2_3 and: g1_1 withInvertedP: invertedP andPrecision: precision];
	timePassed_ms1 = [date1 timeIntervalSinceNow] * -1000.0;
	NSLog(@"3rd pairing took %fms", timePassed_ms1);
	gfp12_3 = [GFP12 raise: tmpGFP12 toThePower: tmpFGInt2 withInvertedP: invertedP andPrecision: precision];
	[tmpGFP12 release];

	// gfp12_1 = [[GFP12 alloc] unMarshal: [gfp12_1 marshal]];
	// gfp12_2 = [[GFP12 alloc] unMarshal: [gfp12_2 marshal]];
	// gfp12_3 = [[GFP12 alloc] unMarshal: [gfp12_3 marshal]];

	GFP12 *gfp12 = [GFP12 subtract: gfp12_1 and: gfp12_2], 
			*gfp13 = [GFP12 subtract: gfp12_1 and: gfp12_3], 
			*gfp23 = [GFP12 subtract: gfp12_3 and: gfp12_2];

	NSLog(@"%@", [gfp12 toBase10String]);
	NSLog(@"%@", [gfp23 toBase10String]);
	NSLog(@"%@", [gfp13 toBase10String]);

	[p release];
	[invertedP release];
	[g1gen release];
	[g2gen release];
	[g1_1 release];
	[g1_2 release];
	[g1_3 release];
	[g2_1 release];
	[g2_2 release];
	[g2_3 release];
	[tmpFGInt1 release];
	[tmpFGInt2 release];
	[tmpFGInt3 release];

	BOOL result = ([gfp13 isZero] && [gfp23 isZero] && [gfp12 isZero]);
	[gfp12 release];
	[gfp13 release];
	[gfp23 release];

	return result;
}


@end





























