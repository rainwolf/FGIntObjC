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

#import "FGInt.h"
/* ToDo
   - divide and conquer division too?
 */


static const FGIntBase primes[1228] =
    {3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127,
    131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251,
    257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389,
    397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541,
    547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677,
    683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839,
    853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997, 1009,
    1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097, 1103, 1109, 1117, 1123,
    1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223, 1229, 1231, 1237, 1249, 1259, 1277, 1279,
    1283, 1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367, 1373, 1381, 1399, 1409, 1423, 1427, 1429,
    1433, 1439, 1447, 1451, 1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493, 1499, 1511, 1523, 1531, 1543, 1549, 1553,
    1559, 1567, 1571, 1579, 1583, 1597, 1601, 1607, 1609, 1613, 1619, 1621, 1627, 1637, 1657, 1663, 1667, 1669, 1693,
    1697, 1699, 1709, 1721, 1723, 1733, 1741, 1747, 1753, 1759, 1777, 1783, 1787, 1789, 1801, 1811, 1823, 1831, 1847,
    1861, 1867, 1871, 1873, 1877, 1879, 1889, 1901, 1907, 1913, 1931, 1933, 1949, 1951, 1973, 1979, 1987, 1993, 1997,
    1999, 2003, 2011, 2017, 2027, 2029, 2039, 2053, 2063, 2069, 2081, 2083, 2087, 2089, 2099, 2111, 2113, 2129, 2131,
    2137, 2141, 2143, 2153, 2161, 2179, 2203, 2207, 2213, 2221, 2237, 2239, 2243, 2251, 2267, 2269, 2273, 2281, 2287,
    2293, 2297, 2309, 2311, 2333, 2339, 2341, 2347, 2351, 2357, 2371, 2377, 2381, 2383, 2389, 2393, 2399, 2411, 2417,
    2423, 2437, 2441, 2447, 2459, 2467, 2473, 2477, 2503, 2521, 2531, 2539, 2543, 2549, 2551, 2557, 2579, 2591, 2593,
    2609, 2617, 2621, 2633, 2647, 2657, 2659, 2663, 2671, 2677, 2683, 2687, 2689, 2693, 2699, 2707, 2711, 2713, 2719,
    2729, 2731, 2741, 2749, 2753, 2767, 2777, 2789, 2791, 2797, 2801, 2803, 2819, 2833, 2837, 2843, 2851, 2857, 2861,
    2879, 2887, 2897, 2903, 2909, 2917, 2927, 2939, 2953, 2957, 2963, 2969, 2971, 2999, 3001, 3011, 3019, 3023, 3037,
    3041, 3049, 3061, 3067, 3079, 3083, 3089, 3109, 3119, 3121, 3137, 3163, 3167, 3169, 3181, 3187, 3191, 3203, 3209,
    3217, 3221, 3229, 3251, 3253, 3257, 3259, 3271, 3299, 3301, 3307, 3313, 3319, 3323, 3329, 3331, 3343, 3347, 3359,
    3361, 3371, 3373, 3389, 3391, 3407, 3413, 3433, 3449, 3457, 3461, 3463, 3467, 3469, 3491, 3499, 3511, 3517, 3527,
    3529, 3533, 3539, 3541, 3547, 3557, 3559, 3571, 3581, 3583, 3593, 3607, 3613, 3617, 3623, 3631, 3637, 3643, 3659,
    3671, 3673, 3677, 3691, 3697, 3701, 3709, 3719, 3727, 3733, 3739, 3761, 3767, 3769, 3779, 3793, 3797, 3803, 3821,
    3823, 3833, 3847, 3851, 3853, 3863, 3877, 3881, 3889, 3907, 3911, 3917, 3919, 3923, 3929, 3931, 3943, 3947, 3967,
    3989, 4001, 4003, 4007, 4013, 4019, 4021, 4027, 4049, 4051, 4057, 4073, 4079, 4091, 4093, 4099, 4111, 4127, 4129,
    4133, 4139, 4153, 4157, 4159, 4177, 4201, 4211, 4217, 4219, 4229, 4231, 4241, 4243, 4253, 4259, 4261, 4271, 4273,
    4283, 4289, 4297, 4327, 4337, 4339, 4349, 4357, 4363, 4373, 4391, 4397, 4409, 4421, 4423, 4441, 4447, 4451, 4457,
    4463, 4481, 4483, 4493, 4507, 4513, 4517, 4519, 4523, 4547, 4549, 4561, 4567, 4583, 4591, 4597, 4603, 4621, 4637,
    4639, 4643, 4649, 4651, 4657, 4663, 4673, 4679, 4691, 4703, 4721, 4723, 4729, 4733, 4751, 4759, 4783, 4787, 4789,
    4793, 4799, 4801, 4813, 4817, 4831, 4861, 4871, 4877, 4889, 4903, 4909, 4919, 4931, 4933, 4937, 4943, 4951, 4957,
    4967, 4969, 4973, 4987, 4993, 4999, 5003, 5009, 5011, 5021, 5023, 5039, 5051, 5059, 5077, 5081, 5087, 5099, 5101,
    5107, 5113, 5119, 5147, 5153, 5167, 5171, 5179, 5189, 5197, 5209, 5227, 5231, 5233, 5237, 5261, 5273, 5279, 5281,
    5297, 5303, 5309, 5323, 5333, 5347, 5351, 5381, 5387, 5393, 5399, 5407, 5413, 5417, 5419, 5431, 5437, 5441, 5443,
    5449, 5471, 5477, 5479, 5483, 5501, 5503, 5507, 5519, 5521, 5527, 5531, 5557, 5563, 5569, 5573, 5581, 5591, 5623,
    5639, 5641, 5647, 5651, 5653, 5657, 5659, 5669, 5683, 5689, 5693, 5701, 5711, 5717, 5737, 5741, 5743, 5749, 5779,
    5783, 5791, 5801, 5807, 5813, 5821, 5827, 5839, 5843, 5849, 5851, 5857, 5861, 5867, 5869, 5879, 5881, 5897, 5903,
    5923, 5927, 5939, 5953, 5981, 5987, 6007, 6011, 6029, 6037, 6043, 6047, 6053, 6067, 6073, 6079, 6089, 6091, 6101,
    6113, 6121, 6131, 6133, 6143, 6151, 6163, 6173, 6197, 6199, 6203, 6211, 6217, 6221, 6229, 6247, 6257, 6263, 6269,
    6271, 6277, 6287, 6299, 6301, 6311, 6317, 6323, 6329, 6337, 6343, 6353, 6359, 6361, 6367, 6373, 6379, 6389, 6397,
    6421, 6427, 6449, 6451, 6469, 6473, 6481, 6491, 6521, 6529, 6547, 6551, 6553, 6563, 6569, 6571, 6577, 6581, 6599,
    6607, 6619, 6637, 6653, 6659, 6661, 6673, 6679, 6689, 6691, 6701, 6703, 6709, 6719, 6733, 6737, 6761, 6763, 6779,
    6781, 6791, 6793, 6803, 6823, 6827, 6829, 6833, 6841, 6857, 6863, 6869, 6871, 6883, 6899, 6907, 6911, 6917, 6947,
    6949, 6959, 6961, 6967, 6971, 6977, 6983, 6991, 6997, 7001, 7013, 7019, 7027, 7039, 7043, 7057, 7069, 7079, 7103,
    7109, 7121, 7127, 7129, 7151, 7159, 7177, 7187, 7193, 7207, 7211, 7213, 7219, 7229, 7237, 7243, 7247, 7253, 7283,
    7297, 7307, 7309, 7321, 7331, 7333, 7349, 7351, 7369, 7393, 7411, 7417, 7433, 7451, 7457, 7459, 7477, 7481, 7487,
    7489, 7499, 7507, 7517, 7523, 7529, 7537, 7541, 7547, 7549, 7559, 7561, 7573, 7577, 7583, 7589, 7591, 7603, 7607,
    7621, 7639, 7643, 7649, 7669, 7673, 7681, 7687, 7691, 7699, 7703, 7717, 7723, 7727, 7741, 7753, 7757, 7759, 7789,
    7793, 7817, 7823, 7829, 7841, 7853, 7867, 7873, 7877, 7879, 7883, 7901, 7907, 7919, 7927, 7933, 7937, 7949, 7951,
    7963, 7993, 8009, 8011, 8017, 8039, 8053, 8059, 8069, 8081, 8087, 8089, 8093, 8101, 8111, 8117, 8123, 8147, 8161,
    8167, 8171, 8179, 8191, 8209, 8219, 8221, 8231, 8233, 8237, 8243, 8263, 8269, 8273, 8287, 8291, 8293, 8297, 8311,
    8317, 8329, 8353, 8363, 8369, 8377, 8387, 8389, 8419, 8423, 8429, 8431, 8443, 8447, 8461, 8467, 8501, 8513, 8521,
    8527, 8537, 8539, 8543, 8563, 8573, 8581, 8597, 8599, 8609, 8623, 8627, 8629, 8641, 8647, 8663, 8669, 8677, 8681,
    8689, 8693, 8699, 8707, 8713, 8719, 8731, 8737, 8741, 8747, 8753, 8761, 8779, 8783, 8803, 8807, 8819, 8821, 8831,
    8837, 8839, 8849, 8861, 8863, 8867, 8887, 8893, 8923, 8929, 8933, 8941, 8951, 8963, 8969, 8971, 8999, 9001, 9007,
    9011, 9013, 9029, 9041, 9043, 9049, 9059, 9067, 9091, 9103, 9109, 9127, 9133, 9137, 9151, 9157, 9161, 9173, 9181,
    9187, 9199, 9203, 9209, 9221, 9227, 9239, 9241, 9257, 9277, 9281, 9283, 9293, 9311, 9319, 9323, 9337, 9341, 9343,
    9349, 9371, 9377, 9391, 9397, 9403, 9413, 9419, 9421, 9431, 9433, 9437, 9439, 9461, 9463, 9467, 9473, 9479, 9491,
    9497, 9511, 9521, 9533, 9539, 9547, 9551, 9587, 9601, 9613, 9619, 9623, 9629, 9631, 9643, 9649, 9661, 9677, 9679,
    9689, 9697, 9719, 9721, 9733, 9739, 9743, 9749, 9767, 9769, 9781, 9787, 9791, 9803, 9811, 9817, 9829, 9833, 9839,
    9851, 9857, 9859, 9871, 9883, 9887, 9901, 9907, 9923, 9929, 9931, 9941, 9949, 9967, 9973};
unichar pgpBase64[65] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
      'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y',
      'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/', '='};



@implementation FGIntNumberBase
@synthesize digit;
-(id) copyWithZone: (NSZone *) zone {
	FGIntNumberBase *newFGIntNumberBase = [[FGIntNumberBase allocWithZone: zone] init];
	return [newFGIntNumberBase initWithFGIntBase: digit];
}
-(id) initWithBase10String: (NSString *) base10String {
	self = [self init];
	digit = (FGIntBase) [base10String longLongValue];
	return self;
}
-(id) initWithFGIntBase: (FGIntBase) initDigit {
	self = [self init];
	digit = initDigit;
	return self;
}
-(void) dealloc {
    [super dealloc];
}
@end



@implementation FGInt
@synthesize sign;
@synthesize length;

/*
   -(NSMutableArray *) number {
        return number;
   }

   - (id) init {
   self = [super init];
   number = [[NSMutableArray alloc] init];
   return self;
   }
 */

-(id) init {
    if (self = [super init]) {
        number = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id) initWithCapacity: (FGIntOverflow) capacity {
    if (self = [super init]) {
        number = [[NSMutableArray alloc] initWithCapacity: capacity];
    }
    return self;
}

-(id) initWithNumber: (NSMutableArray *) initNumber {
    if (self = [super init]) {
        number = [[NSMutableArray alloc] initWithArray: initNumber copyItems: YES];
    }
    return self;
}

-(id) initWithoutNumber {
    if (self = [super init]) {
    }
    return self;
}


//-(FGInt *) initWithNZeroes: (FGIntOverflow) n {
//    FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: 0];
//    self = [self init];
//
//    [self setLength: n];
//    [self setSign: YES];
//
//    SEL copySel = @selector(copy);
//    SEL addObjectSel = @selector(addObject:);
//    id (*objc_call)( id, SEL, ...);
//    objc_call = objc_msgSend;
//
//    (*objc_call)(number, addObjectSel, fGIntBase);
//    for ( FGIntOverflow i = 1; i < n; ++i ) 
//        (*objc_call)(number, addObjectSel, (*objc_call)(fGIntBase,copySel));
//
//    return self;
//}

-(FGInt *) initWithNZeroes: (FGIntOverflow) n {
    FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: 0], *fGIntBaseCopy;
//    self = [self initWithCapacity: n];
    self = [self init];

    [self setLength: n];
    [self setSign: YES];

//    number = [[NSMutableArray alloc] initWithCapacity: n];
    for ( FGIntOverflow i = 1; i < n; ++i ) {
        fGIntBaseCopy = [fGIntBase copy];
        [number addObject: fGIntBaseCopy];
        [fGIntBaseCopy release];
    }
    [number addObject: fGIntBase];
    [fGIntBase release];

    return self;
}



-(NSMutableArray *) number {
    return number;
}

-(void) setNumber: (NSMutableArray *) inputNumber {
    number = inputNumber;
}


//-(void) release {
//    for ( id fGIntBase in number )
//        [fGIntBase release];
//    [number release];
//    [super release];
//}
//

//-(id) copyWithZone: (NSZone *) zone {
//    FGInt *newFGInt = [[FGInt allocWithZone: zone] init];
//    NSMutableArray *newFGIntNumber = [newFGInt number];
//    [newFGInt setSign: sign];
//    [newFGInt setLength: length];    
//
//    SEL copySel = @selector(copy);
//    SEL addObjectSel = @selector(addObject:);
//    id (*objc_call)( id, SEL, ...);
//    objc_call = objc_msgSend;
//
//    for(id fGIntBase in number) {
//        (*objc_call)(newFGIntNumber, addObjectSel, (*objc_call)(fGIntBase,copySel));
//    }
//    return newFGInt;
//}
//
//-(void) dealloc {
//    SEL releaseSel = @selector(release);
//    id (*objc_call)( id, SEL, ...);
//    objc_call = objc_msgSend;
//
//    for ( id fGIntBase in number )
//        (*objc_call)(fGIntBase,releaseSel);
//    (*objc_call)(number,releaseSel);
//    [super dealloc];
//}



-(void) dealloc {
    [number release];
    [super dealloc];
}



-(id) copyWithZone: (NSZone *) zone {
    FGInt *newFGInt = [[FGInt allocWithZone: zone] initWithoutNumber];
    [newFGInt setSign: sign];
    [newFGInt setLength: length];    

    [newFGInt setNumber: [[NSMutableArray alloc] initWithArray: number copyItems: YES]];
    return newFGInt;
}

-(id) shallowCopy {
    FGInt *newFGInt = [[FGInt alloc] initWithoutNumber];
    [newFGInt setSign: sign];
    [newFGInt setLength: length];    

    [newFGInt setNumber: [[NSMutableArray alloc] initWithArray: number copyItems: NO]];
    return newFGInt;
}



//-(id) duplicate  {
//    FGInt *newFGInt = [[FGInt alloc] init];
//    [newFGInt setSign: sign];
//    [newFGInt setLength: length];    
//    for(id fGIntBase in number)
//        [[newFGInt number] addObject: [[FGIntNumberBase alloc] initWithFGIntBase: [fGIntBase digit]]];
//    return newFGInt;
//}


/* divides the number by a 32 bit unsigned int (divInt) and returns the remainder, it alters fGIntNumber */

+(FGIntBase) divideFGIntNumberByIntBis: (NSMutableArray *) fGIntNumber divideBy: (FGIntBase) divInt {
    FGIntBase mod = 0;
    FGIntOverflow tempMod = 0;
    
    @autoreleasepool{
        for( id fGIntBase in [fGIntNumber reverseObjectEnumerator] ) {
            tempMod =  (((FGIntOverflow) mod << 32) | (FGIntOverflow) [fGIntBase digit]);
            [fGIntBase setDigit: (FGIntOverflow) (tempMod / divInt)];
            mod = (FGIntOverflow) tempMod % divInt;
        }
    }

    while (([fGIntNumber count] > 1) && ([[fGIntNumber lastObject] digit] == 0)) {
        [fGIntNumber removeLastObject];
    }
    return mod;
}


/* returns a deep copy of the number */

-(NSMutableArray *) duplicateNumber {
    return [[NSMutableArray alloc] initWithArray: number copyItems: YES];
}



/* returns a decimal (base 10) string of the FGInt */

-(NSString *) toBase10String {
    @autoreleasepool{
        NSMutableArray *tempNumber = [self duplicateNumber];
        NSMutableString *tempString = [[NSMutableString alloc] init], *tmpStr;
        NSString *zeroStr = @"0";
        
        while (([tempNumber count] > 1) || ([[tempNumber objectAtIndex: 0] digit] != 0)) {
            tmpStr = (NSMutableString *) [NSString stringWithFormat:@"%u", [FGInt divideFGIntNumberByIntBis: tempNumber divideBy: 1000000000]];
            [tempString insertString: tmpStr atIndex:0];
            while (([tempString length] % 9) != 0) {
                [tempString insertString: zeroStr atIndex:0];
            }
        }
        [tempString insertString: zeroStr atIndex:0];
        while (([tempString characterAtIndex: 0] == '0') && ([tempString length] > 1))
            [tempString deleteCharactersInRange: NSMakeRange(0, 1)];
        if (!sign) [tempString insertString: @"-" atIndex:0];
        
        [tempNumber release];
        return tempString;
    }
}



