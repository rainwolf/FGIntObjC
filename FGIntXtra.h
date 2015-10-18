#import <Foundation/Foundation.h>
#import <Security/SecRandom.h>
#import <CommonCrypto/CommonHMAC.h>
#import "FGInt.h"


@interface FGIntXtra : NSObject


+(NSData *) SHA256HMACForKey: (NSData *) key AndData: (NSData *)data;
+(NSData *) SHA256: (NSData *) plainText;
+(NSData *) SHA512: (NSData *) plainText;
+(void) incrementNSMutableData: (NSMutableData *) data;


@end