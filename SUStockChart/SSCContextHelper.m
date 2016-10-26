//
//  SSCContextHelper.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 26/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "SSCContextHelper.h"

@implementation SSCContextHelper

+ (NSArray *)viewModelListFromRawData:(NSArray *)dataList viewSize:(CGSize)viewSize candleWidth:(CGFloat)candleWidth currentIndex:(NSInteger)currentIndex{
    
    if (currentIndex < 0) return nil;
    if (dataList.count == 0) return nil;
    
    // make view model for chart
    CGFloat canvasWidth = viewSize.width - kSSCChartViewMarginLeft;
    CGFloat mainBoxheight = viewSize.height * kSSCChartMainBoxHeightPercent;
    CGFloat subBoxHeight = viewSize.height - mainBoxheight - kSSCChartViewGap;
    NSUInteger candleCount = canvasWidth / (candleWidth + kSSCChartCandleSpace);
    
    candleCount = MIN(candleCount, (dataList.count - currentIndex));
    NSMutableArray *viewModelList = [[NSMutableArray alloc] initWithCapacity:candleCount];
    
    // data will display
    NSArray *dataWillDisplayList = [dataList subarrayWithRange:NSMakeRange(currentIndex, candleCount)];
    
    double maxVoTurnover = [SSCCalc ssc_maxVoturnover:dataWillDisplayList];
    double minPrice = [SSCCalc ssc_minPrice:dataWillDisplayList];
    double maxPrice = [SSCCalc ssc_maxPrice:dataWillDisplayList];
    
    CGFloat priceScope = fabs(maxPrice - minPrice);
    
    for (NSInteger i = 0; i < candleCount; i++) {
        SSCDayModel *aDataModel = dataWillDisplayList[i];
        SSCDayViewModel *aViewModel = [SSCDayViewModel new];
        
        aViewModel.color = (aDataModel.pChange >= 0.) ? [UIColor ssc_riseColor].CGColor : [UIColor ssc_dropColor].CGColor;
        
        // open & close
        CGFloat startP = fabs(maxPrice - aDataModel.tOpen) / priceScope;
        aViewModel.bodyStartY = startP * mainBoxheight;
        CGFloat endP = fabs(maxPrice - aDataModel.tClose) / priceScope;
        CGFloat endY = endP * mainBoxheight;
        endY = fabs(aViewModel.bodyStartY - endY) > 1. ? endY : aViewModel.bodyStartY + 1.; // height >= 1.
        aViewModel.bodyEndY = endY;
        
        
        // turnover
        CGFloat voTurnoverP = aDataModel.voTurnover / maxVoTurnover;
        aViewModel.turnoverStartY = viewSize.height - (subBoxHeight * voTurnoverP);
        aViewModel.turnoverEndY = viewSize.height;
        
        // high & low
        CGFloat wStartP = fabs(maxPrice - aDataModel.high) / priceScope;
        aViewModel.wickStartY = wStartP * mainBoxheight;
        CGFloat wEndP = fabs(maxPrice - aDataModel.low) / priceScope;
        aViewModel.wickEndY = wEndP * mainBoxheight;
        
        // X asix
        CGFloat distanceToRight = (kSSCChartCandleSpace + candleWidth) * i + candleWidth / 2.;
        CGFloat centerX = viewSize.width - distanceToRight;
        aViewModel.candleCenterX = centerX;
        
        // MA
        NSInteger toIndex = currentIndex + i;
        
        aViewModel.ma5Point = [self.class pointForMA:5 toIndex:toIndex maxPrice:maxPrice priceScope:priceScope mainBoxheight:mainBoxheight centerX:centerX dataList:dataList];
        aViewModel.ma10Point = [self.class pointForMA:10 toIndex:toIndex maxPrice:maxPrice priceScope:priceScope mainBoxheight:mainBoxheight centerX:centerX dataList:dataList];
        aViewModel.ma20Point = [self.class pointForMA:20 toIndex:toIndex maxPrice:maxPrice priceScope:priceScope mainBoxheight:mainBoxheight centerX:centerX dataList:dataList];
        
        [viewModelList addObject:aViewModel];
    }
    return viewModelList;
}