-(FGIntBase) divideByFGIntBaseMaxBis: (NSMutableArray *) base10Number {
    @autoreleasepool{
        FGIntBase mod = 0;
        FGIntOverflow tempMod = 0;
        NSMutableString *base10StringResult = [[NSMutableString alloc] init], *tmpString;
        NSString *zeroStr = @"0", *tmpStr;
    
        for( id fGIntBase in [base10Number reverseObjectEnumerator] ) {
            tempMod =  (FGIntOverflow) mod*1000000000 + (FGIntOverflow) [fGIntBase digit];
            tmpString = [NSMutableString stringWithFormat:@"%u", (FGIntBase) (tempMod >> 32)];
            while (([tmpString length] % 9) != 0)
                [tmpString insertString: zeroStr atIndex:0];
            [base10StringResult appendString: tmpString];
            mod = tempMod;
        }
    
        FGIntOverflow nlength = [base10StringResult length];
        [base10Number removeAllObjects];
        FGIntNumberBase *tfginb;
        
        for(FGIntBase i = 1; i <= (nlength/9); ++i) {
            tmpStr = [base10StringResult substringWithRange: NSMakeRange(nlength - i*9, 9)];
            tfginb = [[FGIntNumberBase alloc] initWithBase10String: tmpStr];
            [base10Number addObject: tfginb];
            [tfginb release];
        }
        if ((nlength % 9) != 0) {
            tmpStr = [base10StringResult substringWithRange: NSMakeRange(0, nlength % 9)];
            tfginb = [[FGIntNumberBase alloc] initWithBase10String: tmpStr];
            [base10Number addObject: tfginb];
            [tfginb release];
        }
    
        while (([base10Number count] > 1) && ([[base10Number lastObject] digit] == 0)) {
            [base10Number removeLastObject];
        }
        [base10StringResult release];
        [zeroStr release];
            
        return mod;
    }
}


/* provide a decimal (base 10) NSString to initialize the FGInt, possibly preceded by a minus sign (a dash "-") */

-(FGInt *) initWithBase10String: (NSString *) base10String {
    @autoreleasepool{

        self = [self init];
    
        FGIntBase nlength = [base10String length];
        FGIntNumberBase *tfginb;
    
        if ([base10String characterAtIndex: 0] == '-') {
            sign = false;
            --nlength;
        } else
            sign = true;
        FGIntBase lengthInt = 1 + nlength / 9 + (((nlength % 9)==0) ? 0 : 1);
    
        NSMutableArray *base10Number = [[NSMutableArray alloc] init];
        NSString *tmpStr;
    
        for(FGIntBase i = 1; i <= (nlength/9); ++i) {
            tmpStr = [base10String substringWithRange: NSMakeRange(nlength + (sign ? 0 : 1) - i*9, 9)];
            tfginb = [[FGIntNumberBase alloc] initWithBase10String: tmpStr];
            [base10Number addObject: tfginb];
            [tfginb release];
        }
        if ((nlength % 9) != 0) {
            tmpStr = [base10String substringWithRange: NSMakeRange(sign ? 0 : 1, nlength % 9)];
            tfginb = [[FGIntNumberBase alloc] initWithBase10String: tmpStr];
            [base10Number addObject: tfginb];
            [tfginb release];
        }
    
        while (([base10Number count] > 1) || ([[base10Number objectAtIndex: 0] digit] != 0)) {
            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: [self divideByFGIntBaseMaxBis: base10Number]];
            [number addObject: tfginb]; 
            [tfginb release];
        }
        while (([number count] > 1) && ([[number lastObject] digit] == 0)) {
            [number removeLastObject];
        }
        if ([number count] == 0) {
            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: 0];
            [number addObject: tfginb];
            [tfginb release];
        }
        
        [base10Number release];
        [self setLength: [number count]];

        return self;
    }
}


/* provide an unsigned 32bit integer to initialize the FGInt */

-(FGInt *) initWithFGIntBase: (FGIntBase) fGIntBase {
    self = [self init];
    FGIntNumberBase *tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: fGIntBase];
    
    [number addObject: tfginb];
    [tfginb release];
    
    [self setLength: 1];
    [self setSign: YES];
        
    return self;
}


-(FGInt *) initWithNegativeFGIntBase: (FGIntBase) fGIntBase {
    self = [self init];
    FGIntNumberBase *tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: fGIntBase];
    
    [number addObject: tfginb];
    [tfginb release];
    
    [self setLength: 1];
    [self setSign: NO];
        
    return self;
}



/* provide a NSString to initialize the FGInt */

-(FGInt *) initWithNSString: (NSString *) string {
    @autoreleasepool{
        FGIntOverflow i;
        self = [self init];

        NSData *stringBytes = [string dataUsingEncoding:NSUTF8StringEncoding];

        return [self initWithNSData: stringBytes];
    }
}


/* provide NSData to initialize the FGInt */

-(FGInt *) initWithNSData: (NSData *) nsData {
    @autoreleasepool{
        FGIntOverflow i, nsDataLength = [nsData length];
        self = [self init];
    
        unsigned char aBuffer[4];
        NSRange bytesRange;
        FGIntNumberBase *fGIntBase;
        
        for ( i = 0; i < (nsDataLength / 4); ++i ) {
            bytesRange = NSMakeRange(nsDataLength - (i + 1)*4, 4);
            [nsData getBytes: aBuffer range: bytesRange];
            fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: (aBuffer[3] | (aBuffer[2] << 8) | (aBuffer[1] << 16) | (aBuffer[0] << 24))];
            [number addObject: fGIntBase];
            [fGIntBase release];
        }
        if (([nsData length] % 4) != 0) {
            bytesRange = NSMakeRange(0, nsDataLength % 4);
            [nsData getBytes: aBuffer range: bytesRange];
            FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: 0];
            for ( i = 0; i < (nsDataLength % 4); ++i ) 
                [fGIntBase setDigit: [fGIntBase digit] | (aBuffer[i] << (((nsDataLength % 4) - i - 1) * 8))];
            [number addObject: fGIntBase];
            [fGIntBase release];
        }
        while (([number count] > 1) && ([[number lastObject] digit] == 0)) 
            [number removeLastObject];
        [self setLength: [number count]];
        [self setSign: YES];
        return self;
    }
}



/* returns NSData of self */

-(NSData *) toNSData {
    @autoreleasepool{
        FGIntOverflow i = 0;
        FGIntBase digit, j, l;
        NSMutableData *fGIntData = [[NSMutableData alloc] init];
        unsigned char aBuffer[4];

        if ((length == 1) && ([[number objectAtIndex: 0] digit]== 0)) {
            aBuffer[0] = 0;
            [fGIntData appendBytes: aBuffer length: 1];
            return fGIntData;
        }
        
        for ( id fGIntBase in [number reverseObjectEnumerator] ) {
            if (i == 0) {
                ++i;
                digit = [fGIntBase digit];
                l = 0;
                for ( j = 0; j < 4; ++j ) {
                    if ((digit >> ((3 - j) * 8)) != 0) {
                        aBuffer[l] = ((digit >> ((3 - j) * 8)) & 255);
                        ++l;
                    }
                }
                [fGIntData appendBytes: aBuffer length: l];
            } else {
                digit = [fGIntBase digit];
                for ( j = 0; j < 4; ++j )
                    aBuffer[j] = ((digit >> ((3 - j) * 8)) & 255);
                [fGIntData appendBytes: aBuffer length: 4];
            }
        }
//    for ( id fGIntBase in number ) {
//        if (i < length - 1) {
//            digit = [fGIntBase digit];
//            for ( j = 0; j < 4; ++j )
//                aBuffer[j] = ((digit >> (j*8)) & 255);
//            [fGIntData appendBytes: aBuffer length: 4];
//        } else {
//            digit = [fGIntBase digit];
//            l = 0;
//            for ( j = 0; j < 4; ++j ) {
//                aBuffer[j] = ((digit >> (j*8)) & 255);
//                if ((digit >> (j*8)) != 0)
//                    ++l;
//            }
//            [fGIntData appendBytes: aBuffer length: l];
//        }
//        ++i;
//    }
        return fGIntData;
    }
}


-(NSData *) toMPINSData {
    NSMutableData *mpiData = [[NSMutableData alloc] init];
    NSData *tmpData;
    FGIntOverflow keyLength = (length - 1)*32; 
    unsigned char aBuffer[2];
    
    FGIntBase lastDigit = [[number lastObject] digit];
    while (lastDigit != 0) {
        ++keyLength;
        lastDigit >>= 1;
    }
    if (keyLength == 0)
        ++keyLength;
    aBuffer[0] = (keyLength / 256) & 255;
    aBuffer[1] = (keyLength) & 255;
    [mpiData appendBytes: aBuffer length: 2];
    tmpData = [self toNSData];
    [mpiData appendData: tmpData];
    [tmpData release];
    return mpiData;
}


/* convert self to an NSString, this does assume the self was previously a UTF8String, a random FGInt will not be */

-(NSString *) toNSString {
    NSData *tmpData = [self toNSData];
    NSString *str = [[NSString alloc] initWithData: tmpData encoding: NSUTF8StringEncoding];
    [tmpData release];
    return str;
}



/* Compare 2 FGInts in absolute value, returns
   larger if fGInt1 > fGInt2, smaller if fGInt1 < fGInt2, equal if fGInt1 = fGInt2,
   error otherwise */

+(tCompare) compareAbsoluteValueOf: (FGInt *) fGInt1 with: (FGInt *) fGInt2 {
    FGIntBase size1 = [fGInt1 length], size2 = [fGInt2 length], i = size2 - 1;

    if (size1 > size2)
        return larger;
    if (size1 < size2)
        return smaller;
    while (([[[fGInt1 number] objectAtIndex: i] digit] == [[[fGInt2 number] objectAtIndex: i] digit]) && (i > 0)) {
        --i;
    }
    if ([[[fGInt1 number] objectAtIndex: i] digit] == [[[fGInt2 number] objectAtIndex: i] digit])
        return equal;
    if ([[[fGInt1 number] objectAtIndex: i] digit] < [[[fGInt2 number] objectAtIndex: i] digit])
        return smaller;
    if ([[[fGInt1 number] objectAtIndex: i] digit] > [[[fGInt2 number] objectAtIndex: i] digit])
        return larger;
    return error;
}


/* add fGInt1 with fGInt2 and return a FGInt */


//+(FGInt *) add1: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
//    FGIntOverflow length1 = [fGInt1 length], length2 = [fGInt2 length], sumLength;
//    FGIntNumberBase *tfginb, *fGIntBase;
//    if (length1 < length2)
//        return [FGInt add: fGInt2 and: fGInt1];
//
//    if ([fGInt1 sign] == [fGInt2 sign]) {
//        FGInt *sum = [fGInt1 copy];
//        NSMutableArray *sumNumber = [sum number], *fGInt2Number = [fGInt2 number];
//        FGIntOverflow i = 0, tmpMod, mod = 0;
//        NSEnumerator *tmpEnum1 = [sumNumber objectEnumerator];
//
//            
//        for ( fGIntBase in fGInt2Number ) {
//            tfginb = [tmpEnum1 nextObject];
//            tmpMod = (FGIntOverflow) [tfginb digit] + [fGIntBase digit] + mod;
//            [tfginb setDigit: tmpMod];
//            mod = tmpMod >> 32;
//        }
//        while ( tfginb = [tmpEnum1 nextObject] ) {
//            tmpMod = (FGIntOverflow) [tfginb digit] + mod;
//            [tfginb setDigit: tmpMod];
//            mod = tmpMod >> 32;
//        }
//        [tmpEnum1 release];
//        sumLength = length1 + ((mod == 0) ? 0 : 1);
//        if (mod != 0) {
//            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: mod];
//            [sumNumber addObject: tfginb];
//            [tfginb release];
//        }
//        [sum setSign: [fGInt1 sign]];
//        [sum setLength: sumLength];
//        return sum;
//    } else {
//        if ([FGInt compareAbsoluteValueOf: fGInt2 with: fGInt1] == larger)
//            return [FGInt add: fGInt2 and: fGInt1];
//        FGIntOverflow tmpMod, mod = 0, i;
//        FGInt *sum = [[FGInt alloc] init];
//        NSMutableArray *sumNumber = [sum number], *fGInt2Number = [fGInt2 number], *fGInt1Number = [fGInt1 number];
//
//        for ( i = 0; i < length2; ++i ) {
//            tmpMod = (FGIntOverflow) 4294967296 + [[fGInt1Number objectAtIndex: i] digit] - [[fGInt2Number objectAtIndex: i] digit] - mod;
//            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: tmpMod];
//            [sumNumber addObject: tfginb];
//            [tfginb release];
//            mod = (tmpMod > 4294967295u) ? 0 : 1;
//        }
//        for ( i = length2; i < length1; ++i ) {
//            tmpMod = (FGIntOverflow) 4294967296 + [[fGInt1Number objectAtIndex: i] digit] - mod;
//            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: tmpMod];
//            [sumNumber addObject: tfginb];
//            [tfginb release];
//            mod = (tmpMod > 4294967295u) ? 0 : 1;
//        }
//
//        sumLength = length1;
//        while ((sumLength > 1) && ([[sumNumber lastObject] digit] == 0)) {
//            sumLength -= 1;
//            [sumNumber removeLastObject];
//        }
//        [sum setLength: sumLength];
//        if ((sumLength == 1) && ([[sumNumber lastObject] digit] == 0))
//            [sum setSign: YES];
//        else
//            [sum setSign: [fGInt1 sign]];
//
//        return sum;
//    }
//}


+(FGInt *) add: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = [fGInt1 length], length2 = [fGInt2 length], sumLength;
    FGIntNumberBase *tfginb, *fGIntBase, *sumBase;
    if (length1 < length2)
        return [FGInt add: fGInt2 and: fGInt1];

    if ([fGInt1 sign] == [fGInt2 sign]) {
        FGInt *sum = [fGInt1 copy];
        NSMutableArray *sumNumber = [sum number], *fGInt2Number = [fGInt2 number], *fGInt1Number = [fGInt1 number];
        FGIntOverflow i = 0, tmpMod, mod = 0;

            
        for ( fGIntBase in fGInt2Number ) {
            sumBase = [sumNumber objectAtIndex: i];
            tmpMod = (FGIntOverflow) [sumBase digit] + [fGIntBase digit] + mod;
            [sumBase setDigit: tmpMod];
            mod = tmpMod >> 32;
            ++i;
        }
        for ( i = length2; i < length1; ++i ) {
            if (mod == 0)
                break;
            sumBase = [sumNumber objectAtIndex: i];
            tmpMod = (FGIntOverflow) [sumBase digit] + mod;
            [sumBase setDigit: tmpMod];
            mod = tmpMod >> 32;
        }
        sumLength = length1 + ((mod == 0) ? 0 : 1);
        if (mod != 0) {
            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: mod];
            [sumNumber addObject: tfginb];
            [tfginb release];
        }
        [sum setSign: [fGInt1 sign]];
        [sum setLength: sumLength];
        return sum;
    } else {
        if ([FGInt compareAbsoluteValueOf: fGInt2 with: fGInt1] == larger)
            return [FGInt add: fGInt2 and: fGInt1];
        FGIntOverflow tmpMod, mod = 0, i = 0;
        FGInt *sum = [fGInt1 copy];
        NSMutableArray *sumNumber = [sum number], *fGInt2Number = [fGInt2 number], *fGInt1Number = [fGInt1 number];


        for ( fGIntBase in fGInt2Number ) {
            sumBase = [sumNumber objectAtIndex: i];
            tmpMod = (FGIntOverflow) 4294967296 + [sumBase digit] - [fGIntBase digit] - mod;
            [sumBase setDigit: tmpMod];
            mod = (tmpMod > 4294967295u) ? 0 : 1;
            ++i;
        }
        for ( i = length2; i < length1; ++i ) {
            if (mod == 0)
                break;
            sumBase = [sumNumber objectAtIndex: i];
            tmpMod = (FGIntOverflow) 4294967296 + [sumBase digit] - mod;
            [sumBase setDigit: tmpMod];
            mod = (tmpMod > 4294967295u) ? 0 : 1;
        }

        sumLength = length1;
        while ((sumLength > 1) && ([[sumNumber lastObject] digit] == 0)) {
            sumLength -= 1;
            [sumNumber removeLastObject];
        }
        [sum setLength: sumLength];
        if ((sumLength == 1) && ([[sumNumber lastObject] digit] == 0))
            [sum setSign: YES];
        else
            [sum setSign: [fGInt1 sign]];

        return sum;
    }
}



+(FGInt *) add1: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntOverflow length1 = [fGInt1 length], length2 = [fGInt2 length], sumLength;
    FGIntNumberBase *tfginb, *fGIntBase, *sumBase;
    if (length1 < length2)
        return [FGInt add: fGInt2 and: fGInt1];

    if ([fGInt1 sign] == [fGInt2 sign]) {
        FGInt *sum = [fGInt1 copy];
        NSMutableArray *sumNumber = [sum number], *fGInt2Number = [fGInt2 number], *fGInt1Number = [fGInt1 number];
        FGIntOverflow i = 0, tmpMod, mod = 0;

        FGIntBase tmpFGInt1Number[[fGInt1 length]];
        for ( fGIntBase in fGInt1Number ) {
        	tmpFGInt1Number[i] = [fGIntBase digit];
        	++i;
       	}


        i = 0;
        for ( fGIntBase in fGInt2Number ) {
            tmpMod = (FGIntOverflow) tmpFGInt1Number[i] + [fGIntBase digit] + mod;
            [sumBase setDigit: tmpMod];
            mod = tmpMod >> 32;
            ++i;
        }
        for ( i = length2; i < length1; ++i ) {
            if (mod == 0)
                break;
            sumBase = [sumNumber objectAtIndex: i];
            tmpMod = (FGIntOverflow) [sumBase digit] + mod;
            [sumBase setDigit: tmpMod];
            mod = tmpMod >> 32;
        }
        sumLength = length1 + ((mod == 0) ? 0 : 1);
        if (mod != 0) {
            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: mod];
            [sumNumber addObject: tfginb];
            [tfginb release];
        }
        [sum setSign: [fGInt1 sign]];
        [sum setLength: sumLength];
        return sum;
    } else {
        if ([FGInt compareAbsoluteValueOf: fGInt2 with: fGInt1] == larger)
            return [FGInt add: fGInt2 and: fGInt1];
        FGIntOverflow tmpMod, mod = 0, i = 0;
        FGInt *sum = [fGInt1 copy];
        NSMutableArray *sumNumber = [sum number], *fGInt2Number = [fGInt2 number], *fGInt1Number = [fGInt1 number];


        for ( fGIntBase in fGInt2Number ) {
            sumBase = [sumNumber objectAtIndex: i];
            tmpMod = (FGIntOverflow) 4294967296 + [sumBase digit] - [fGIntBase digit] - mod;
            [sumBase setDigit: tmpMod];
            mod = (tmpMod > 4294967295u) ? 0 : 1;
            ++i;
        }
        for ( i = length2; i < length1; ++i ) {
            if (mod == 0)
                break;
            sumBase = [sumNumber objectAtIndex: i];
            tmpMod = (FGIntOverflow) 4294967296 + [sumBase digit] - mod;
            [sumBase setDigit: tmpMod];
            mod = (tmpMod > 4294967295u) ? 0 : 1;
        }

        sumLength = length1;
        while ((sumLength > 1) && ([[sumNumber lastObject] digit] == 0)) {
            sumLength -= 1;
            [sumNumber removeLastObject];
        }
        [sum setLength: sumLength];
        if ((sumLength == 1) && ([[sumNumber lastObject] digit] == 0))
            [sum setSign: YES];
        else
            [sum setSign: [fGInt1 sign]];

        return sum;
    }
}

