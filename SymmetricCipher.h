#import <Foundation/Foundation.h>

typedef unsigned int word;



@interface Salsa20 : NSObject <NSCopying> {
	NSData *inputData, *nonce, *key;
}
@property (assign, readwrite) NSData *inputData;
@property (assign, readwrite) NSData *nonce;
@property (assign, readwrite) NSData *key;

-(NSData *) encrypt;
-(NSData *) decrypt;

@end






@interface Poly1305 : NSObject <NSCopying> {
	NSData *message, *r, *s, *hmac;
}
@property (assign, readwrite) NSData *message;
@property (assign, readwrite) NSData *r;
@property (assign, readwrite) NSData *s;
@property (nonatomic, assign, readwrite) NSData *hmac;
-(NSData *) computeHMAC;
-(BOOL) verifyHmac;


@end


@interface Poly1305AES : Poly1305 <NSCopying> {
	NSData *key, *nonce;
}
@property (assign, readwrite) NSData *key;
@property (assign, readwrite) NSData *nonce;

@end