+ (CGPoint)pointForMA:(NSInteger)dayCount toIndex:(NSInteger)toIndex maxPrice:(double)maxPrice priceScope:(double)priceScope mainBoxheight:(CGFloat)mainBoxheight centerX:(CGFloat)centerX dataList:(NSArray *)dataList{
    NSInteger leftCount = dataList.count - toIndex;
    NSRange range = NSMakeRange(toIndex, MIN(leftCount, dayCount));
    NSArray *list = [dataList subarrayWithRange:range];
    NSNumber *averageNum = [list valueForKeyPath:@"@avg.tClose"];
    CGFloat maYPercent = fabs(maxPrice - averageNum.doubleValue) / priceScope;
    //    NSLog(@"per %f", maYPercent);
    if (maYPercent > 1.) {
        return CGPointMake(-1, -1);
    }else{
        return CGPointMake(centerX, maYPercent * mainBoxheight);
    }
}

+ (void)maLineContext:(CGContextRef)context type:(NSInteger)type color:(UIColor *)color viewModelList:(NSArray *)viewModelList{
    
    //    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
    //        SSCDayViewModel *item = (SSCDayViewModel *)evaluatedObject;
    //        switch (type) {
    //            case 5:
    //                return item.ma5Point.x >= 0.0;
    //                break;
    //            case 10:
    //                return item.ma10Point.x >= 0.0;
    //                break;
    //            case 20:
    //            default:
    //                return item.ma20Point.x >= 0.0;
    //        }
    //    }];
    //    NSArray *lineArray = [_viewModelList filteredArrayUsingPredicate:predicate];
    NSMutableArray *lineArray = [[NSMutableArray alloc] initWithCapacity:viewModelList.count];
    for (SSCDayViewModel *viewModel in viewModelList) {
        CGPoint point;
        switch (type) {
            case 5:
                point = viewModel.ma5Point;
                break;
            case 10:
                point = viewModel.ma10Point;
                break;
            case 20:
            default:
                point = viewModel.ma20Point;
                break;
        }
        if (point.x >= kSSCChartViewMarginLeft && point.y >= 0.) {
            [lineArray addObject:viewModel];
        }
    }
    NSInteger count = [lineArray count];
    CGPoint addLines[count];
    for (NSInteger j = 0; j < count; j++) {
        SSCDayViewModel *viewModel = viewModelList[j];
        CGPoint point;
        switch (type) {
            case 5:
                point = viewModel.ma5Point;
                break;
            case 10:
                point = viewModel.ma10Point;
                break;
            case 20:
            default:
                point = viewModel.ma20Point;
                break;
        }
        addLines[j].x = point.x;
        addLines[j].y = point.y;
    }
    
    CGContextBeginPath(context);
    CGContextAddLines(context, addLines, count);
    CGContextSetLineWidth(context, 1.);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokePath(context);
}

+ (void)textContext:(CGContextRef)context dataDisplayList:(NSArray *)dataDisplayList rect:(CGRect)rect{
    
    if (dataDisplayList.count == 0) return;
    
    double maxVoTurnover = [SSCCalc ssc_maxVoturnover:dataDisplayList];
    double minPrice = [SSCCalc ssc_minPrice:dataDisplayList];
    double maxPrice = [SSCCalc ssc_maxPrice:dataDisplayList];
    
    double priceScope = fabs(maxPrice - minPrice);
    double priceGap = priceScope / 4.;
    NSString *textA0 = [NSString stringWithFormat:@"%.2f", maxPrice];
    NSString *textA1 = [NSString stringWithFormat:@"%.2f", maxPrice - priceGap * 1.];
    NSString *textA2 = [NSString stringWithFormat:@"%.2f", maxPrice - priceGap * 2.];
    NSString *textA3 = [NSString stringWithFormat:@"%.2f", maxPrice - priceGap * 3.];
    NSString *textA4 = [NSString stringWithFormat:@"%.2f", minPrice];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentRight];
    NSDictionary *attr = @{
                           NSFontAttributeName              : [UIFont systemFontOfSize:8.],
                           NSForegroundColorAttributeName   : [UIColor whiteColor],
                           NSParagraphStyleAttributeName    : style
                           };
    
    CGFloat mainboxHeight = rect.size.height * kSSCChartMainBoxHeightPercent;
    CGFloat gap = mainboxHeight / 4.;
    CGRect rectA0 = CGRectMake(0., 0., kSSCChartViewMarginLeft - 5., 8.);
    CGRect rectA1 = CGRectMake(0., gap * 1. - 8, kSSCChartViewMarginLeft - 5., 8.);
    CGRect rectA2 = CGRectMake(0., gap * 2. - 8, kSSCChartViewMarginLeft - 5., 8.);
    CGRect rectA3 = CGRectMake(0., gap * 3. - 8, kSSCChartViewMarginLeft - 5., 8.);
    CGRect rectA4 = CGRectMake(0., gap * 4. - 8, kSSCChartViewMarginLeft - 5., 8.);
    
    [textA0 drawInRect:rectA0 withAttributes:attr];
    [textA1 drawInRect:rectA1 withAttributes:attr];
    [textA2 drawInRect:rectA2 withAttributes:attr];
    [textA3 drawInRect:rectA3 withAttributes:attr];
    [textA4 drawInRect:rectA4 withAttributes:attr];
    
    CGFloat subBoxTop = mainboxHeight + kSSCChartViewGap;
    CGRect rectB0 = CGRectMake(0., subBoxTop, kSSCChartViewMarginLeft - 5., 8.);
    CGRect rectB1 = CGRectMake(0., rect.size.height - 12., kSSCChartViewMarginLeft - 5., 12);
    
    NSString *textB0 = [NSString stringWithFormat:@"%.2f万", maxVoTurnover / 10000 / 100];
    NSString *textB1 = [NSString stringWithFormat:@"万手"];
    [textB0 drawInRect:rectB0 withAttributes:attr];
    [textB1 drawInRect:rectB1 withAttributes:attr];
}