//+(FGInt *) add2: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
//    FGIntOverflow length1 = [fGInt1 length], length2 = [fGInt2 length], sumLength;
//    FGIntNumberBase *tfginb, *fGIntBase;
//    if (length1 < length2)
//        return [FGInt add: fGInt2 and: fGInt1];
//
//    if ([fGInt1 sign] == [fGInt2 sign]) {
//        FGInt *sum = [fGInt1 copy];
//        NSMutableArray *sumNumber = [sum number], *fGInt2Number = [fGInt2 number];
//        FGIntNumberBase *sumBase;
//
//        FGIntOverflow tmpMod = 0, mod = 0, i = 0;
//        for ( i = 0; i < length2; ++i ) {
//            sumBase = [sumNumber objectAtIndex: i];
//            tmpMod = (FGIntOverflow) [sumBase digit] + [[fGInt2Number objectAtIndex: i] digit] + mod;
//            [sumBase setDigit: tmpMod];
//            mod = tmpMod >> 32;
//        }
//        for ( i = length2; i < length1; ++i ) {
//            sumBase = [sumNumber objectAtIndex: i];
//            tmpMod = (FGIntOverflow) [sumBase digit] + mod;
//            [sumBase setDigit: tmpMod];
//            mod = tmpMod >> 32;
//        }
//        sumLength = length1 + ((mod == 0) ? 0 : 1);
//        if (mod != 0) {
//            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: mod];
//            [sumNumber addObject: tfginb];
//            [tfginb release];
//        }
//        [sum setSign: [fGInt1 sign]];
//        [sum setLength: sumLength];
//        return sum;
//    } else {
//        if ([FGInt compareAbsoluteValueOf: fGInt2 with: fGInt1] == larger)
//            return [FGInt add: fGInt2 and: fGInt1];
//        FGIntOverflow tmpMod, mod = 0, i;
//        FGInt *sum = [[FGInt alloc] init];
//        NSMutableArray *sumNumber = [sum number], *fGInt2Number = [fGInt2 number], *fGInt1Number = [fGInt1 number];
//
//        for ( i = 0; i < length2; ++i ) {
//            tmpMod = (FGIntOverflow) 4294967296 + [[fGInt1Number objectAtIndex: i] digit] - [[fGInt2Number objectAtIndex: i] digit] - mod;
//            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: tmpMod];
//            [sumNumber addObject: tfginb];
//            [tfginb release];
//            mod = (tmpMod > 4294967295u) ? 0 : 1;
//        }
//        for ( i = length2; i < length1; ++i ) {
//            tmpMod = (FGIntOverflow) 4294967296 + [[fGInt1Number objectAtIndex: i] digit] - mod;
//            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: tmpMod];
//            [sumNumber addObject: tfginb];
//            [tfginb release];
//            mod = (tmpMod > 4294967295u) ? 0 : 1;
//        }
//
//        sumLength = length1;
//        while ((sumLength > 1) && ([[sumNumber lastObject] digit] == 0)) {
//            sumLength -= 1;
//            [sumNumber removeLastObject];
//        }
//        [sum setLength: sumLength];
//        if ((sumLength == 1) && ([[sumNumber lastObject] digit] == 0))
//            [sum setSign: YES];
//        else
//            [sum setSign: [fGInt1 sign]];
//
//        return sum;
//    }
//}




-(void) changeSign {
    [self setSign: ![self sign]];
}


/* subtract fGInt1 with fGInt2 and return a FGInt */

+(FGInt *) subtract: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGInt *result;
    [fGInt2 changeSign];
    result = [FGInt add: fGInt1 and: fGInt2];
    [fGInt2 changeSign];
    return result;
}


/* Multiply 2 FGInts, and return fGInt1 * fGInt2 */

+(FGInt *) pencilPaperMultiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntBase length1 = [fGInt1 length],
              length2 = [fGInt2 length],
              productLength = length1 + length2, i, j, fGIntBaseDigit;
    FGIntNumberBase *tfginb, *fGIntBase1, *fGIntBase2, *productBase;
    FGIntOverflow tempMod, mod;
    NSMutableArray *fGInt1Number = [fGInt1 number], *fGInt2Number = [fGInt2 number];

    FGInt *product = [[FGInt alloc] initWithNZeroes: productLength];
    NSMutableArray *productNumber = [product number];

    [product setSign: [fGInt1 sign] == [fGInt2 sign]];

    i = 0;
    for( id fGIntBase2 in fGInt2Number ) {
        mod = 0;
        j = 0;
        fGIntBaseDigit = [fGIntBase2 digit];
        for( id fGIntBase1 in fGInt1Number ) {
            productBase = [productNumber objectAtIndex: j + i];
            tempMod = (FGIntOverflow) [fGIntBase1 digit] * fGIntBaseDigit + [productBase digit] + mod;
            [productBase setDigit: tempMod];
            mod = tempMod >> 32;
            ++j;
        }
        [[productNumber objectAtIndex: (i + j)] setDigit: mod];
        ++i;        
    }
    while ((productLength > 1) && ([[productNumber lastObject] digit] == 0)) {
        --productLength;
        [productNumber removeLastObject];
    }
    [product setLength: productLength];
    if ((productLength == 1) && ([[productNumber lastObject] digit] == 0))
        [product setSign: YES];
    else
        [product setSign: ([fGInt1 sign]==[fGInt2 sign])];
    return product;
}



+(FGInt *) karatsubaMultiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntBase length1 = [fGInt1 length],
              length2 = [fGInt2 length],
              karatsubaLength = MAX(length1, length2);

    if (karatsubaLength <= karatsubaThreshold) return [FGInt pencilPaperMultiply: fGInt1 and: fGInt2];

    if (length1 != karatsubaLength) return [FGInt karatsubaMultiply: fGInt2 and: fGInt1];

    FGIntOverflow halfLength = (karatsubaLength / 2) + (karatsubaLength % 2), i;

    FGInt *f1a = [[FGInt alloc] init], *f1b = [[FGInt alloc] init],
    *f2a, *f2b = [[FGInt alloc] init],
    *faa, *fbb, *fab, *f1ab, *f2ab, *zero;
    NSMutableArray *f1aNumber = [f1a number], *f1bNumber = [f1b number],
    *f2aNumber, *f2bNumber = [f2b number];

    zero = [[FGInt alloc] initWithFGIntBase: 0];

    [f1a setSign: [fGInt1 sign]];
    [f1b setSign: [fGInt1 sign]];
    i = 0;
    for ( id fGIntBase in [fGInt1 number]) {
        if ( i < halfLength ) {
            [f1bNumber addObject: fGIntBase];
        } else {
            [f1aNumber addObject: fGIntBase];
        }
        ++i;
    }
    [f1b setLength: halfLength];
    [f1a setLength: karatsubaLength - halfLength];

    if ( length2 <= halfLength ) {
        f2a = [zero copy];
        [f2a setSign: [fGInt2 sign]];
        for ( id fGIntBase in [fGInt2 number]) 
            [f2bNumber addObject: fGIntBase];
        [f2b setSign: [fGInt2 sign]];
        [f2b setLength: [fGInt2 length]];
    } else {
        f2a = [[FGInt alloc] init];
        f2aNumber = [f2a number];
        [f2a setSign: [fGInt2 sign]];
        [f2b setSign: [fGInt2 sign]];

        i = 0;
        for ( id fGIntBase in [fGInt2 number] ) {
            if ( i < halfLength ) {
                [f2bNumber addObject: fGIntBase];
            } else {
                [f2aNumber addObject: fGIntBase];
            }
            ++i;
        }
        [f2b setLength: halfLength];
        [f2a setLength: length2 - halfLength];
    }
    if (([FGInt compareAbsoluteValueOf: f1a with: zero] != equal) && ([FGInt compareAbsoluteValueOf: f2a with: zero] != equal))
        faa = [FGInt karatsubaMultiply: f1a and: f2a];
    else {
        faa = [zero copy];
        [faa setSign: [f1a sign] == [f2a sign]];
    }
    if (([FGInt compareAbsoluteValueOf: f1b with: zero] != equal) && ([FGInt compareAbsoluteValueOf: f2b with: zero] != equal))
        fbb = [FGInt karatsubaMultiply: f1b and: f2b];
    else {
        fbb = [zero copy];
        [fbb setSign: [f1b sign] == [f2b sign]];
    }
    f1ab = [FGInt add: f1a and: f1b];
    f2ab = [FGInt add: f2a and: f2b];
    if (([FGInt compareAbsoluteValueOf: f1ab with: zero] != equal) && ([FGInt compareAbsoluteValueOf: f2ab with: zero] != equal))
        fab = [FGInt karatsubaMultiply: f1ab and: f2ab];
    else {
        fab = [zero copy];
        [fab setSign: [f1a sign] == [f2a sign]];
    }



    [zero release];
    [f1a release];
    [f2a release];
    [f1ab release];
    [f2ab release];
    [f1b release];
    [f2b release];
    [fab subtractWith: faa];
    [fab subtractWith: fbb];
    FGInt *product = faa;
    [product shiftLeftBy32Times: halfLength*2];
    [fab shiftLeftBy32Times: halfLength];
    [product addWith: fab];
    [fab release];
    [product addWith: fbb];
    [fbb release];
    [product setSign: [fGInt1 sign] == [fGInt2 sign]];

    return product;
}


+(FGInt *) multiply: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGIntBase length1 = [fGInt1 length],
              length2 = [fGInt2 length],
              length = MAX(length1,length2);
    if (length >= karatsubaThreshold)
        return [FGInt karatsubaMultiply: fGInt1 and: fGInt2];
    else
        return [FGInt pencilPaperMultiply: fGInt1 and: fGInt2];
}


/* square a FGInt, return fGInt^2 */

+(FGInt *) pencilPaperSquare: (FGInt *) fGInt {
    FGIntOverflow length1 = [fGInt length], tempMod, mod, overflow,
              squareLength = 2 * length1, i, j, k, tempInt;
//    FGIntBase fGIntBaseDigit;
    FGIntNumberBase *squareBase;
    NSArray *fGIntNumber = [fGInt number];

    FGInt *square = [[FGInt alloc] initWithNZeroes: squareLength];
    NSMutableArray *squareNumber = [square number];

    i = 0;
    for( id fGIntBase1 in fGIntNumber ) {
        tempInt = [fGIntBase1 digit];
        squareBase = [squareNumber objectAtIndex: 2 * i];
        tempMod = (FGIntOverflow) tempInt*tempInt + [squareBase digit];
        [squareBase setDigit: tempMod];
        mod = (tempMod >> 32);
        j = 0;
        for( id fGIntBase2 in fGIntNumber ) {
            if (j > i) {
                overflow = 0;
                squareBase = [squareNumber objectAtIndex: i + j];
                tempMod = (FGIntOverflow) tempInt * [fGIntBase2 digit];
                if ((tempMod >> 63) == 1)
                    overflow = 1;
                tempMod = (tempMod << 1) + [squareBase digit] + mod;
                [squareBase setDigit: tempMod];
                mod = (overflow << 32) | (tempMod >> 32);
            }
            ++j;
        }
        k = 0;
        while (mod != 0) {
            squareBase = [squareNumber objectAtIndex: (i + length1 + k)];
            tempMod = (FGIntOverflow) [squareBase digit] + mod;
            [squareBase setDigit: tempMod];
            mod = tempMod >> 32;
            ++k;
        }
        ++i;
    }

    while ((squareLength > 1) && ([[squareNumber lastObject] digit] == 0)) {
        --squareLength;
        [squareNumber removeLastObject];
    }
    [square setLength: squareLength];
    return square;
}


+(FGInt *) karatsubaSquare: (FGInt *) fGInt {
    FGIntOverflow karatsubaLength = [fGInt length];
    FGIntOverflow halfLength = (karatsubaLength / 2) + (karatsubaLength % 2), i;

    if (karatsubaLength <= karatsubaThreshold) return [FGInt pencilPaperSquare: fGInt];

    FGInt *fa = [[FGInt alloc] init], *fb = [[FGInt alloc] init],
    *faa, *fbb, *fab, *zero;
    NSMutableArray *faNumber = [fa number], *fbNumber = [fb number], *fGIntNumber = [fGInt number];
    zero = [[FGInt alloc] initWithFGIntBase: 0];
    FGIntNumberBase *fGIntBaseCopy;

    i = 0;
    for ( id fGIntBase in fGIntNumber ) {
        if ( i < halfLength ) {
            [fbNumber addObject: fGIntBase];
        } else {
            fGIntBaseCopy = [fGIntBase copy];
            [faNumber addObject: fGIntBaseCopy];
            [fGIntBaseCopy release];
        }
        ++i;
    }
    [fb setLength: halfLength];
    [fa setLength: karatsubaLength - halfLength];
        
    while (([fa length] > 1) && ([[faNumber lastObject] digit] == 0)) {
        [fa setLength: [fa length] - 1];
        [faNumber removeLastObject];
    }

    if ([FGInt compareAbsoluteValueOf: fa with: zero] != equal)
        faa = [FGInt karatsubaSquare: fa];
    else
        faa = [zero copy];

    while (([fb length] > 1) && ([[[fb number] lastObject] digit] == 0)) {
        [fb setLength: [fb length] - 1];
        [fbNumber removeLastObject];
    }

    if ([FGInt compareAbsoluteValueOf: fb with: zero] != equal)
        fbb = [FGInt karatsubaSquare: fb];
    else
        fbb = [zero copy];

    [fa addWith: fb];
    if ([FGInt compareAbsoluteValueOf: fa with: zero] != equal)
        fab = [FGInt karatsubaSquare: fa];
    else
        fab = [zero copy];
    
    [zero release];
    [fa release];
    [fb release];
    [fab subtractWith: faa];
    [fab subtractWith: fbb];
    FGInt *square = faa;
    [square shiftLeftBy32Times: halfLength*2];
    [fab shiftLeftBy32Times: halfLength];
    [square addWith: fab];
    [fab release];
    [square addWith: fbb];
    [fbb release];
    [square setSign: YES];

    return square;
}


+(FGInt *) square: (FGInt *) fGInt {
    FGIntBase length = [fGInt length];

    if (length >= karatsubaThreshold)
        return [FGInt karatsubaSquare: fGInt];
    else
        return [FGInt pencilPaperSquare: fGInt];
}



/* raise fGInt to the power fGIntN, and return fGInt ^ fGIntN */

+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN {
    FGIntOverflow nLength = [fGIntN length], i, j;
    FGIntNumberBase *tfginb;
    FGIntBase tmp;
    FGInt *tmpFGInt1, *tmpFGInt2, *tmpFGInt;

    FGInt *power = [[FGInt alloc] initWithFGIntBase: 1];
    tmpFGInt1 = [fGInt copy];

    i = 0;
    for( id fGIntBase in [fGIntN number] ) {
        tmp = [fGIntBase digit];
        if (i < nLength - 1)
            for(j = 0; j < 32; ++j) {
                if (((tmp >> j) % 2) == 1) {
                    tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
                    [power release];
                    power = tmpFGInt;
                }
                tmpFGInt = [FGInt square: tmpFGInt1];
                [tmpFGInt1 release];
                tmpFGInt1 = tmpFGInt;
            }
    }
    j = 0;
    tmp = [[[fGIntN number] lastObject] digit];
    while((tmp >> j)  != 0) {
        if (((tmp >> j) % 2) == 1) {
            tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
            [power release];
            power = tmpFGInt;
        }
        ++j;
        if ((tmp >> j)  != 0)
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = tmpFGInt;
    }
    return power;
}


/* bitwise shift of self by 32 */

-(void) shiftLeftBy32 {
    if ((length != 1) || ([[number objectAtIndex: 0] digit] != 0)) {
        [self setLength: length + 1];
        FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: 0];
        [number insertObject: fGIntBase atIndex: 0];
        [fGIntBase release];
    }
}

-(void) shiftRightBy32 {
    if (length == 1) {
        [[number objectAtIndex: 0] setDigit: 0];
    } else {
        [self setLength: length - 1];
        [number removeObjectAtIndex: 0];
    }
}

-(void) shiftLeftBy32Times: (FGIntOverflow) n {
    if (((length != 1) || ([[number objectAtIndex: 0] digit] != 0)) && (n > 0)) {
        FGIntOverflow i;
        [self setLength: length + n];

        FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: 0], *fGIntBaseCopy;
    
        for ( i = 1; i < n; ++i ) {
            fGIntBaseCopy = [fGIntBase copy];
            [number insertObject: fGIntBaseCopy atIndex: 0];
            [fGIntBaseCopy release];
        }
        [number insertObject: fGIntBase atIndex: 0];
        [fGIntBase release];
    }
}



-(void) shiftRightBy32Times: (FGIntOverflow) n {
    if (n >= length) {
        [number removeObjectsInRange: NSMakeRange(0, length - 1)];
        [self setLength: 1];
        [[number objectAtIndex: 0] setDigit: 0];
    } else {
        [self setLength: length - n];
        [number removeObjectsInRange: NSMakeRange(0, n)];
    }
}



