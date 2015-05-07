#import <Foundation/Foundation.h>


@interface NSMutableData (FGInt)



-(NSMutableData *) initWithHexString: (NSString *) hexString;
-(NSString *) toHexString;


@end;