+ (void)gridContext:(CGContextRef)context rect:(CGRect)rect{
    CGContextSetStrokeColorWithColor(context, [UIColor ssc_gridLineColor].CGColor);
    CGContextSetLineWidth(context, 1.0f);
    CGContextSetAlpha(context, .5);
    
    CGFloat mainBoxheight = rect.size.height * kSSCChartMainBoxHeightPercent;
    CGFloat hLineY_0 = 0.;
    CGFloat hLineY_1 = mainBoxheight / 4.;
    CGFloat hLineY_2 = hLineY_1 * 2.;
    CGFloat hLineY_3 = hLineY_1 * 3.;
    CGFloat hLineY_4 = mainBoxheight;
    
    //sub box
    CGFloat hLineY_a = mainBoxheight + kSSCChartViewGap;
    CGFloat hLineY_b = rect.size.height;
    
    CGFloat marginLeft = kSSCChartViewMarginLeft;
    CGFloat rightX = rect.size.width;
    
    // horizontal line
    [self.class drawContext:context fromPoint:MPOINT(marginLeft, hLineY_0) toPoint:MPOINT(rightX, hLineY_0)];
    [self.class drawContext:context fromPoint:MPOINT(marginLeft, hLineY_1) toPoint:MPOINT(rightX, hLineY_1)];
    [self.class drawContext:context fromPoint:MPOINT(marginLeft, hLineY_2) toPoint:MPOINT(rightX, hLineY_2)];
    [self.class drawContext:context fromPoint:MPOINT(marginLeft, hLineY_3) toPoint:MPOINT(rightX, hLineY_3)];
    [self.class drawContext:context fromPoint:MPOINT(marginLeft, hLineY_4) toPoint:MPOINT(rightX, hLineY_4)];
    
    [self.class drawContext:context fromPoint:MPOINT(marginLeft, hLineY_a) toPoint:MPOINT(rightX, hLineY_a)];
    [self.class drawContext:context fromPoint:MPOINT(marginLeft, hLineY_b) toPoint:MPOINT(rightX, hLineY_b)];
    
    // vertical line
    [self.class drawContext:context fromPoint:MPOINT(marginLeft, 0.) toPoint:MPOINT(marginLeft, mainBoxheight)];
    [self.class drawContext:context fromPoint:MPOINT(rightX, 0.) toPoint:MPOINT(rightX, mainBoxheight)];
    
    [self.class drawContext:context fromPoint:MPOINT(marginLeft, hLineY_a) toPoint:MPOINT(marginLeft, hLineY_b)];
    [self.class drawContext:context fromPoint:MPOINT(rightX, hLineY_a) toPoint:MPOINT(rightX, hLineY_b)];
    
    CGContextStrokePath(context);
    CGContextSetAlpha(context, 1.0);
}

+ (void)drawContext:(CGContextRef)context fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint{
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
}

@end
