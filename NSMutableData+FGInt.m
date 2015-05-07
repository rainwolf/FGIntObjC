#import "NSMutableData+FGInt.h"


@implementation NSMutableData (FGInt)



-(NSMutableData *) initWithHexString: (NSString *) hexString {
    if (self = [super init]) {

	    hexString = [hexString lowercaseString];
	    // NSMutableData *data= [[NSMutableData alloc] init];
	    unsigned char whole_byte;
	    char byte_chars[3] = {'\0','\0','\0'};
	    int i = 0;
	    int length = hexString.length;
	    while (i < length - 1) {
	        char c = [hexString characterAtIndex:i++];
	        if (c < '0' || (c > '9' && c < 'a') || c > 'f') {
	            continue;
	        }
	        byte_chars[0] = c;
	        byte_chars[1] = [hexString characterAtIndex:i++];
	        whole_byte = strtol(byte_chars, NULL, 16);
	        [self appendBytes:&whole_byte length:1];
	    }

    }
    return self;
}


-(NSString *) toHexString {
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];

    if (!dataBuffer) {
        return nil;
    }

    unsigned long dataLength  = [self length];
    NSMutableString *hexString  = [[NSMutableString alloc] init];

    @autoreleasepool{
	    for (int i = 0; i < dataLength; ++i) {
	        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
	    }
	}
    return hexString;
}



@end