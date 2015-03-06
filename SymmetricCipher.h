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
	NSData *inputData, *nonce, *key, *hmac;
}
@property (assign, readwrite) NSData *inputData;
@property (assign, readwrite) NSData *nonce;
@property (assign, readwrite) NSData *key;
@property (nonatomic, assign, readwrite) NSData *hmac;
-(NSData *) computeHMAC;
-(BOOL) verifyHmac;


@end


@interface Poly1305AES : Poly1305 <NSCopying> {
}
@end




