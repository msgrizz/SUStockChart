//
//  UIColor+SSCColorStyle.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "UIColor+SSCColorStyle.h"
#import "SSCConstaints.h"

@implementation UIColor (SSCColorStyle)

+ (UIColor *)ssc_backgroundColor{
    return RGBCOLOR(33., 32., 46.);
}

+ (UIColor *)ssc_gridLineColor{
    return RGBCOLOR(114., 142., 132.);
}

+ (UIColor *)ssc_riseColor{
    return RGBCOLOR(227., 76., 69.);
}

+ (UIColor *)ssc_dropColor{
    return RGBCOLOR(58., 186., 150.);
}

+ (UIColor *)ssc_ma5Color{
    return RGBCOLOR(184., 0., 121.);
}

+ (UIColor *)ssc_ma10Color{
    return RGBCOLOR(222., 151., 34.);
}

+ (UIColor *)ssc_ma20Color{
    return RGBCOLOR(31., 120., 192.);
}
@end