-(void) shiftLeft {
    FGIntOverflow tmpInt, mod = 0, i;

    for( id fGIntBase in number ) {
        tmpInt = [fGIntBase digit];
        [fGIntBase setDigit: mod | (tmpInt << 1)];
        mod = tmpInt >> 31;
    }
    if (mod != 0) {
        FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: mod];
        [number addObject: fGIntBase];
        [fGIntBase release];
        [self setLength: length + 1];
    }
}


-(void) shiftRight {
    FGIntOverflow tmpInt, mod = 0, i;

    @autoreleasepool{
        for( id fGIntBase in [number reverseObjectEnumerator] ) {
            tmpInt = [fGIntBase digit];
            [fGIntBase setDigit: mod | (tmpInt >> 1)];
            mod = tmpInt << 31;
        }
    }
    if (([[number lastObject] digit] == 0) && (length > 1)) {
        [number removeLastObject];
        [self setLength: length - 1];
    }
}


/* by can be any positive integer */

-(void) shiftRightBy: (FGIntBase) by {
    FGIntOverflow tmpInt, mod = 0, by32Times = by / 32, byMod32 = by % 32;

    if (by32Times != 0) {
        if (by32Times >= length) {
            [number removeObjectsInRange: NSMakeRange(0, length - 1)];
            [self setLength: 1];
            [[number objectAtIndex: 0] setDigit: 0];
        } else {
            [self setLength: length - by32Times];
            [number removeObjectsInRange: NSMakeRange(0, by32Times)];
        }
    }
        
    if (byMod32 != 0) {
        @autoreleasepool{
            for( id fGIntBase in [number reverseObjectEnumerator] ) {
                tmpInt = [fGIntBase digit];
                [fGIntBase setDigit: mod | (tmpInt >> byMod32)];
                mod = tmpInt << (32 - byMod32);
            }
        }
        if (([[number lastObject] digit] == 0) && (length > 1)) {
            [number removeLastObject];
            [self setLength: length - 1];
        }
    }
}


-(void) shiftLeftBy: (FGIntBase) by {
    FGIntOverflow tmpInt, mod = 0, by32Times = by / 32, byMod32 = by % 32, i;

    if (((length != 1) || ([[number objectAtIndex: 0] digit] != 0)) && (by32Times > 0)) {
        [self setLength: length + by32Times];

        FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: 0], *fGIntBaseCopy;
    
        for ( i = 1; i < by32Times; ++i ) {
            fGIntBaseCopy = [fGIntBase copy];
            [number insertObject: fGIntBaseCopy atIndex: 0];
            [fGIntBaseCopy release];
        }
        [number insertObject: fGIntBase atIndex: 0];
        [fGIntBase release];
    }
        
    if (byMod32 != 0) {
        for( id fGIntBase in number ) {
            tmpInt = [fGIntBase digit];
            [fGIntBase setDigit: mod | (tmpInt << byMod32)];
            mod = tmpInt >> (32 - byMod32);
        }
        if (mod != 0) {
            FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: mod];
            [number addObject: fGIntBase];
            [fGIntBase release];
            [self setLength: length + 1];
        }
    }
}


-(void) increment {
    FGIntOverflow mod = 1, tmpMod, i = 0;
    FGIntNumberBase *tfginb;
    NSMutableArray *fGIntNumber = number;

    for (id fGIntBase in fGIntNumber ) {
        tmpMod = (FGIntOverflow) [fGIntBase digit] + mod;
        [fGIntBase setDigit: tmpMod];
        mod = tmpMod >> 32;
    }
    
    if (mod != 0) {
        ++length;
        tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: (FGIntBase) mod];
        [number addObject: tfginb];
        [tfginb release];
    }
}

-(void) decrement {
    FGIntOverflow mod = 1, tmpMod, i = 0;

    if ((length > 1) || ([[number objectAtIndex: 0] digit] != 0)) {
        for (id fGIntBase in number ) {
            tmpMod = (FGIntOverflow) (4294967296u | [fGIntBase digit]) - mod;
            if (tmpMod > 4294967295u) 
                mod = 0; 
            else 
                mod = 1;
            [fGIntBase setDigit: tmpMod];
            if (mod == 0)
                break;
        }
        while ((length > 1) && ([[number lastObject] digit] == 0)) {
            --length;
            [number removeLastObject];
        }
    } 
}




/* multiply the self by a 32bit unsigned integer */

-(void) multiplyByInt: (FGIntBase) multInt {
    FGIntOverflow tmpInt, mod = 0;
    FGIntBase i;

    for( id fGIntBase in number ) {
        tmpInt = (FGIntOverflow) [fGIntBase digit] * multInt;
        tmpInt += (FGIntOverflow) mod;
        [fGIntBase setDigit: (FGIntBase) tmpInt];
        mod = tmpInt >> 32;
    }
    if (mod != 0) {
        FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: mod];
        [number addObject: fGIntBase];
        [fGIntBase release];
        ++length;
//        [self setLength: [self length] + 1];
    }
}


/* replaces self with self - fGInt, assumes that 0 < fGInt < self */

-(void) subtractWith: (FGInt *) fGInt {
    FGIntBase length1 = [self length], length2 = [fGInt length];
    FGIntOverflow mod = 0, tmpMod, i = 0;
    FGIntNumberBase *numberBase;

//    if (length2 > length1) {
//        NSLog(@"Oh-oh, length1 = %u, and length2 is %u and and selfcount is %lu count is %lu",length1, length2,[[self number] count], [[fGInt number] count]);
//        NSLog(@"the base10 string of  self %@",[self toBase10String]);
//        NSLog(@"the base10 string of fgint %@",[fGInt toBase10String]);
//    }

//    for( id fGIntBase in [fGInt number] ) {
    for( i = 0; i < length2; ++i ) {
        numberBase = [number objectAtIndex: i];
        tmpMod = (FGIntOverflow) (4294967296u | [numberBase digit]) - [[[fGInt number] objectAtIndex: i] digit] - mod;
        if (tmpMod > 4294967295u) mod = 0; else mod = 1;
        [numberBase setDigit: tmpMod];
    }
    for( i = length2; i < length1; ++i ) {
        if (mod == 0)
            break;
        numberBase = [number objectAtIndex: i];
        tmpMod = (FGIntOverflow) (4294967296u | [numberBase digit]) - mod;
        if (tmpMod > 4294967295u) mod = 0; else mod = 1;
        [numberBase setDigit: tmpMod];
    }
    while ((length1 > 1) && ([[number lastObject] digit] == 0)) {
        --length1;
        [number removeLastObject];
    }
    [self setLength: length1];
}

//-(void) subtractWith1: (FGInt *) fGInt {
//    FGIntBase length1 = [self length], length2 = [fGInt length];
//    FGIntOverflow mod = 0, tmpMod, i = 0;
//    FGIntNumberBase *numberBase;
//
////    if (length2 > length1) {
////        NSLog(@"Oh-oh, length1 = %u, and length2 is %u and and selfcount is %lu count is %lu",length1, length2,[[self number] count], [[fGInt number] count]);
////        NSLog(@"the base10 string of  self %@",[self toBase10String]);
////        NSLog(@"the base10 string of fgint %@",[fGInt toBase10String]);
////    }
//    for( id fGIntBase in [fGInt number] ) {
//        numberBase = [number objectAtIndex: i];
//        tmpMod = (FGIntOverflow) (4294967296u | [numberBase digit]) - [fGIntBase digit] - mod;
//        if (tmpMod > 4294967295u) mod = 0; else mod = 1;
//        [numberBase setDigit: tmpMod];
//        ++i;
//    }
//    for( i = length2; i < length1; ++i ) {
//        numberBase = [number objectAtIndex: i];
//        tmpMod = (FGIntOverflow) (4294967296u | [numberBase digit]) - mod;
//        if (tmpMod > 4294967295u) mod = 0; else mod = 1;
//        [numberBase setDigit: tmpMod];
//    }
//    while ((length1 > 1) && ([[number lastObject] digit] == 0)) {
//        --length1;
//        [number removeLastObject];
//    }
//    [self setLength: length1];
//}


/* replaces self with self + fGInt */

-(void) addWith: (FGInt *) fGInt {
    FGIntOverflow length1 = [self length], length2 = [fGInt length], mod = 0, tmpMod, i = 0, minLength = MIN(length1, length2);
    FGIntNumberBase *tfginb;
    NSMutableArray *fGIntNumber = [fGInt number];
    
    for( i = 0; i < minLength; ++i ) {
        tfginb = [number objectAtIndex: i];
        tmpMod = (FGIntOverflow) [tfginb digit] + [[fGIntNumber objectAtIndex: i] digit] + mod;
        [tfginb setDigit: tmpMod];
        mod = tmpMod >> 32;
    }
    for( i = minLength; i < length1; ++i ) {
        if (mod == 0)
            break;
        tfginb = [number objectAtIndex: i];
        tmpMod = (FGIntOverflow) [tfginb digit] + mod;
        mod = tmpMod >> 32;
        [tfginb setDigit: tmpMod];
    }
    for( i = minLength; i < length2; ++i ) {
        tmpMod = (FGIntOverflow) [[fGIntNumber objectAtIndex: i] digit] + mod;
        mod = tmpMod >> 32;
        tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: tmpMod];
        [number addObject: tfginb];
        [tfginb release];
    }
    
    if (mod != 0) {
        [self setLength: MAX(length1, length2) + 1];
        if ([number count] != MAX(length1, length2) + 1) {
            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: (FGIntBase) mod];
            [number addObject: tfginb];
            [tfginb release];
        }
        else
            [[number objectAtIndex: MAX(length1, length2)] setDigit: (FGIntBase) mod];
    } else
        [self setLength: MAX(length1, length2)];
}

//-(void) addWith1: (FGInt *) fGInt {
//    FGIntOverflow length1 = [self length], length2 = [fGInt length], mod = 0, tmpMod, i = 0;
//    FGIntNumberBase *tfginb;
//    NSMutableArray *fGIntNumber = [fGInt number];
//    
//    for( id fGIntBase in number ) {
//        tmpMod = (FGIntOverflow) [fGIntBase digit] + ((i < length2) ? [[fGIntNumber objectAtIndex: i] digit] : 0) + mod;
//        [fGIntBase setDigit: tmpMod];
//        mod = tmpMod >> 32;
//        ++i;
//    }
//    for( i = length1; i < length2; ++i ) {
//        tmpMod = (FGIntOverflow) [[fGIntNumber objectAtIndex: i] digit] + mod;
//        mod = tmpMod >> 32;
//        tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: (FGIntBase) tmpMod];
//        [number addObject: tfginb];
//    }
//    
//    if (mod != 0) {
//        [self setLength: MAX(length1, length2) + 1];
//        if ([number count] != MAX(length1, length2) + 1) {
//            tfginb = [[FGIntNumberBase alloc] initWithFGIntBase: (FGIntBase) mod];
//            [number addObject: tfginb];
//        }
//        else
//            [[number objectAtIndex: MAX(length1, length2)] setDigit: (FGIntBase) mod];
//    } else
//        [self setLength: MAX(length1, length2)];
//}



-(void) makePositive {
    [self setSign: YES];
}


/* divide using the digital long division equivalent. fGInt / divisorFGInt = result */

+(NSDictionary *) longDivision: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    NSMutableDictionary *quotientAndRemainder = [[NSMutableDictionary alloc] init];
    
    FGInt *modFGInt, *resFGInt, *tmpFGInt;
    FGIntBase divInt;
    FGIntOverflow tmpInt, i, j, k, divisorLength = [divisorFGInt length], tmpFGIntHead1, tmpFGIntHead2, modFGIntLength;
    FGIntNumberBase *fGIntBase;
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        j = ([fGInt length] + 1 > divisorLength) ? ([fGInt length] - divisorLength + 1) : 0;
        resFGInt = [[FGInt alloc] initWithNZeroes: j];
        tmpFGInt = [divisorFGInt copy];
        modFGInt = [fGInt copy];
            
        NSMutableArray *tmpFGIntNumber = [tmpFGInt number], *modFGIntNumber = [modFGInt number], *resFGIntNumber = [resFGInt number];

        if (j > 0) 
            [tmpFGInt shiftLeftBy32Times: j - 1];
        tmpFGIntHead1 = ((FGIntOverflow) [[tmpFGIntNumber lastObject] digit] + 1);
        if ([tmpFGInt length] > 1) {
            tmpFGIntHead2 = (((FGIntOverflow) [[tmpFGIntNumber lastObject] digit] << 32) + 
                                      [[tmpFGIntNumber objectAtIndex: [tmpFGInt length] - 2] digit] + 1);
        } else {
            tmpFGIntHead2 = 0;
        }

        modFGIntLength = [modFGInt length];
        while ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] != smaller) {
            while ([FGInt compareAbsoluteValueOf: modFGInt with: tmpFGInt] != smaller) {
                if (modFGIntLength > [tmpFGInt length]) {
                    divInt = (FGIntOverflow) (((FGIntOverflow) [[modFGIntNumber lastObject] digit] << 32) +
                                              [[modFGIntNumber objectAtIndex: [modFGInt length] - 2] digit]) /
                             tmpFGIntHead1;
                } else {
                    if ((modFGIntLength > 1) && (tmpFGIntHead2 != 0)) {
                       divInt = (((FGIntOverflow) [[modFGIntNumber lastObject] digit] << 32) +
                              [[modFGIntNumber objectAtIndex: [modFGInt length] - 2] digit]) / tmpFGIntHead2;
                    } else {
                        divInt = (FGIntOverflow) ([[modFGIntNumber lastObject] digit]) /
                                 tmpFGIntHead1;
                    }
                }
                if (divInt != 0) {
                    [modFGInt subtractWith: tmpFGInt multipliedByInt: divInt];
                    fGIntBase = [resFGIntNumber objectAtIndex: j - 1];
                    [fGIntBase setDigit: [fGIntBase digit] + divInt];
                } else {
                    [modFGInt subtractWith: tmpFGInt];
                    fGIntBase = [resFGIntNumber objectAtIndex: j - 1];
                    [fGIntBase setDigit: [fGIntBase digit] + 1];
                }
                modFGIntLength = [modFGInt length];
            }
            if (([modFGInt length] <= [tmpFGInt length]) &&
                ([tmpFGInt length] > divisorLength)) {
                [tmpFGInt shiftRightBy32];
                --j;
            }
        }
        [tmpFGInt release];
    } else {
        if ([fGInt sign]) {
            resFGInt = [[FGInt alloc] initWithFGIntBase: 0];
            modFGInt = [fGInt copy];
        } else {
            resFGInt = [[FGInt alloc] initWithFGIntBase: 1];
            if ([divisorFGInt sign])
                [resFGInt setSign: NO];
            modFGInt = [divisorFGInt copy];
            [modFGInt makePositive];
            [modFGInt subtractWith: fGInt];
        }
        [quotientAndRemainder setObject: resFGInt forKey: quotientKey];
        [quotientAndRemainder setObject: modFGInt forKey: remainderKey];
        [resFGInt release];
        [modFGInt release];

        return quotientAndRemainder;
    }
    while (([resFGInt length] > 1) && ([[[resFGInt number] lastObject] digit] == 0)) {
        [resFGInt setLength: [resFGInt length] - 1];
        [[resFGInt number] removeLastObject];
    }

    [resFGInt setSign: [fGInt sign] == [divisorFGInt sign]];
    if ((![fGInt sign]) && (!(([modFGInt length] == 1) && ([[[modFGInt number] objectAtIndex: 0] digit] == 0)))) {
        FGInt *one = [[FGInt alloc] initWithFGIntBase: 1];
        [resFGInt addWith: one];
        tmpFGInt = [divisorFGInt copy];
        [tmpFGInt subtractWith: modFGInt];
        [modFGInt release];
        modFGInt = tmpFGInt;
        [modFGInt setSign: YES];
        [one release];
    }
    
    [quotientAndRemainder setObject:resFGInt forKey:quotientKey];
    [quotientAndRemainder setObject:modFGInt forKey:remainderKey];
    [resFGInt release];
    [modFGInt release];

    return quotientAndRemainder;
}



/* compute the initial bits for newton inversion with kZero fraction digits */

