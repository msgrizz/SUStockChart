//
//  SSCConstaints.h
//  SUStockChart
//
//  Created by Su Xiaozhou on 26/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBCGCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1].CGColor

#define MPOINT(x, y) CGPointMake(x, y)

static CGFloat const kSSCChartViewMarginLeft = 30.;
static CGFloat const kSSCChartViewGap = 9.;
static CGFloat const kSSCChartMainBoxHeightPercent = 0.7;
static CGFloat const kSSCChartCandleSpace = 1.;
static CGFloat const kSSCChartCandleLampwickWidth = 1.;
static NSString *kSSCChartIndexChangeKey = @"indexChange";
static NSString *kSSCChartIndexSelectedKey = @"indexSelected";
