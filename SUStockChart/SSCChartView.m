//
//  SSCChartView.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "SSCChartView.h"
#import "UIColor+SSCColorStyle.h"

#define MPOINT(x, y) CGPointMake(x, y)

static CGFloat const kSSCChartViewMarginLeft = 30.;
static CGFloat const kSSCChartMainBoxHeightPercent = 0.7;

@interface SSCChartView()
@property NSInteger currentIndex; //First one from right side on chart
@end

@implementation SSCChartView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        _currentIndex = 0;
    }
    return self;
}

- (void)setContent:(NSArray *)data{
    
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    // Gridding
    CGContextSetStrokeColorWithColor(context, [UIColor ssc_gridLineColor].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetAlpha(context, .5);
    
    CGFloat mainBoxheight = rect.size.height * kSSCChartMainBoxHeightPercent;
    CGFloat hLineY_0 = 0.;
    CGFloat hLineY_1 = mainBoxheight / 3.;
    CGFloat hLineY_2 = hLineY_1 * 2.;
    CGFloat hLineY_3 = mainBoxheight;
    
    //sub box
    CGFloat hLineY_a = mainBoxheight + 20.;
    CGFloat hLineY_b = rect.size.height;
    
    CGFloat marginLeft = kSSCChartViewMarginLeft;
    CGFloat boxWidth = rect.size.width - marginLeft;
    
    // horizontal line
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_0) toPoint:MPOINT(boxWidth, hLineY_0)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_1) toPoint:MPOINT(boxWidth, hLineY_1)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_2) toPoint:MPOINT(boxWidth, hLineY_2)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_3) toPoint:MPOINT(boxWidth, hLineY_3)];
    
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_a) toPoint:MPOINT(boxWidth, hLineY_a)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_b) toPoint:MPOINT(boxWidth, hLineY_b)];
    
    // vertical line
    [self drawContext:context fromPoint:MPOINT(marginLeft, 0.) toPoint:MPOINT(marginLeft, hLineY_3)];
    [self drawContext:context fromPoint:MPOINT(boxWidth, 0.) toPoint:MPOINT(boxWidth, hLineY_3)];
    
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_a) toPoint:MPOINT(marginLeft, hLineY_b)];
    [self drawContext:context fromPoint:MPOINT(boxWidth, hLineY_a) toPoint:MPOINT(boxWidth, hLineY_b)];
    
    
    
    
    CGContextStrokePath(context);
    CGContextSetAlpha(context, 1.0);
}

- (void)drawContext:(CGContextRef)context fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint{
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
}


@end
