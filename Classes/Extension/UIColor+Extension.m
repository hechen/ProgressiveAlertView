//
//  Created by He Chen on 2017/9/30.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor *)colorWithHex:(NSString *)hexCode {
	if ([hexCode hasPrefix:@"#"])
		hexCode = [hexCode substringFromIndex:1];

	if (hexCode.length == 3) {
		hexCode = [NSString stringWithFormat:@"%@%@", hexCode, hexCode];
	}

	NSScanner *scanner = [NSScanner scannerWithString:hexCode];
	unsigned hexNum;
	if (![scanner scanHexInt:&hexNum]) return nil;

	UInt32 r = (hexNum >> 16) & 0xFF;
	UInt32 g = (hexNum >> 8) & 0xFF;
	UInt32 b = (hexNum) & 0xFF;
	UIColor *result = [UIColor colorWithRed:r / 255.0f
									  green:g / 255.0f
									   blue:b / 255.0f
									  alpha:1.0f];
	return result;
}

@end