+(FGInt *) newtonInitialValue: (FGInt *) fGInt precision: (FGIntBase) kZero {
    FGInt *resFGInt, *tmpFGInt, *bFGInt;
    FGIntBase divInt;
    FGIntOverflow tmpInt, i, j, k, l, isTwo = 0, divisorLength = [fGInt length], 
                    tmpFGIntHead1, tmpFGIntHead2, bFGIntLength;
    
    k = divisorLength;
    for ( id fGIntBase in [fGInt number] ) {
        if ([fGIntBase digit] != 0 ) {
            for ( l = 0; l <= 31; ++l ) {
                if (([fGIntBase digit] & (1 << l)) != 0)
                    ++isTwo;
            }
        }
    }

    if (isTwo != 1) {
        j = (FGIntOverflow) ceil( (double) kZero / 32 );
        k = divisorLength + j;
        
        bFGInt = [[FGInt alloc] initWithNZeroes: k];
        FGIntNumberBase *fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: 1];
        [[bFGInt number] addObject: fGIntBase];
        [fGIntBase release];
        [bFGInt setLength: k + 1];

        j = ([bFGInt length] + 1 > divisorLength) ? ([bFGInt length] - divisorLength + 1) : 0;
            
        tmpFGInt = [fGInt copy];
    
        if (j > 0) 
            [tmpFGInt shiftLeftBy32Times: j - 1];

        resFGInt = [[FGInt alloc] initWithNZeroes: j];

        NSMutableArray *resFGIntNumber = [resFGInt number], *bFGIntNumber = [bFGInt number], *tmpFGIntNumber = [tmpFGInt number];
        tmpFGIntHead1 = ((FGIntOverflow) [[tmpFGIntNumber lastObject] digit] + 1);
        if ([tmpFGInt length] > 1) {
            tmpFGIntHead2 = (((FGIntOverflow) [[tmpFGIntNumber lastObject] digit] << 32) + 
                                      [[tmpFGIntNumber objectAtIndex: [tmpFGInt length] - 2] digit] + 1);
        } else {
            tmpFGIntHead2 = 0;
        }
        
        bFGIntLength = [bFGInt length];
        while ([FGInt compareAbsoluteValueOf: bFGInt with: fGInt] != smaller) {
            while ([FGInt compareAbsoluteValueOf: bFGInt with: tmpFGInt] != smaller) {
                if (bFGIntLength > [tmpFGInt length]) {
                    divInt = (FGIntOverflow) (((FGIntOverflow) [[bFGIntNumber lastObject] digit] << 32) +
                                              [[bFGIntNumber objectAtIndex: [bFGInt length] - 2] digit]) /
                             tmpFGIntHead1;
                } else {
                    if ((bFGIntLength > 1) && (tmpFGIntHead2 != 0)) {
                       divInt = (((FGIntOverflow) [[bFGIntNumber lastObject] digit] << 32) +
                              [[bFGIntNumber objectAtIndex: [bFGInt length] - 2] digit]) / tmpFGIntHead2;
                    } else {
                        divInt = (FGIntOverflow) ([[bFGIntNumber lastObject] digit]) /
                                 tmpFGIntHead1;
                    }
                }
                if (divInt != 0) {
                    [bFGInt subtractWith: tmpFGInt multipliedByInt: divInt];
                    fGIntBase = [resFGIntNumber objectAtIndex: j - 1];
                    [fGIntBase setDigit: [fGIntBase digit] + divInt];
                } else {
                    [bFGInt subtractWith: tmpFGInt];
                    fGIntBase = [resFGIntNumber objectAtIndex: j - 1];
                    [fGIntBase setDigit: [fGIntBase digit] + 1];
                }
                bFGIntLength = [bFGInt length];
            }
            if ((bFGIntLength <= [tmpFGInt length]) && ([tmpFGInt length] > divisorLength)) {
                [tmpFGInt shiftRightBy32];
                --j;
            }
        }
    
        while (([resFGInt length] > 1) && ([[[resFGInt number] lastObject] digit] == 0)) {
            [resFGInt setLength: [resFGInt length] - 1];
            [resFGIntNumber removeLastObject];
        }
    
        j = kZero + 1; 

        i = 32 * ([resFGInt length] - 1);
        while (([[resFGIntNumber lastObject] digit] >> i) != 0)
            ++i;

        if (i > j) 
            [resFGInt shiftRightBy: i - j];
        else 
            [resFGInt shiftLeftBy: j - i];

        [bFGInt release];
        [tmpFGInt release];
    } else {
        resFGInt = [[FGInt alloc] initWithFGIntBase: 2];
        [resFGInt shiftLeftBy: kZero];
    }

    return resFGInt;
}


/*  newtonInversion returns the 1/fGInt with precision fraction digits */

+(FGInt *) newtonInversion: (FGInt *) fGInt withPrecision: (FGIntOverflow) precision {
    FGInt *z, *zSquare, *vFGInt, *tFGInt, *uFGInt;
    FGIntOverflow h, i, j, k = precision, baseCaseLength = 128, vLength, uRadix,
              vRadix, zRadix, zSquareRadix, tRadix, sRadix, vIndex, correction = 0;
    NSMutableArray *kValues = [[NSMutableArray alloc] init];      

    vFGInt = [fGInt copy];
    vLength = [vFGInt length];
    while ([[[vFGInt number] lastObject] digit] < 2147483648)
        [vFGInt shiftLeft];


    FGIntNumberBase *fGIntBase;
    while (k > baseCaseLength) {
        k = (FGIntOverflow) ceil( (double) k / 2);
        fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: k];
        [kValues insertObject: fGIntBase atIndex: 0];
        [fGIntBase release];
    }
    z = [FGInt newtonInitialValue: vFGInt precision: k];
    zRadix = k;
    tFGInt = [[FGInt alloc] init];
    vIndex = 0;
    tRadix = 0;
    
    NSMutableArray *tFGIntNumber = [tFGInt number], *vFGIntNumber = [vFGInt number];
    fGIntBase = [[FGIntNumberBase alloc] initWithFGIntBase: 0];

    for ( i = 0; i < [kValues count]; ++i ) {
        k = [[kValues objectAtIndex: i] digit];
        zSquare = [FGInt square: z];
        zSquareRadix = zRadix * 2;

        while (tRadix < 2*k + 3) {
            if (vLength > vIndex) {
                [tFGIntNumber insertObject: [vFGIntNumber objectAtIndex: vLength - 1 - vIndex] atIndex: 0];
            } else {
                [tFGIntNumber insertObject: fGIntBase atIndex: 0];
            }
            ++vIndex;
            tRadix += 32;
        }
        [tFGInt setLength: tRadix / 32];
        h = tRadix - 2*k - 3;
        uFGInt = [FGInt multiply: tFGInt and: zSquare];
        [zSquare release];
        uRadix = tRadix + zSquareRadix;
        if (uRadix > 2*k + 1 + h) {
            [uFGInt shiftRightBy: uRadix - (2*k + 1 + h)];
            uRadix = 2*k + 1 + h;
        }
        [z shiftLeft];

        if (uRadix > zRadix) {
            [z shiftLeftBy: uRadix - zRadix];
            zRadix = uRadix;
        }
        [z subtractWith: uFGInt];
        [uFGInt release];
    }
    [fGIntBase release];

    if (zRadix > precision) 
        [z shiftRightBy: zRadix - precision];
    [z setSign: YES];

    [kValues release];
    [tFGInt release];
    [vFGInt release];
    return z;    
}



+(NSDictionary *) barrettDivision: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    NSMutableDictionary *quotientAndRemainder = [[NSMutableDictionary alloc] init];
    FGInt *modFGInt = [[FGInt alloc] init], *resFGInt = [[FGInt alloc] init], *tmpFGInt = [[FGInt alloc] init], 
          *fGIntCopy, *divisorCopy;
    FGIntOverflow tmpInt, i, j, k, m = ([fGInt length] - 1) * 32, n = ([divisorFGInt length] - 1) * 32;
    BOOL mnCorrect = NO, fGIntSign = [fGInt sign], divisorSign = [divisorFGInt sign];
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        FGInt *invertedDivisor, *one;
        [fGInt setSign: YES];
        [divisorFGInt setSign: YES];    
            
        NSMutableArray *fGIntNumber = [fGInt number], *divisorFGIntNumber = [divisorFGInt number];
                
        for ( i = 0; i < 32; ++i ) {
            if (([[fGIntNumber lastObject] digit] >> i) == 0) 
                break;
            ++m;
        }
        for ( i = 0; i < 32; ++i ) {
            if (([[divisorFGIntNumber lastObject] digit] >> i) == 0) 
                break;
            ++n;
        }
        
        if (m > 2*n) {
            fGIntCopy = [fGInt copy];
            divisorCopy = [divisorFGInt copy];
            mnCorrect = YES;
        }
        
        while (m > 2*n) {
            if (m >= 2*n + 32) {
                [fGInt shiftLeftBy32];
                [divisorFGInt shiftLeftBy32];
                m += 32;
                n += 32;
            } else {
                [fGInt shiftLeft];
                [divisorFGInt shiftLeft];
                ++m;
                ++n;
            }
        }

        invertedDivisor = [FGInt newtonInversion: divisorFGInt withPrecision: m - n];

        tmpFGInt = [fGInt copy];
        i = n - 1;
        if (i > 0) 
            [tmpFGInt shiftRightBy: i];
        resFGInt = [FGInt multiply: tmpFGInt and: invertedDivisor];
        [tmpFGInt release];

        i = m - n + 1;
        if (i > 0) 
            [resFGInt shiftRightBy: i];
        
        tmpFGInt = [FGInt multiply: divisorFGInt and: resFGInt];
        modFGInt = [FGInt subtract: fGInt and: tmpFGInt];
        [tmpFGInt release];
        one = [[FGInt alloc] initWithFGIntBase: 1];
        
        while (!([modFGInt sign] && ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] == smaller))) {
            if (![modFGInt sign]) {
                tmpFGInt = [FGInt add: modFGInt and: divisorFGInt];
                [modFGInt release];
                modFGInt = tmpFGInt;
                [resFGInt subtractWith: one];
            } else {
                [modFGInt subtractWith: divisorFGInt];
                [resFGInt addWith: one];
            }
        }
        if (!fGIntSign) {
                modFGInt = [FGInt subtract: divisorFGInt and: modFGInt];
                [resFGInt addWith: one];
        }
        [resFGInt setSign: fGIntSign == divisorSign];

        if (mnCorrect) {
            [fGInt setNumber: [fGIntCopy number]];
            [fGInt setLength: [fGIntCopy length]];
            [divisorFGInt setNumber: [divisorCopy number]];
            [divisorFGInt setLength: [divisorCopy length]];
        }
        
        [fGInt setSign: fGIntSign];
        [divisorFGInt setSign: divisorSign];

        [invertedDivisor release];
        [one release];
        
        [quotientAndRemainder setObject:resFGInt forKey:quotientKey];
        [quotientAndRemainder setObject:modFGInt forKey:remainderKey];
        [resFGInt release];
        [modFGInt release];

        return quotientAndRemainder;
    } else {
        if ([fGInt sign]) {
            resFGInt = [[FGInt alloc] initWithFGIntBase: 0];
            modFGInt = [fGInt copy];
        } else {
            if ([divisorFGInt sign])
                resFGInt = [[FGInt alloc] initWithBase10String: @"-1"];
            else
                resFGInt = [[FGInt alloc] initWithFGIntBase: 1];
            modFGInt = [divisorFGInt copy];
            [modFGInt makePositive];
            [modFGInt subtractWith: fGInt];
        }
        [quotientAndRemainder setObject:resFGInt forKey:quotientKey];
        [quotientAndRemainder setObject:modFGInt forKey:remainderKey];
        [resFGInt release];
        [modFGInt release];

        return quotientAndRemainder;
    }
}

+(FGInt *) barrettMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    FGInt *modFGInt, *resFGInt, *tmpFGInt, *fGIntCopy, *divisorCopy;
    FGIntOverflow tmpInt, i, j, k, m = ([fGInt length] - 1) * 32, n = ([divisorFGInt length] - 1) * 32;
    BOOL mnCorrect = NO, fGIntSign = [fGInt sign], divisorSign = [divisorFGInt sign];
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        FGInt *invertedDivisor = [[FGInt alloc] init], *one;
        [fGInt setSign: YES];
        [divisorFGInt setSign: YES];    
            
        NSMutableArray *fGIntNumber = [fGInt number], *divisorFGIntNumber = [divisorFGInt number];
                
        for ( i = 0; i < 32; ++i ) {
            if (([[fGIntNumber lastObject] digit] >> i) == 0) 
                break;
            ++m;
        }
        for ( i = 0; i < 32; ++i ) {
            if (([[divisorFGIntNumber lastObject] digit] >> i) == 0) 
                break;
            ++n;
        }
        
        if (m > 2*n) {
            fGIntCopy = [fGInt copy];
            divisorCopy = [divisorFGInt copy];
            mnCorrect = YES;
        }
        
        while (m > 2*n) {
            if (m >= 2*n + 32) {
                [fGInt shiftLeftBy32];
                [divisorFGInt shiftLeftBy32];
                m += 32;
                n += 32;
            } else {
                [fGInt shiftLeft];
                [divisorFGInt shiftLeft];
                ++m;
                ++n;
            }
        }

        invertedDivisor = [FGInt newtonInversion: divisorFGInt withPrecision: m - n];

        tmpFGInt = [fGInt copy];
        i = n - 1;
        if (i > 0) 
            [tmpFGInt shiftRightBy: i];
        resFGInt = [FGInt multiply: tmpFGInt and: invertedDivisor];
        [tmpFGInt release];

        i = m - n + 1;
        if (i > 0) 
            [resFGInt shiftRightBy: i];
        
        tmpFGInt = [FGInt multiply: divisorFGInt and: resFGInt];
        modFGInt = [FGInt subtract: fGInt and: tmpFGInt];
        [tmpFGInt release];
        one = [[FGInt alloc] initWithFGIntBase: 1];
        
        while (!([modFGInt sign] && ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] == smaller))) {
            if (![modFGInt sign]) {
                tmpFGInt = [FGInt add: modFGInt and: divisorFGInt];
                [modFGInt release];
                modFGInt = tmpFGInt;
            } else {
                [modFGInt subtractWith: divisorFGInt];
            }
        }
        if (!fGIntSign) {
            tmpFGInt = [FGInt subtract: divisorFGInt and: modFGInt];
            [modFGInt release];
            modFGInt = tmpFGInt;
        }

        if (mnCorrect) {
            [fGInt setNumber: [fGIntCopy number]];
            [fGInt setLength: [fGIntCopy length]];
            [divisorFGInt setNumber: [divisorCopy number]];
            [divisorFGInt setLength: [divisorCopy length]];
        }
        
        [fGInt setSign: fGIntSign];
        [divisorFGInt setSign: divisorSign];
        
        [invertedDivisor release];
        
        return modFGInt;
    } else {
        if ([fGInt sign])
            return [fGInt copy];
        else {
            modFGInt = [divisorFGInt copy];
            [modFGInt makePositive];
            [modFGInt subtractWith: fGInt];
            return modFGInt;
        }
    }
}





-(void) subtractWith: (FGInt *) fGInt multipliedByInt: (FGIntBase) multInt {
    FGIntBase length1 = [self length], length2 = [fGInt length];
    FGIntOverflow mod = 0, tmpMod, i = 0, mMod = 0, mTmpMod;
    FGIntNumberBase *numberBase;

//    if (length2 > length1) {
//        NSLog(@"Oh-oh, length1 = %u, and length2 is %u and count is %lu",length1, length2, [[fGInt number] count]);
//        NSLog(@"the base10 string of  self %@",[self toBase10String]);
//        NSLog(@"the base10 string of fgint %@",[fGInt toBase10String]);
//    }
    for( id fGIntBase in [fGInt number] ) {
        mTmpMod = (FGIntOverflow) [fGIntBase digit] * multInt + mMod;
        mMod = mTmpMod >> 32;
        numberBase = [number objectAtIndex: i];
        tmpMod = (FGIntOverflow) (4294967296u | [numberBase digit]) - (mTmpMod & 4294967295u) - mod;
        mod = (tmpMod > 4294967295u) ?  0 : 1;
        [numberBase setDigit: tmpMod];
        ++i;
    }
    for( i = length2; i < length1; ++i ) {
        if ((mod == 0) && (mMod == 0))
            break;
        numberBase = [number objectAtIndex: i];
        tmpMod = (FGIntOverflow) (4294967296u | [numberBase digit]) - mMod - mod;
        mMod >>= 32;
        mod = (tmpMod > 4294967295u) ?  0 : 1;
        [numberBase setDigit: tmpMod];
    }
    while ((length1 > 1) && ([[number lastObject] digit] == 0)) {
        --length1;
        [number removeLastObject];
    }
    [self setLength: length1];
}


-(void) subtractWith1: (FGInt *) fGInt multipliedByInt: (FGIntBase) multInt {
    FGIntBase length1 = [self length], length2 = [fGInt length];
    FGIntOverflow mod = 0, tmpMod, i = 0, mMod = 0, mTmpMod;
    FGIntNumberBase *numberBase;
    NSMutableArray *fGIntNumber = [fGInt number];
//    if (length2 > length1) {
//        NSLog(@"Oh-oh, length1 = %u, and length2 is %u and count is %lu",length1, length2, [[fGInt number] count]);
//        NSLog(@"the base10 string of  self %@",[self toBase10String]);
//        NSLog(@"the base10 string of fgint %@",[fGInt toBase10String]);
//    }

//    for( id fGIntBase in [fGInt number] ) {
    for( i = 0; i < length2; ++i ) {
        mTmpMod = (FGIntOverflow) [[fGIntNumber objectAtIndex: i] digit] * multInt + mMod;
        mMod = mTmpMod >> 32;
        numberBase = [number objectAtIndex: i];
        tmpMod = (FGIntOverflow) (4294967296u | [numberBase digit]) - (mTmpMod & 4294967295u) - mod;
        mod = (tmpMod > 4294967295u) ?  0 : 1;
        [numberBase setDigit: tmpMod];
//        ++i;
    }
    for( i = length2; i < length1; ++i ) {
        if ((mod == 0) && (mMod == 0))
            break;
        numberBase = [number objectAtIndex: i];
        tmpMod = (FGIntOverflow) (4294967296u | [numberBase digit]) - mMod - mod;
        mMod >>= 32;
        mod = (tmpMod > 4294967295u) ?  0 : 1;
        [numberBase setDigit: tmpMod];
    }
    while ((length1 > 1) && ([[number lastObject] digit] == 0)) {
        --length1;
        [number removeLastObject];
    }
    [self setLength: length1];
}



+(FGInt *) longDivisionMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    FGInt *modFGInt, *tmpFGInt;
    FGIntBase divInt;
    FGIntOverflow tmpInt, i, j, k, divisorLength = [divisorFGInt length], tmpFGIntHead1, tmpFGIntHead2, modFGIntLength;

    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        j = ([fGInt length] + 1 > divisorLength) ? ([fGInt length] - divisorLength + 1) : 0;
        tmpFGInt = [divisorFGInt copy];
        modFGInt = [fGInt copy];
            
        if (j > 0) 
            [tmpFGInt shiftLeftBy32Times: j - 1];

        NSMutableArray *tmpFGIntNumber = [tmpFGInt number], *modFGIntNumber = [modFGInt number];
        tmpFGIntHead1 = ((FGIntOverflow) [[tmpFGIntNumber lastObject] digit] + 1);
        if ([tmpFGInt length] > 1) {
            tmpFGIntHead2 = (((FGIntOverflow) [[tmpFGIntNumber lastObject] digit] << 32) + 
                                      [[tmpFGIntNumber objectAtIndex: [tmpFGInt length] - 2] digit] + 1);
        } else {
            tmpFGIntHead2 = 0;
        }
        
        modFGIntLength = [modFGInt length];
        while ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] != smaller) {
            while ([FGInt compareAbsoluteValueOf: modFGInt with: tmpFGInt] != smaller) {
                if ([modFGInt length] > [tmpFGInt length]) {
                    divInt = (FGIntOverflow) (((FGIntOverflow) [[modFGIntNumber lastObject] digit] << 32) +
                                              [[modFGIntNumber objectAtIndex: [modFGInt length] - 2] digit]) /
                             tmpFGIntHead1;
                } else {
                    if ((modFGIntLength > 1) && (tmpFGIntHead2 != 0)) {
                       divInt = (((FGIntOverflow) [[modFGIntNumber lastObject] digit] << 32) +
                              [[modFGIntNumber objectAtIndex: [modFGInt length] - 2] digit]) / tmpFGIntHead2;
                    } else {
                        divInt = (FGIntOverflow) ([[modFGIntNumber lastObject] digit]) /
                                 tmpFGIntHead1;
                    }
                }
                if (divInt != 0) {
                    [modFGInt subtractWith: tmpFGInt multipliedByInt: divInt];
                } else {
                    [modFGInt subtractWith: tmpFGInt];
                }
                modFGIntLength = [modFGInt length];
            }
            if (([modFGInt length] <= [tmpFGInt length]) &&
                ([tmpFGInt length] > divisorLength)) {
                [tmpFGInt shiftRightBy32];
            }
        }
        [tmpFGInt release];
    } 
    else {
        modFGInt = [fGInt copy];
    }
    if ((![fGInt sign]) && (!(([modFGInt length] == 1) && ([[[modFGInt number] objectAtIndex: 0] digit] == 0)))) {
        tmpFGInt = [divisorFGInt copy];
        [tmpFGInt subtractWith: modFGInt];
        [modFGInt release];
        modFGInt = tmpFGInt;
        [modFGInt setSign: YES];
    }
    return modFGInt;
}


