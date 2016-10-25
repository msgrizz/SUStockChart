//
//  UIColor+SSCColorStyle.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "UIColor+SSCColorStyle.h"

@implementation UIColor (SSCColorStyle)
+ (UIColor *)ssc_gridLineColor{
    return [UIColor lightGrayColor];
}

+ (UIColor *)ssc_riseColor{
    return [UIColor redColor];
}

+ (UIColor *)ssc_dropColor{
    return [UIColor greenColor];
}

+ (UIColor *)ssc_ma5Color{
    return [UIColor magentaColor];
}

+ (UIColor *)ssc_ma10Color{
    return [UIColor yellowColor];
}

+ (UIColor *)ssc_ma20Color{
    return [UIColor cyanColor];
}
@end
