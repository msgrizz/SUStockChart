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
@end
