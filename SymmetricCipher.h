#import <Foundation/Foundation.h>

typedef unsigned int word;



@interface Salsa20 : NSObject <NSCopying> {
	NSData *inputData, *nonce, *key;
}
@property (assign, readwrite) NSData *inputData;
@property (assign, readwrite) NSData *nonce;
@property (assign, readwrite) NSData *key;

-(NSData *) salsa20Encrypt;
-(NSData *) salsa20Decrypt;
-(NSData *) xsalsa20Encrypt;
-(NSData *) xsalsa20Decrypt;

@end



