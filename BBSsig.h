#import <Foundation/Foundation.h>
#import "BN256.h"





@interface BBSRevocation : NSObject {
	G1Point *a;
	FGInt *x;
	G2Point *aStar;
}
@property (retain, readwrite) G1Point *a;
@property (retain, readwrite) FGInt *x;
@property (retain, readwrite) G2Point *aStar;

-(id) unMarshal: (NSData *) marshalData;
-(void) dealloc;
-(NSData *) marshal;

@end



@interface BBSGroup : NSObject <NSMutableCopying> {
	G1Point *g1, *h, *u, *v;
	G2Point	*g2, *w;
	GFP12 *ehw, *ehg2, *minusEg1g2;
}
@property (retain, readwrite) G1Point *g1, *h, *u, *v;
@property (retain, readwrite) G2Point *g2, *w;
@property (retain, readwrite) GFP12 *ehw, *ehg2, *minusEg1g2;

-(void) updateWithRevocation: (BBSRevocation *) revocation;
-(id) unMarshal: (NSData *) marshalData;
-(void) dealloc;
-(NSData *) marshal;

@end


@class BBSPrivateKey;
@interface BBSMemberKey : NSObject <NSMutableCopying> {
	BBSGroup *group;
	FGInt *x;
	G1Point *a;
}
@property (retain, readwrite) BBSGroup *group;
@property (retain, readwrite) FGInt *x;
@property (retain, readwrite) G1Point *a;

-(id) initNewMemberWithGroupPrivateKey: (BBSPrivateKey *) bbsGroupPrivate;
-(BOOL) updateWithRevocation: (BBSRevocation *) revocation;
-(id) unMarshal: (NSData *) marshalData;
-(void) dealloc;
-(NSData *) marshal;

@end


@interface BBSPrivateKey : NSObject <NSMutableCopying> {
	BBSGroup *group;
	FGInt *xi1, *xi2, *gamma;
}
@property (retain, readwrite) BBSGroup *group;
@property (retain, readwrite) FGInt *xi1, *xi2, *gamma;

-(id) generateGroup;
-(id) unMarshal: (NSData *) marshalData;
-(void) dealloc;
-(NSData *) marshal;
-(BBSRevocation *) generateRevocationForMember: (BBSMemberKey *) memberKey;

@end


@interface BBSsig : NSObject {
	NSData *message, *signature;
}
@property (retain, readwrite) NSData *message;
@property (retain, readwrite) NSData *signature;

+(NSData *) hash: (NSData *) plaintext;
+(NSData *) sign: (NSData *) digest withMemberKey: (BBSMemberKey *) memberKey;
+(G1Point *) r1245: (G1Point *) g1 and: (G1Point *) g2 addKtimes: (FGInt *) k andLtimes: (FGInt *) l  with: (FGInt *) pFGInt withOrder: (FGInt *) order andInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP12 *) sAdd: (FGInt *) s1 and: (FGInt *) s2 andRaise: (GFP12 *) gfp12 with: (FGInt *) pFGInt withOrder: (FGInt *) order andInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(GFP12 *) pair: (G2Point *) g2 and: (G1Point *) g1 multiply: (GFP12 *) gfp12 andRaiseTo: (FGInt *) exp with: (FGInt *) pFGInt withInvertedP: (FGInt *) invertedP andPrecision: (FGIntOverflow) precision;
+(BOOL) verifySignature: (NSData *) signature ofDigest: (NSData *) digest withGroupKey: (BBSGroup *) groupKey;
+(NSData *) openSignature: (NSData *) signature withPrivateKey: (BBSPrivateKey *) privateKey;
+(void) testBBSsig;


@end




