+(FGInt *) longDivisionModBis: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    FGInt *modFGInt, *tmpFGInt;
    FGIntBase divInt;
    FGIntOverflow tmpInt, i, j, k, divisorLength = [divisorFGInt length], modFGIntLength, tmpFGIntHead1, tmpFGIntHead2;

    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {
        j = ([fGInt length] + 1 > divisorLength) ? ([fGInt length] - divisorLength + 1) : 0;
        tmpFGInt = [divisorFGInt copy];
        modFGInt = fGInt;
            
        if (j > 0) 
            [tmpFGInt shiftLeftBy32Times: j - 1];

        NSMutableArray *tmpFGIntNumber = [tmpFGInt number], *modFGIntNumber = [modFGInt number];
        tmpFGIntHead1 = ((FGIntOverflow) [[tmpFGIntNumber lastObject] digit] + 1);
        if ([tmpFGInt length] > 1) {
            tmpFGIntHead2 = (((FGIntOverflow) [[tmpFGIntNumber lastObject] digit] << 32) + 
                                      [[tmpFGIntNumber objectAtIndex: [tmpFGInt length] - 2] digit] + 1);
        } else {
            tmpFGIntHead2 = 0;
        }
        
        while ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] != smaller) {
            modFGIntLength = [modFGInt length];
            while ([FGInt compareAbsoluteValueOf: modFGInt with: tmpFGInt] != smaller) {
                if (modFGIntLength > [tmpFGInt length]) {
                    divInt = (FGIntOverflow) (((FGIntOverflow) [[modFGIntNumber lastObject] digit] << 32) +
                                              [[modFGIntNumber objectAtIndex: modFGIntLength - 2] digit]) /
                             tmpFGIntHead1;
                } else {
                    if ((modFGIntLength > 1) && (tmpFGIntHead2 != 0)) {
                       divInt = (((FGIntOverflow) [[modFGIntNumber lastObject] digit] << 32) +
                              [[modFGIntNumber objectAtIndex: [modFGInt length] - 2] digit]) / tmpFGIntHead2;
                    } else {
                        divInt = (FGIntOverflow) ([[modFGIntNumber lastObject] digit]) /
                                 tmpFGIntHead1;
                    }
                }
                if (divInt != 0) {
                    [modFGInt subtractWith: tmpFGInt multipliedByInt: divInt];
                } else {
                    [modFGInt subtractWith: tmpFGInt];
                }
                modFGIntLength = [modFGInt length];
            }
            if ((modFGIntLength <= [tmpFGInt length]) &&
                ([tmpFGInt length] > divisorLength)) {
                [tmpFGInt shiftRightBy32];
            }
        }
        [tmpFGInt release];
    } else {
        if ([fGInt sign])
            return fGInt;
        else 
            modFGInt = fGInt;
    }
    if ((![fGInt sign]) && (!(([modFGInt length] == 1) && ([[[modFGInt number] objectAtIndex: 0] digit] == 0)))) {
        tmpFGInt = [divisorFGInt copy];
        [tmpFGInt subtractWith: modFGInt];
        [modFGInt release];
        modFGInt = tmpFGInt;
        [modFGInt setSign: YES];
    }
    return modFGInt;
}




/*  barrettMod expects fGInt to contain not more than double the amount of significant bits of divisorFGInt,
    invertedDivisor has double the amount of significant bits of divisorFGInt as fraction bits.
    barrettMod expects all arguments to be positive.
*/


+(FGInt *) barrettMod: (FGInt *) fGInt by: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision {
    FGInt *modFGInt, *resFGInt, *tmpFGInt;
    FGIntOverflow i, j, k;
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {

        tmpFGInt = [[FGInt alloc] init];
        NSMutableArray *tmpFGIntNumber = [tmpFGInt number], *fGIntNumber = [fGInt number];
        FGIntNumberBase *fGIntBaseCopy;
        i = precision - 1;
        j = i / 32;
        k = 0;
        for ( id fGIntBase in fGIntNumber ) {
            ++k;
            if (k > j) {
                fGIntBaseCopy = [fGIntBase copy];
                [tmpFGIntNumber addObject: fGIntBaseCopy];
                [fGIntBaseCopy release];
            }
        }
        [tmpFGInt setLength: [tmpFGIntNumber count]];
        j = i % 32;
        if (j > 0) 
            [tmpFGInt shiftRightBy: j];
        resFGInt = [FGInt multiply: tmpFGInt and: invertedDivisor];
        [tmpFGInt release];
        i = precision + 1;
        if (i > 0) 
            [resFGInt shiftRightBy: i];
        
        tmpFGInt = [FGInt multiply: divisorFGInt and: resFGInt];
        [resFGInt release];
        modFGInt = [FGInt subtract: fGInt and: tmpFGInt];
        [tmpFGInt release];

        i = 0;
        while (!([modFGInt sign] && ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] == smaller))) {
            if (![modFGInt sign]) {
                tmpFGInt = [FGInt add: modFGInt and: divisorFGInt];
                [modFGInt release];
                modFGInt = tmpFGInt;
            } else {
                [modFGInt subtractWith: divisorFGInt];
            }
        }
        
        return modFGInt;
    } else 
        return [fGInt copy];
}


+(FGInt *) barrettModBis: (FGInt *) fGInt by: (FGInt *) divisorFGInt with: (FGInt *) invertedDivisor andPrecision: (FGIntOverflow) precision {
    FGInt *modFGInt, *resFGInt, *tmpFGInt;
    FGIntOverflow i, j, k;
    
    if ([FGInt compareAbsoluteValueOf: fGInt with: divisorFGInt] != smaller) {

        tmpFGInt = [[FGInt alloc] init];
        NSMutableArray *tmpFGIntNumber = [tmpFGInt number], *fGIntNumber = [fGInt number];
        FGIntNumberBase *fGIntBaseCopy;
        i = precision - 1;
        j = i / 32;
        k = 0;
        for ( id fGIntBase in fGIntNumber ) {
            ++k;
            if (k > j) {
                fGIntBaseCopy = [fGIntBase copy];
                [tmpFGIntNumber addObject: fGIntBaseCopy];
                [fGIntBaseCopy release];
            }
        }
        [tmpFGInt setLength: [tmpFGIntNumber count]];
        j = i % 32;
        if (j > 0) 
            [tmpFGInt shiftRightBy: j];
                
        resFGInt = [FGInt multiply: tmpFGInt and: invertedDivisor];
        [tmpFGInt release];
        i = precision + 1;
        if (i > 0) 
            [resFGInt shiftRightBy: i];
        
        modFGInt = [FGInt multiply: divisorFGInt and: resFGInt];
        [resFGInt release];
        if ([FGInt compareAbsoluteValueOf: modFGInt with: fGInt] == larger) {
            [modFGInt subtractWith: fGInt];
            [fGInt release];
            fGInt = modFGInt;
            [modFGInt setSign: NO];
        } else {
            [fGInt subtractWith: modFGInt];
            [modFGInt release];
            modFGInt = fGInt;
        }

        i = 0;
        while (!([modFGInt sign] && ([FGInt compareAbsoluteValueOf: modFGInt with: divisorFGInt] == smaller))) {
            if (![modFGInt sign]) {
                tmpFGInt = [FGInt add: modFGInt and: divisorFGInt];
                [modFGInt release];
                modFGInt = tmpFGInt;
                fGInt = modFGInt;
            } else {
                [modFGInt subtractWith: divisorFGInt];
            }
        }
        
        return modFGInt;
    } else 
        return fGInt;
}




/* raise fGInt to the power fGIntN mod modFGInt, and return (fGInt ^ fGIntN) % modFGInt */

+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN barrettMod: (FGInt *) modFGInt {
    FGInt *power = [[FGInt alloc] initWithFGIntBase: 1];
    FGIntOverflow nLength = [fGIntN length], i, j, precision = ([modFGInt length] - 1) * 32;
    FGIntBase tmp;
    FGInt *tmpFGInt1, *tmpFGInt;
    NSMutableArray *modFGIntNumber = [modFGInt number], *nFGIntNumber = [fGIntN number];
    
    for ( i = 0; i < 32; ++i ) {
        if (([[modFGIntNumber lastObject] digit] >> i) == 0) 
            break;
        ++precision;
    }

    FGInt *invertedDivisor = [FGInt newtonInversion: modFGInt withPrecision: precision];
    tmpFGInt1 = [fGInt retain];

    i = 1;
    for( id fGIntBase in nFGIntNumber ) {
        if (i >= nLength)
            break;
        tmp = [fGIntBase digit];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
                [power release];
                power = [FGInt barrettModBis: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//                power = [FGInt barrettMod: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//                [tmpFGInt release];
            }
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = [FGInt barrettModBis: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            tmpFGInt1 = [FGInt barrettMod: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            [tmpFGInt release];
            tmp >>= 1;
        }
        ++i;
    }
    tmp = [[nFGIntNumber lastObject] digit];
    while(tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
            [power release];
            power = [FGInt barrettModBis: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            power = [FGInt barrettMod: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            [tmpFGInt release];
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = [FGInt barrettModBis: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            tmpFGInt1 = [FGInt barrettMod: tmpFGInt by: modFGInt with: invertedDivisor andPrecision: precision];
//            [tmpFGInt release];
        }
    }

    [invertedDivisor release];
    [tmpFGInt1 release];

    return power;
}


+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN longDivisionMod: (FGInt *) modFGInt {
    FGInt *power = [[FGInt alloc] initWithFGIntBase: 1];
    FGIntOverflow nLength = [fGIntN length], i, j, precision = ([modFGInt length] - 1) * 32;
    FGIntBase tmp;
    FGInt *tmpFGInt1, *tmpFGInt;
    NSMutableArray *nFGIntNumber = [fGIntN number];

    tmpFGInt1 = [fGInt retain];

    i = 1;
    for( id fGIntBase in nFGIntNumber ) {
        if (i >= nLength)
            break;
        tmp = [fGIntBase digit];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
                [power release];
                power = [FGInt longDivisionModBis: tmpFGInt by: modFGInt];
//              power = [FGInt longDivisionMod: tmpFGInt by: modFGInt];
//              [tmpFGInt release];
            }
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = [FGInt longDivisionModBis: tmpFGInt by: modFGInt];
//            tmpFGInt1 = [FGInt longDivisionMod: tmpFGInt by: modFGInt];
//            [tmpFGInt release];
            tmp >>= 1;
        }
        ++i;
    }
    tmp = [[nFGIntNumber lastObject] digit];
    while(tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpFGInt = [FGInt multiply: power and: tmpFGInt1];
            [power release];
            power = [FGInt longDivisionModBis: tmpFGInt by: modFGInt];
//            power = [FGInt longDivisionMod: tmpFGInt by: modFGInt];
//            [tmpFGInt release];
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpFGInt = [FGInt square: tmpFGInt1];
            [tmpFGInt1 release];
            tmpFGInt1 = [FGInt longDivisionModBis: tmpFGInt by: modFGInt];
//            tmpFGInt1 = [FGInt longDivisionMod: tmpFGInt by: modFGInt];
//            [tmpFGInt release];
        }
    }
    
    [tmpFGInt1 release];
    
    return power;
}


+(FGInt *) mod: (FGInt *) fGInt by: (FGInt *) modFGInt {
    if (([fGInt length] > [modFGInt length]) && ([fGInt length] - [modFGInt length] > barrettThreshold))
        return [FGInt barrettMod: fGInt by: modFGInt];
    else
        return [FGInt longDivisionMod: fGInt by: modFGInt];
}


+(NSDictionary *) divide: (FGInt *) fGInt by: (FGInt *) divisorFGInt {
    if (([fGInt length] > [divisorFGInt length]) && ([fGInt length] - [divisorFGInt length] > barrettThreshold))
        return [FGInt barrettDivision: fGInt by: divisorFGInt];
    else
        return [FGInt longDivision: fGInt by: divisorFGInt];
}


/* compute the greatest common divisor of fGInt1 and fGInt2 */

+(FGInt *) gcd: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    if ( [FGInt compareAbsoluteValueOf: fGInt1 with: fGInt2] == equal) 
        return [fGInt1 copy];
        else {
            if ([FGInt compareAbsoluteValueOf: fGInt1 with: fGInt2] == smaller)
                return [FGInt gcd: fGInt2 and: fGInt1];
            else {
                FGInt *tmpFGInt1, *tmpFGInt2, *tmpFGInt3, *tmpFGInt, *zero = [[FGInt alloc] initWithFGIntBase: 0];
                tmpFGInt1 = [fGInt1 copy];
                tmpFGInt2 = [fGInt2 copy];
                while ([FGInt compareAbsoluteValueOf: tmpFGInt2 with: zero] != equal) {
                    tmpFGInt = tmpFGInt2;
                    tmpFGInt2 = [FGInt longDivisionModBis: tmpFGInt1 by: tmpFGInt2];
                    tmpFGInt1 = tmpFGInt;
                }
                [zero release];
                [tmpFGInt2 release];
                return tmpFGInt1;
            }
        }
}



/* compute the greatest common divisor of fGInt1 and fGInt2 */

+(FGInt *) lcm: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGInt *tmpFGInt1, *tmpFGInt2, *resFGInt;
    tmpFGInt1 = [FGInt multiply: fGInt1 and: fGInt2];
    tmpFGInt2 = [FGInt gcd: fGInt1 and: fGInt2];
    NSDictionary *divMod = [FGInt divide: tmpFGInt1 by: tmpFGInt2];
    resFGInt = [[divMod objectForKey: quotientKey] retain];
    [tmpFGInt1 release];
    [tmpFGInt2 release];
    [divMod release];
    return resFGInt;
}



/* returns the modular inverse of fGInt mod modFGInt*/

+(FGInt *) modularInverse: (FGInt *) fGInt mod: (FGInt *) modFGInt {
    FGInt *r1, *r2, *r3, *zero, *one, *tmpB, *tmpFGInt, *tmpFGInt1, 
            *tmpFGInt2, *inverse, *gcd;
    NSDictionary *tmpDivMod;


    one = [[FGInt alloc] initWithFGIntBase: 1];
    gcd = [FGInt gcd: fGInt and: modFGInt];

    if ([FGInt compareAbsoluteValueOf: one with: gcd] == equal) {
        zero = [[FGInt alloc] initWithFGIntBase: 0];
        [gcd release];
        r2 = [fGInt copy];
        r1 = [modFGInt copy];
        inverse = [zero copy];
        tmpB = [one copy];
        do {
            tmpDivMod = [FGInt divide: r1 by: r2];
            [r1 release];
            r1 = r2;
            r2 = [tmpDivMod objectForKey: remainderKey];
            [r2 retain];
            tmpFGInt1 = [FGInt multiply: [tmpDivMod objectForKey: quotientKey] and: tmpB];
            [tmpDivMod release];
            tmpFGInt2 = [FGInt subtract: inverse and: tmpFGInt1];
            [tmpFGInt1 release];
            [inverse release];
            inverse = tmpB;
            tmpB = tmpFGInt2;
        } while ([FGInt compareAbsoluteValueOf: r2 with: zero] != equal);
        [r1 release];
        [r2 release];
        [tmpB release];
        if (![inverse sign]) {
            tmpFGInt = [FGInt add: inverse and: modFGInt];
            [inverse release];
            inverse = tmpFGInt;
        }
        [one release];
        [zero release];

        return inverse;
    }
    [gcd release];
    [one release];
    return zero;
}



+(FGInt *) mModBis: (FGInt *) fGInt withLength: (FGIntOverflow) bLength andHead: (FGIntBase) head {
    if (bLength <= [fGInt length]) {
        NSMutableArray *fGIntNumber = [fGInt number];
        FGIntOverflow i = 0;
        FGIntNumberBase *resBase;
        
        FGInt *resFGInt = [[FGInt alloc] init];
        NSMutableArray *resFGIntNumber = [resFGInt number];
        for ( id fGIntBase in fGIntNumber ) {
            [resFGIntNumber addObject: fGIntBase];
            ++i;
            if (i >= bLength - 1)
                break;
        }

        resBase = [[fGIntNumber objectAtIndex: bLength - 1] copy];
        [resBase setDigit: [resBase digit] & head];
        [resFGIntNumber addObject: resBase];
        [resBase release];
        [resFGInt setSign: YES];
        i = bLength;
        while ((i > 1) && ([[resFGIntNumber lastObject] digit]== 0)) {
            --i;
            [resFGIntNumber removeLastObject];
        }
        [resFGInt setLength: i];
        return resFGInt;
    } else {
        return [fGInt retain];
    }
}



