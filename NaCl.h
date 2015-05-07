#import <Foundation/Foundation.h>


@interface NaClPacket : NSObject {
	NSData *message, *key, *nonce, *recipientPK, *secretKey;
}
@property (retain, readwrite) NSData *message;
@property (retain, readwrite) NSData *key;
@property (retain, readwrite) NSData *nonce;
@property (retain, readwrite) NSData *recipientPK;
@property (retain, readwrite) NSData *secretKey;

-(NaClPacket *) initWithMessage: (NSData *) messageData key: (NSData *) keyData andNonce: (NSData *) nonceData;
-(NaClPacket *) initWithMessage: (NSData *) messageData recipientsPublicKey: (NSData *) recipientPKData secretKey: (NSData *) secretKeyData andNonce: (NSData *) nonceData;
-(NSData *) packXsalsa20Poly1305;
-(NSData *) unpackXsalsa20Poly1305;
-(NSData *) packCurve25519Xsalsa20Poly1305;
-(NSData *) unpackCurve25519Xsalsa20Poly1305;


@end