+(FGInt *) mMultiplyMod: (FGInt *) fGInt1 and: (FGInt *) fGInt2 withLength: (FGIntOverflow) bLength andHead: (FGIntBase) head {
    FGIntOverflow length1 = [fGInt1 length], length2 = [fGInt2 length], resLength = MIN(bLength, length1 + length2), 
                    i, j, t, mod, tmpMod = 0;
    FGInt *product = [[FGInt alloc] initWithNZeroes: resLength];
    NSMutableArray *productNumber = [product number], *fGInt2Number = [fGInt2 number], *fGInt1Number = [fGInt1 number];
    FGIntNumberBase *productBase;
    FGIntBase fGIntBaseDigit;
    
    i = 0;
    for ( id fGInt2Base in fGInt2Number ) {
        mod = 0;
        t = MIN(length1, bLength - i);
        j = 0;
        fGIntBaseDigit = [fGInt2Base digit];
        for ( id fGInt1Base in fGInt1Number ) {
            productBase = [productNumber objectAtIndex: j + i];
            tmpMod = (FGIntOverflow) fGIntBaseDigit*[fGInt1Base digit] + [productBase digit] + mod;
            [productBase setDigit: tmpMod];
            mod = tmpMod >> 32;    
            ++j;
            if (j >= t)
                break;
        }
        if (i + length1 <= bLength - 1)
            [[productNumber objectAtIndex: i + length1] setDigit: mod];
        ++i;
    }
    if (resLength == bLength) {
        productBase = [productNumber objectAtIndex: bLength - 1];
        [productBase setDigit: [productBase digit] & head];
    }
    i = resLength;
    while ((i > 1) && ([[productNumber lastObject] digit] == 0)) {
        --i;
        [productNumber removeLastObject];
    }
    [product setLength: i];
    [product setSign: [fGInt1 sign] == [fGInt2 sign]];
    return product;
}


+(FGInt *) mMod: (FGInt *) fGInt withBase: (FGInt *) baseFGInt andInverseBase: (FGInt *) inverseBaseFGInt withLength: (FGIntOverflow) bLength andHead: (FGIntBase) head {
    FGInt *tmpFGInt, *tmpFGInt1, *mFGInt;
    FGIntBase tmp;
    FGIntOverflow i;
    NSMutableArray *mFGIntNumber;
    
    tmpFGInt = [FGInt mModBis: fGInt withLength: bLength andHead: head];
    tmpFGInt1 = [FGInt mMultiplyMod: tmpFGInt and: inverseBaseFGInt withLength: bLength andHead: head];
//    tmpFGInt1 = [FGInt mMultiplyModBis: fGInt and: inverseBaseFGInt withLength: bLength andHead: head];
    [tmpFGInt release];
    mFGInt = [FGInt multiply: tmpFGInt1 and: baseFGInt];
    [tmpFGInt1 release];
    if ([mFGInt sign] == [fGInt sign])
        [mFGInt addWith: fGInt];
    else {
        if ([FGInt compareAbsoluteValueOf: mFGInt with: fGInt] == larger)
            [mFGInt subtractWith: fGInt];
        else {
            tmpFGInt = mFGInt;
            mFGInt = [FGInt subtract: fGInt and: tmpFGInt];
            [tmpFGInt release];
        }
    }

    if (bLength > 1)
        [mFGInt shiftRightBy32Times: bLength - 1];
    [mFGInt setSign: YES];
    if (head < 2147483648) {
        mFGIntNumber = [mFGInt number];
        tmp = [FGInt divideFGIntNumberByIntBis: mFGIntNumber divideBy: head + 1];
        [mFGInt setLength: [mFGIntNumber count]];
    } else
        [mFGInt shiftRightBy32];
    if ([FGInt compareAbsoluteValueOf: mFGInt with: baseFGInt] != smaller)
        [mFGInt subtractWith: baseFGInt];
    return mFGInt;
}


+(FGInt *) montgomeryMod: (FGInt *) fGInt withBase: (FGInt *) baseFGInt andInverseBase: (FGInt *) inverseBaseFGInt withLength: (FGIntOverflow) bLength andHead: (FGIntBase) head {
    FGInt *tmpFGInt, *tmpFGInt1, *mFGInt;
    FGIntOverflow length1 = MIN([fGInt length], bLength), length2 = [inverseBaseFGInt length], resLength = MIN(bLength, length1 + length2), 
                    i, j, t, mod, tmpMod = 0, tmpInt;
    FGInt *product = [[FGInt alloc] initWithNZeroes: resLength];
    FGIntBase tmp, fGIntBaseDigit;
    NSMutableArray *mFGIntNumber, *fGIntNumber = [fGInt number], *inverseNumber = [inverseBaseFGInt number], *productNumber = [product number];
    FGIntNumberBase *productBase;
    
    i = 0;
    for ( id fGInt2Base in inverseNumber ) {
        mod = 0;
        t = MIN(length1, bLength - i);
        j = 0;
        fGIntBaseDigit = [fGInt2Base digit];
        if (i == 0)
            for ( id fGInt1Base in fGIntNumber ) {
                productBase = [productNumber objectAtIndex: j + i];
                if (j < bLength - 1) 
                    tmpMod = (FGIntOverflow) fGIntBaseDigit*[fGInt1Base digit] + [productBase digit] + mod;
                else // if (j == bLength - 1)
                    tmpMod = (FGIntOverflow) fGIntBaseDigit*([fGInt1Base digit] & head) + [productBase digit] + mod;
                [productBase setDigit: tmpMod];
                mod = tmpMod >> 32;    
                ++j;
                if (j >= t)
                    break;
            }
        else
            for ( id fGInt1Base in fGIntNumber ) {
                productBase = [productNumber objectAtIndex: j + i];
                tmpMod = (FGIntOverflow) fGIntBaseDigit*[fGInt1Base digit] + [productBase digit] + mod;
                [productBase setDigit: tmpMod];
                mod = tmpMod >> 32;    
                ++j;
                if (j >= t)
                    break;
            }
        if (i + length1 <= bLength - 1)
            [[productNumber objectAtIndex: i + length1] setDigit: mod];
        ++i;
    }
    if (resLength == bLength) {
//        productBase = [productNumber objectAtIndex: bLength - 1];
        productBase = [productNumber lastObject];
        [productBase setDigit: [productBase digit] & head];
    }
    i = resLength;
    while ((i > 1) && ([[productNumber lastObject] digit] == 0)) {
        --i;
        [productNumber removeLastObject];
    }
    [product setLength: i];

    mFGInt = [FGInt multiply: product and: baseFGInt];
    [product release];
    if ([mFGInt sign] == [fGInt sign])
        [mFGInt addWith: fGInt];
    else {
        if ([FGInt compareAbsoluteValueOf: mFGInt with: fGInt] == larger)
            [mFGInt subtractWith: fGInt];
        else {
            tmpFGInt = mFGInt;
            mFGInt = [FGInt subtract: fGInt and: tmpFGInt];
            [tmpFGInt release];
        }
    }

    mFGIntNumber = [mFGInt number];
    if (bLength > 1) {
        [mFGInt setLength: [mFGInt length] - bLength + 1];
        [mFGIntNumber removeObjectsInRange: NSMakeRange(0, bLength - 1)];
    }
//        [mFGInt shiftRightBy32Times: bLength - 1];
    [mFGInt setSign: YES];
    if (head < 2147483648) {
        tmp = [FGInt divideFGIntNumberByIntBis: mFGIntNumber divideBy: head + 1];
        [mFGInt setLength: [mFGIntNumber count]];
    } else
        [mFGInt shiftRightBy32];
    if ([FGInt compareAbsoluteValueOf: mFGInt with: baseFGInt] != smaller)
        [mFGInt subtractWith: baseFGInt];
    return mFGInt;
}


+(FGInt *) raise: (FGInt *) fGInt toThePower: (FGInt *) fGIntN montgomeryMod: (FGInt *) modFGInt {
    FGInt *tmpFGInt2, *tmpFGInt, *power, *rFGInt, *inverseBaseFGInt;
    FGIntOverflow bLength = [modFGInt length], i, nLength = [fGIntN length],
                    tmpLength = bLength + ((([[[modFGInt number] objectAtIndex: bLength - 1] digit] >> 31) == 0) ? 0 : 1);
    int j;
    FGIntBase head, tmp;
    NSMutableArray *rNumber, *modFGIntNumber = [modFGInt number], *nFGIntNumber = [fGIntN number];
    
    power = [FGInt mod: fGInt by: modFGInt];
    if (([power length] == 1) && ([[[power number] objectAtIndex: 0] digit] == 0))
        return power;
    [power release];
    
    rFGInt = [[FGInt alloc] initWithNZeroes: tmpLength];
    rNumber = [rFGInt number];
    FGIntNumberBase *fGIntBase = [rNumber lastObject];
    if (tmpLength == bLength) {
        head = 4294967295u;
        tmp = [[modFGIntNumber objectAtIndex: tmpLength - 1] digit];
        for ( j = 30; j >= 0; --j ) {
            head >>= 1;
            if ((tmp >> j) == 1) {
                [fGIntBase setDigit: 1 << (j + 1)];
                break;
            }
        }
    } else {
        [fGIntBase setDigit: 1];
        head = 4294967295u;
    }

//    tmpFGInt2 = [FGInt modularInverse: modFGInt mod: rFGInt];
    tmpFGInt2 = [FGInt leftShiftModularInverse: modFGInt mod: rFGInt];
    if (![tmpFGInt2 sign])
        inverseBaseFGInt = tmpFGInt2;
    else {
        inverseBaseFGInt = [rFGInt copy];
        [inverseBaseFGInt subtractWith: tmpFGInt2];
        [tmpFGInt2 release];
    }
    [inverseBaseFGInt makePositive];

    power = [FGInt mod: rFGInt by: modFGInt];
    tmpFGInt = [FGInt multiply: fGInt and: power];
    tmpFGInt2 = [FGInt mod: tmpFGInt by: modFGInt];
    [tmpFGInt release];
    
    i = 1;
    for( id fGIntBase in nFGIntNumber ) {
        if (i >= nLength)
            break;
        tmp = [fGIntBase digit];
        for( j = 0; j < 32; ++j ) {
            if ((tmp % 2) == 1) {
                tmpFGInt = [FGInt multiply: power and: tmpFGInt2];
                [power release];
//                power = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
                power = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
                [tmpFGInt release];
            }
            tmpFGInt = [FGInt square: tmpFGInt2];
            [tmpFGInt2 release];
//            tmpFGInt2 = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            tmpFGInt2 = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            [tmpFGInt release];
            tmp >>= 1;
    }
        ++i;
    }
    tmp = [[nFGIntNumber lastObject] digit];
    while(tmp != 0) {
        if ((tmp % 2) == 1) {
            tmpFGInt = [FGInt multiply: power and: tmpFGInt2];
            [power release];
//            power = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            power = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            [tmpFGInt release];
        }
        tmp >>= 1;
        if (tmp != 0) {
            tmpFGInt = [FGInt square: tmpFGInt2];
            [tmpFGInt2 release];
//            tmpFGInt2 = [FGInt mMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            tmpFGInt2 = [FGInt montgomeryMod: tmpFGInt withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
            [tmpFGInt release];
        }
    }
    power = [FGInt mMod: power withBase: modFGInt andInverseBase: inverseBaseFGInt withLength: bLength andHead: head];
    
    [tmpFGInt2 release];
    
    return power;
}

// work in progress, maybe 

+(FGInt *) leftShiftModularInverse: (FGInt *) fGInt mod: (FGInt *) modFGInt {
    FGIntOverflow cU = 0, cV = 0, modLength = [modFGInt length];
    FGInt *u = [modFGInt copy], *v = [fGInt copy],  *cU2 = [[FGInt alloc] initWithFGIntBase: 1], *cV2 = [cU2 copy], 
        *r = [[FGInt alloc] initWithFGIntBase: 0], *s = [cU2 copy], *tmpFGInt, *modBits = [[FGInt alloc] initWithNZeroes: modLength];
    FGIntBase modHead = (1 << 31), tmpInt = [[[modFGInt number] lastObject] digit];
//    NSMutableArray *uNumber = [u number], *vNumber = [v number];
    while (modHead > tmpInt)
        modHead >>= 1;
    [[[modBits number] lastObject] setDigit: modHead];
    
    while (([FGInt compareAbsoluteValueOf: u with: cU2] != equal) && ([FGInt compareAbsoluteValueOf: v with: cV2] != equal)) {
        if ([FGInt compareAbsoluteValueOf: modBits with: u] == larger) {
            if (cU >= cV) 
                [r shiftLeft];
            else
                [s shiftRight];
            [u shiftLeft];
            ++cU;
            [cU2 shiftLeft];
        } else if ([FGInt compareAbsoluteValueOf: modBits with: v] == larger) {
            if (cV >= cU) 
                [s shiftLeft];
            else
                [r shiftRight];
            [v shiftLeft];
            ++cV;
            [cV2 shiftLeft];
        } else {
            if ([u sign] == [v sign]) {
                if (cU <= cV) {
                    tmpFGInt = [FGInt subtract: u and: v];
                    [u release];
                    u = tmpFGInt;
                    tmpFGInt = [FGInt subtract: r and: s];
                    [r release];
                    r = tmpFGInt;
                } else {
                    tmpFGInt = [FGInt subtract: v and: u];
                    [v release];
                    v = tmpFGInt;
                    tmpFGInt = [FGInt subtract: s and: r];
                    [s release];
                    s = tmpFGInt;
                }
            } else {
                if (cU <= cV) {
                    tmpFGInt = [FGInt add: u and: v];
                    [u release];
                    u = tmpFGInt;
                    tmpFGInt = [FGInt add: r and: s];
                    [r release];
                    r = tmpFGInt;
                } else {
                    tmpFGInt = [FGInt add: v and: u];
                    [v release];
                    v = tmpFGInt;
                    tmpFGInt = [FGInt add: s and: r];
                    [s release];
                    s = tmpFGInt;
                }
            }
        }
    }
    if ([FGInt compareAbsoluteValueOf: v with: cV2] == equal) {
        [r release];
        r = s;
        [u release];
        u = v;
    } else {
        [s release];
        [v release];
    }
    if (![u sign]) {
        if (![r sign]) 
            [r makePositive];
        else {
            tmpFGInt = [FGInt subtract: modFGInt and: r];
            [r release];
            r = tmpFGInt;
        }
    } 
    if (![r sign]) {
        tmpFGInt = [FGInt add: modFGInt and: r];
        [r release];
        r = tmpFGInt;
    } 
    
    [u release];
//        NSLog(@" kitty %llu and %llu", cU, cV);
    [cU2 release];
    [cV2 release];
    [modBits release];
    return r;
}



/* divides the number by a 32 bit unsigned int (divInt) and returns the remainder, it does not alter fGIntNumber */

-(FGIntBase) modFGIntByInt: (FGIntBase) divInt {
    FGIntBase mod = 0;
    FGIntOverflow tempMod = 0;

    @autoreleasepool{
        for( id fGIntBase in [number reverseObjectEnumerator] ) {
            tempMod =  (((FGIntOverflow) mod << 32) | (FGIntOverflow) [fGIntBase digit]);
            mod = (FGIntOverflow) tempMod % divInt;
        }
    }
    
    return mod;
}

-(void) divideByInt: (FGIntBase) divInt {
    FGIntBase mod = 0;
    FGIntOverflow tempMod = 0;
    
    @autoreleasepool{
        for( id fGIntBase in [number reverseObjectEnumerator] ) {
            tempMod =  (((FGIntOverflow) mod << 32) | (FGIntOverflow) [fGIntBase digit]);
            [fGIntBase setDigit: (FGIntOverflow) (tempMod / divInt)];
            mod = (FGIntOverflow) tempMod % divInt;
        }
    }

    while ((length > 1) && ([[number lastObject] digit] == 0)) {
        [number removeLastObject];
        --length;
    }
//    [self setLength: length];
}

// Trialdivision of a FGInt upto 9999 and stopping when a divisor is found, returning ok=false

-(BOOL) trialDivision {
    if (([[number objectAtIndex: 0] digit] % 2) == 0) return NO;
    BOOL isPrime = YES;
    FGIntBase i = 0;
    while (isPrime && (i < 1228)) {
        isPrime = ([self modFGIntByInt: primes[i]] != 0);
        if ((!isPrime) && ([self length] == 1) && ([[number objectAtIndex: 0] digit] == primes[i])) {
            isPrime = YES;
            break;
        }
        ++i;
    }
    return isPrime;
}



/* Compute the coefficients from the Bezout-Bachet theorem, fGInt1 * aFGInt + fGInt2 * bFGInt = gcd(fGInt1, fGInt2) */

+(NSDictionary *) bezoutBachet: (FGInt *) fGInt1 and: (FGInt *) fGInt2 {
    FGInt *r1, *r2, *r3, *zero, *one, *tmpA, *aFGInt, *bFGInt, *tmpFGInt1, *tmpFGInt2 = [[FGInt alloc] init], *gcd;
    NSMutableDictionary *bezoutBachetCoefficients = [[NSMutableDictionary alloc] init];
    NSDictionary *tmpDivMod;
    
    one = [[FGInt alloc] initWithFGIntBase: 1];
    zero = [[FGInt alloc] initWithFGIntBase: 0];

    r1 = [fGInt1 copy];
    r2 = [fGInt2 copy];
    aFGInt = [zero copy];
    tmpA = [one copy];
    do {
        tmpDivMod = [FGInt divide: r1 by: r2];
        [r1 release];
        r1 = r2;
        r2 = [[tmpDivMod objectForKey: remainderKey] retain];
        tmpFGInt1 = [FGInt multiply: [tmpDivMod objectForKey: quotientKey] and: tmpA];
        [tmpDivMod release];
        tmpFGInt2 = [FGInt subtract: bFGInt and: tmpFGInt1];
        [tmpFGInt1 release];
        aFGInt = tmpA;
        tmpA = tmpFGInt2;
    } while ([FGInt compareAbsoluteValueOf: r2 with: zero] != equal);
    [tmpA release];
    [r1 release];
    [r2 release];
    gcd = [FGInt gcd: fGInt1 and: fGInt2];
    tmpFGInt1 = [FGInt multiply: aFGInt and: fGInt1];
    [tmpFGInt2 release];
    tmpFGInt2 = [FGInt subtract: gcd and: tmpFGInt1];
    [tmpFGInt1 release];
    [gcd release];
    tmpDivMod = [FGInt divide: tmpFGInt2 by: fGInt2];
    bFGInt = [[tmpDivMod objectForKey: quotientKey] retain];
    [tmpDivMod release];
    [tmpFGInt2 release];
    
    [one release];

    [bezoutBachetCoefficients setObject: aFGInt forKey:aKey];
    [bezoutBachetCoefficients setObject: bFGInt forKey:bKey];
    [aFGInt release];
    [bFGInt release];
    
    return bezoutBachetCoefficients;
}


-(BOOL) rabinMillerTest: (FGIntBase) numberOfTests {
    BOOL isPrime = YES;
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *pMinusOne = [FGInt subtract: self and: one], *mFGInt = [pMinusOne copy],
            *zFGInt, *tmpFGInt;
    FGIntOverflow i = 0, j, b = 0;
    NSMutableArray *mFGIntNumber = [mFGInt number];
    
    while (([[mFGIntNumber objectAtIndex: 0] digit] % 2) == 0) {
        if ([[mFGIntNumber objectAtIndex: 0] digit] == 0) {
            b += 32;
            [mFGInt shiftRightBy32];
        } else {
            ++b;
            [mFGInt shiftRight];
        }
    }
    
    while ((i < numberOfTests) && isPrime) {
        ++i;
        tmpFGInt = [[FGInt alloc] initWithFGIntBase: primes[arc4random() % 1228]];
        zFGInt = [FGInt raise: tmpFGInt toThePower: mFGInt montgomeryMod: self];
        [tmpFGInt release];
        j = 0;
        if (([FGInt compareAbsoluteValueOf: zFGInt with: one] != equal) && ([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] != equal)) { 
            while (isPrime && (j < b)) {
                if ((j > 0) && ([FGInt compareAbsoluteValueOf: zFGInt with: one] == equal)) 
                    isPrime = NO;
                else {
                    ++j;
                    if ((j < b) && ([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] != equal)) {
                        tmpFGInt = [FGInt square: zFGInt];
                        [zFGInt release];
                        zFGInt = [FGInt mod: tmpFGInt by: self];
                        [tmpFGInt release];
                        if ([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] == equal) 
                            j = b;
                    } else {
                        if (([FGInt compareAbsoluteValueOf: zFGInt with: pMinusOne] != equal) && ( j >= b))
                            isPrime = NO;
                    }
                }
            }
        }
        [zFGInt release];
    }
    [one release];
    [pMinusOne release];
    [mFGInt release];
    return isPrime;
}


/* 
   Perform a (combined) primality test on FGIntp consisting of a trialdivision upto 9973,
   if the FGInt passes perform numberOfTests Rabin Miller primality tests, returns ok when a
   FGInt is probably prime
*/

-(BOOL) primalityTest: (FGIntBase) numberOfTests {
    if ([self trialDivision])
        if (([self length] == 1) && ([[number objectAtIndex: 0] digit] < 9974))
            return YES;
        else 
            return [self rabinMillerTest: numberOfTests];
    else
        return NO;
}



/* divide fGInt by a 32bit integer divInt and return the result = fGInt / divInt */

+(FGInt *) divide: (FGInt *) fGInt byFGIntBase: (FGIntBase) divInt {
    FGInt *result = [[FGInt alloc] init];
    NSMutableArray *fGIntNumber = [fGInt number], *resultNumber = [result number];
    FGIntOverflow mod = 0, tmpMod, resultLength;
    
    @autoreleasepool{
        for ( id fGIntBase in [fGIntNumber reverseObjectEnumerator] ) {
            tmpMod = (mod << 32) | [fGIntBase digit];
            [resultNumber insertObject: [[FGIntNumberBase alloc] initWithFGIntBase: (tmpMod / divInt)] atIndex: 0];
            mod = tmpMod % divInt;
        }
    }
    resultLength = [resultNumber count];
    while ((resultLength > 1) && ([[resultNumber lastObject] digit] == 0)) {
        [resultNumber removeLastObject];
        --resultLength;
    }
    [result setLength: resultLength];
    [result setSign: [fGInt sign]];
    return result;
}

/* Computes the Legendre symbol for any number aFGInt and
   a prime number pFGInt, returns 0 if pFGInt divides aFGInt, 1 if aFGInt is a
   quadratic residu mod pFGInt, -1 if aFGInt is a quadratic
   nonresidu mod pFGInt
*/

-(int) legendreSymbolMod: (FGInt *) pFGInt {
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *zero = [[FGInt alloc] initWithFGIntBase: 0], 
        *tmpFGInt = [FGInt mod: self by: pFGInt];
    if ([FGInt compareAbsoluteValueOf: zero with: tmpFGInt] == equal) {
        [tmpFGInt release];
        [one release];
        [zero release];
        return 0;
    } else {
        [tmpFGInt release];
        FGInt *tmpFGInt1 = [pFGInt copy], *tmpFGInt2 = [self copy], *tmpFGInt3, *tmpFGInt4, *tmpFGInt5;
        int legendre = 1;
        
        while ([FGInt compareAbsoluteValueOf: tmpFGInt1 with: one] != equal) {
            if (([[[tmpFGInt2 number] objectAtIndex: 0] digit] % 2) == 0) {
                tmpFGInt3 = [FGInt square: tmpFGInt1];
                [tmpFGInt3 decrement];
                [tmpFGInt3 shiftRightBy: 3];
                if (([[[tmpFGInt3 number] objectAtIndex: 0] digit] % 2) != 0) 
                    legendre *= (-1);
                [tmpFGInt3 release];
                [tmpFGInt2 shiftRight];
            } else {
                tmpFGInt3 = [FGInt subtract: tmpFGInt1 and: one];
                tmpFGInt4 = [FGInt subtract: tmpFGInt2 and: one];
                tmpFGInt5 = [FGInt multiply: tmpFGInt3 and: tmpFGInt4];
                [tmpFGInt3 release];
                [tmpFGInt4 release];
                [tmpFGInt5 shiftRightBy: 2];
                if (([[[tmpFGInt5 number] objectAtIndex: 0] digit] % 2) != 0)
                    legendre *= (-1);
                [tmpFGInt5 release];
                tmpFGInt3 = [FGInt mod: tmpFGInt1 by: tmpFGInt2];
                [tmpFGInt1 release];
                tmpFGInt1 = tmpFGInt2;
                tmpFGInt2 = tmpFGInt3;
            }
        }
        [tmpFGInt1 release];
        [tmpFGInt2 release];
        [one release];
        [zero release];
        return legendre;
    }
}



/* Compute a square root modulo a prime number
  SquareRoot^2 mod Prime = Square
*/

+(FGInt *) squareRootOf: (FGInt *) fGInt mod: pFGInt {
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *nFGInt = [[FGInt alloc] initWithFGIntBase: 2], 
            *sFGInt = [pFGInt copy], *bFGInt, *rFGInt, *tmpFGInt, *tmpFGInt1, 
            *tmpFGInt2 = [[FGInt alloc] init], *tempFGInt;
        
    FGIntOverflow a = 0, i, j;

    while ([nFGInt legendreSymbolMod: pFGInt] != -1) 
        [nFGInt increment];
    [sFGInt decrement];
    while (([[[sFGInt number] objectAtIndex: 0] digit] % 2) == 0) {
        if ([[[sFGInt number] objectAtIndex: 0] digit] == 0) {
            a += 32;
            [sFGInt shiftRightBy32];
        } else {
            ++a;
            [sFGInt shiftRight];
        }
    }
    bFGInt = [FGInt raise: nFGInt toThePower: sFGInt montgomeryMod: pFGInt];
    tmpFGInt = [FGInt add: sFGInt and: one];
    [tmpFGInt shiftRight];
    rFGInt = [FGInt raise: fGInt toThePower: tmpFGInt montgomeryMod: pFGInt];
    tmpFGInt1 = [FGInt modularInverse: fGInt mod: pFGInt];
    for ( i = 0; i < a - 1; ++i ) {
        tempFGInt = [FGInt square: rFGInt];
        [tmpFGInt2 release];
        tmpFGInt2 = [FGInt mod: tempFGInt by: pFGInt];
        [tempFGInt release];
        tempFGInt = [FGInt multiply: tmpFGInt1 and: tmpFGInt2];
        [tmpFGInt release];
        tmpFGInt = [FGInt mod: tempFGInt by: pFGInt];
        [tempFGInt release];
        for ( j = 0; j < a - i - 2; ++j ) {
            tempFGInt = [FGInt square: tmpFGInt];
            [tmpFGInt release];
            tmpFGInt = [FGInt mod: tempFGInt by: pFGInt];
            [tempFGInt release];
        }
        if ([FGInt compareAbsoluteValueOf: tmpFGInt with: one] != equal) {
            tempFGInt = [FGInt multiply: rFGInt and: bFGInt];
            [rFGInt release];
            rFGInt = [FGInt mod: tempFGInt by: pFGInt];
            [tempFGInt release];
        }
        if (i >= a - 2) 
            break;
        tempFGInt = [FGInt square: bFGInt];
        [bFGInt release];
        bFGInt = [FGInt mod: tempFGInt by: pFGInt];
        [tempFGInt release];
    }
    [one release];
    [nFGInt release];
    [sFGInt release];
    [bFGInt release];
    [tmpFGInt release];
    [tmpFGInt1 release];
    [tmpFGInt2 release];
    return rFGInt;
}


/* Compute and return self! = self * (self - 1) * (self - 2) * ... * 3 * 2 * 1 */

-(FGInt *) factorial {
    FGInt *one = [[FGInt alloc] initWithFGIntBase: 1], *result = [[FGInt alloc] initWithFGIntBase: 1], 
        *tmpFGInt = [self copy], *tmpFGInt1;
    while ([FGInt compareAbsoluteValueOf: tmpFGInt with: one] == larger) {
        tmpFGInt1 = [FGInt multiply: result and: tmpFGInt];
        [result release];
        result = tmpFGInt1;
        [tmpFGInt subtractWith: one];
    }
    return result;
}



/* Searches for a nearest prime number p larger than the number self is initialized with */

//-(FGInt *) findNearestLargerPrime {
//    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2], *prime = [self copy];
//    if (([[[prime number] objectAtIndex: 0] digit] % 2) == 0)
//        [[[prime number] objectAtIndex: 0] setDigit: [[[prime number] objectAtIndex: 0] digit] + 1];
//    while (![prime primalityTest: 5])
//        [prime addWith: two];
//    [two release];
//    return prime;
//}


-(void) findNearestLargerPrime {
    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2];
    [self addWith: two];
    if (([[number objectAtIndex: 0] digit] % 2) == 0)
        [[number objectAtIndex: 0] setDigit: [[number objectAtIndex: 0] digit] + 1];
    while (![self primalityTest: 5])
        [self addWith: two];
    [two release];
}


-(void) findNearestLargerPrimeWithRabinMillerTests: (FGIntBase) numberOfTests {
    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2];
    [self addWith: two];
    if (([[number objectAtIndex: 0] digit] % 2) == 0)
        [[number objectAtIndex: 0] setDigit: [[number objectAtIndex: 0] digit] + 1];
    while (![self primalityTest: numberOfTests])
        [self addWith: two];
    [two release];
}


/* Searches for a nearest prime number p larger than self, such that (p mod q = 1), make sure qFGInt is a prime number */

//-(FGInt *) findNearestLargerDSAPrimeWith: (FGInt *) qFGInt {
//    FGInt *two = [[FGInt alloc] initWithFGIntBase: 2], *one = [[FGInt alloc] initWithFGIntBase: 1], 
//        *prime = [self copy], *doubleQ = [qFGInt copy], *tmpFGInt;
//    [doubleQ shiftRight];
//    tmpFGInt = [FGInt mod: prime by: qFGInt];
//    [prime addWith: tmpFGInt];
//    [tmpFGInt release];
//    [prime addWith: one];
//    [one release];
//    if (([[[prime number] objectAtIndex: 0] digit] % 2) == 0)
//        [prime addWith: qFGInt];
//    while (![prime primalityTest: 5])
//        [prime addWith: doubleQ];
//    [two release];
//    [doubleQ release];
//    return prime;
//}

-(void) findNearestLargerDSAPrimeWith: (FGInt *) qFGInt {
    FGInt *doubleQ = [qFGInt copy], *tmpFGInt;
    [doubleQ shiftLeft];
    tmpFGInt = [FGInt mod: self by: qFGInt];
    [self subtractWith: tmpFGInt];
    [tmpFGInt release];
    [self increment];
    if (([[[self number] objectAtIndex: 0] digit] % 2) == 0)
        [self addWith: qFGInt];
    while (![self primalityTest: 5])
        [self addWith: doubleQ];
    [doubleQ release];
}


/* Tests whether nFGInt is smooth wrt to primes and has a prime factor of at least 
    leastSize bits, which it returns. If not it returns nil.
*/

-(FGInt *) isNearlyPrimeAndAtLeast: (FGIntOverflow) leastSize {
    FGInt *rFGInt = [self copy];
    FGIntBase i, mod;
    while (([[[rFGInt number] objectAtIndex: 0] digit] % 2) == 0) {
        if ([[[rFGInt number] objectAtIndex: 0] digit] == 0)
            [rFGInt shiftRightBy32];
        else 
            [rFGInt shiftRight];
    }
    for ( i = 0; i < 1228; ++i ) {
        while ([rFGInt modFGIntByInt: primes[i]] == 0) {
            [rFGInt divideByInt: primes[i]];
        }
    }
    FGIntOverflow bitSize = [rFGInt bitSize];
    if (bitSize < leastSize) {
        [rFGInt release];
        return nil;
    }
    FGIntBase rmTests = 4;
    if (bitSize < 460) rmTests = 7;
    if (bitSize < 300) rmTests = 13;
    if (bitSize < 260) rmTests = 19;
    if (bitSize < 200) rmTests = 29;
    if (bitSize < 160) rmTests = 37;
    if ([rFGInt rabinMillerTest: rmTests])
        return rFGInt;
    else {
        [rFGInt release];
        return nil;
    }
}



/* Convert NSData to a base64 NSString
*/

+(NSString *) convertNSDataToBase64: (NSData *) nsData {
    if (!nsData) {
        NSLog(@"No nsData available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    @autoreleasepool{
        FGIntOverflow i;
        NSMutableString *string = [[NSMutableString alloc] init];
    
        unsigned char aBuffer[3];
        NSRange bytesRange;
        
        for ( i = 0; i < ([nsData length] / 3); ++i ) {
            bytesRange = NSMakeRange(i*3, 3);
            [nsData getBytes: aBuffer range: bytesRange];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[aBuffer[0] >> 2] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[0] & 3) << 4) | (aBuffer[1] >> 4)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[1] & 15) << 2) | (aBuffer[2] >> 6)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[aBuffer[2] & 63] length: 1]];
        }
        if (([nsData length] % 3) == 1) {
            bytesRange = NSMakeRange(3*([nsData length]/3), [nsData length] % 3);
            [nsData getBytes: aBuffer range: bytesRange];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[aBuffer[0] >> 2] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[0] & 3) << 4)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[64] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[64] length: 1]];
        }
        if (([nsData length] % 3) == 2) {
            bytesRange = NSMakeRange(3*([nsData length]/3), [nsData length] % 3);
            [nsData getBytes: aBuffer range: bytesRange];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[aBuffer[0] >> 2] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[0] & 3) << 4) | (aBuffer[1] >> 4)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[((aBuffer[1] & 15) << 2)] length: 1]];
            [string appendString:[NSString stringWithCharacters:&pgpBase64[64] length: 1]];
        }
        return string;
    }
}


/* Convert an NSString to a base64 NSString
*/

+(NSString *) convertNSStringToBase64: (NSString *) nsString {
    if (!nsString) {
        NSLog(@"No nsString available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    return [FGInt convertNSDataToBase64: [nsString dataUsingEncoding:NSUTF8StringEncoding]];
}


+(int) getBase64Index: (char) base64Char {
    if (base64Char == 43)
        return 62;
    if (base64Char == 47)
        return 63;
    if (base64Char < 58)
        return (base64Char - 48) + 52;
    if (base64Char == 61)
        return 0;
    if (base64Char < 91)
        return (base64Char - 65);
    if (base64Char < 123)
        return (base64Char - 97) + 26;
    return 0;
}


/* Convert a base64 NSString to NSData (binary data)
*/

+(NSData *) convertBase64ToNSData: (NSString *) base64String {
    if (!base64String) {
        NSLog(@"No base64String available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    @autoreleasepool{
        FGIntOverflow i;
        FGIntBase j, all24Bits;
        NSMutableData *nsData = [[NSMutableData alloc] init];
    
        unsigned char aBuffer[3];
        unsigned char a64Buffer[4];
        NSRange bytesRange;
        NSData *stringBytes=[base64String dataUsingEncoding: NSASCIIStringEncoding];

        for ( i = 0; i < ([stringBytes length] / 4); ++i ) {
            bytesRange = NSMakeRange(i*4, 4);
            [stringBytes getBytes: a64Buffer range: bytesRange];
            all24Bits = 0;
            for ( j = 0; j < 4; ++j )
                all24Bits = (all24Bits << 6) | [FGInt getBase64Index: a64Buffer[j]];
            for ( j = 0; j < 3; ++j )
                aBuffer[j] = (all24Bits >> ((2-j)*8)) & 255;
            [nsData appendBytes: aBuffer length: 3];
        }
        if (a64Buffer[3] == 61) {
            [nsData setLength: [nsData length] - 1];
            if (a64Buffer[2] == 61)
                [nsData setLength: [nsData length] - 1];
        }

        return nsData;
    }
}


/* Convert a base64 NSString to NSString
   This is tricky, it expects the outcome to be UTF8 encoded
*/

+(NSString *) convertBase64ToNSString: (NSString *) base64String {
    if (!base64String) {
        NSLog(@"No base64String available for %s at line %d", __PRETTY_FUNCTION__, __LINE__);
        return nil;
    }
    return [[NSString alloc] initWithData: [FGInt convertBase64ToNSData: base64String] encoding: NSUTF8StringEncoding];
}



-(FGIntOverflow) bitSize {
    FGIntOverflow bits = (length - 1) * 32;
    FGIntBase lastDigit = [[number lastObject] digit];
    while (lastDigit != 0) {
        ++bits;
        lastDigit >>= 1;
    }
    return bits;
}





@end