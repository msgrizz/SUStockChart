//
//  SSCChartView.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "SSCChartView.h"
#import "UIColor+SSCColorStyle.h"

#import "SSCDayModel.h"
#import "SSCDayViewModel.h"

#define MPOINT(x, y) CGPointMake(x, y)

static CGFloat const kSSCChartViewMarginLeft = 30.;
static CGFloat const kSSCChartViewGap = 9.;
static CGFloat const kSSCChartMainBoxHeightPercent = 0.7;
static CGFloat const kSSCChartCandleSpace = 1.;
static CGFloat const kSSCChartCandleLampwickWidth = 1.;

@interface SSCChartView()
@property NSInteger currentIndex; //First one from right side on chart
@property NSArray *dataList;
@property NSMutableArray *viewModelList;
@property CGFloat candleBodyWidth;
@end

@implementation SSCChartView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        _currentIndex = 0;
        _candleBodyWidth = 7.;
    }
    return self;
}

- (void)setContent:(NSArray *)data{
    _dataList = data;
}

- (void)buildViewData:(CGSize)viewSize candleWidth:(CGFloat)candleWidth currentIndex:(NSInteger)currentIndex{
    
    
    // make view model for chart
    CGFloat canvasWidth = viewSize.width - kSSCChartViewMarginLeft;
    CGFloat mainBoxheight = viewSize.height * kSSCChartMainBoxHeightPercent;
    CGFloat subBoxHeight = viewSize.height - mainBoxheight - kSSCChartViewGap;
    NSInteger candleCount = floor((canvasWidth) / (candleWidth + kSSCChartCandleSpace));
    
    candleCount = MIN(candleCount, (_dataList.count - currentIndex));
    _viewModelList = [[NSMutableArray alloc] initWithCapacity:candleCount];
    
    // data will display
    NSArray *dataWillDisplayList = [_dataList subarrayWithRange:NSMakeRange(currentIndex, candleCount)];
    
    NSNumber *maxVoTurnoverNum = [dataWillDisplayList valueForKeyPath:@"@max.voTurnover"];
    
    NSNumber *minPriceNum = [dataWillDisplayList valueForKeyPath:@"@min.low"];
    NSNumber *maxPriceNum = [dataWillDisplayList valueForKeyPath:@"@max.high"];
    
    double maxVoTurnover = [maxVoTurnoverNum doubleValue];
    double minPrice = [minPriceNum doubleValue];
    double maxPrice = [maxPriceNum doubleValue];
    
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
        CGFloat distanceToRight = (kSSCChartCandleSpace + self.candleBodyWidth) * i + self.candleBodyWidth / 2.;
        CGFloat centerX = viewSize.width - distanceToRight;
        aViewModel.candleCenterX = centerX;
        
        // MA
        NSInteger toIndex = currentIndex + i;

        aViewModel.ma5Point = [self pointForMA:5 toIndex:toIndex maxPrice:maxPrice priceScope:priceScope mainBoxheight:mainBoxheight centerX:centerX dataList:_dataList];
        aViewModel.ma10Point = [self pointForMA:10 toIndex:toIndex maxPrice:maxPrice priceScope:priceScope mainBoxheight:mainBoxheight centerX:centerX dataList:_dataList];
        aViewModel.ma20Point = [self pointForMA:20 toIndex:toIndex maxPrice:maxPrice priceScope:priceScope mainBoxheight:mainBoxheight centerX:centerX dataList:_dataList];
        
        [_viewModelList addObject:aViewModel];
    }
}

- (CGPoint)pointForMA:(NSInteger)dayCount toIndex:(NSInteger)toIndex maxPrice:(double)maxPrice priceScope:(double)priceScope mainBoxheight:(CGFloat)mainBoxheight centerX:(CGFloat)centerX dataList:(NSArray *)dataList{
    NSInteger leftCount = dataList.count - toIndex;
    NSRange range5 = NSMakeRange(toIndex, MIN(leftCount, dayCount));
    NSArray *list5 = [dataList subarrayWithRange:range5];
    NSNumber *average5Num = [list5 valueForKeyPath:@"@avg.tClose"];
    CGFloat ma5YPercent = fabs(maxPrice - average5Num.doubleValue) / priceScope;
    return CGPointMake(centerX, ma5YPercent * mainBoxheight);
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
    CGFloat hLineY_a = mainBoxheight + kSSCChartViewGap;
    CGFloat hLineY_b = rect.size.height;
    
    CGFloat marginLeft = kSSCChartViewMarginLeft;
//    CGFloat boxWidth = rect.size.width - marginLeft;
    CGFloat rightX = rect.size.width;
    
    [self buildViewData:rect.size candleWidth:_candleBodyWidth currentIndex:_currentIndex];
    
    // horizontal line
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_0) toPoint:MPOINT(rightX, hLineY_0)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_1) toPoint:MPOINT(rightX, hLineY_1)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_2) toPoint:MPOINT(rightX, hLineY_2)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_3) toPoint:MPOINT(rightX, hLineY_3)];
    
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_a) toPoint:MPOINT(rightX, hLineY_a)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_b) toPoint:MPOINT(rightX, hLineY_b)];
    
    // vertical line
    [self drawContext:context fromPoint:MPOINT(marginLeft, 0.) toPoint:MPOINT(marginLeft, hLineY_3)];
    [self drawContext:context fromPoint:MPOINT(rightX, 0.) toPoint:MPOINT(rightX, hLineY_3)];
    
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_a) toPoint:MPOINT(marginLeft, hLineY_b)];
    [self drawContext:context fromPoint:MPOINT(rightX, hLineY_a) toPoint:MPOINT(rightX, hLineY_b)];
    
    CGContextStrokePath(context);
    CGContextSetAlpha(context, 1.0);
    
    for (SSCDayViewModel *viewModel in _viewModelList) {
        CGContextSetStrokeColorWithColor(context, viewModel.color);
        
        //open & close
        CGContextSetLineWidth(context, self.candleBodyWidth);
        CGContextMoveToPoint(context, viewModel.candleCenterX,viewModel.bodyStartY);
        CGContextAddLineToPoint(context, viewModel.candleCenterX, viewModel.bodyEndY);
        
        // turnover
        CGContextMoveToPoint(context, viewModel.candleCenterX, viewModel.turnoverStartY);
        CGContextAddLineToPoint(context, viewModel.candleCenterX, viewModel.turnoverEndY);
        CGContextStrokePath(context); //改变粗细之前先绘制
        
        // high & low
        CGContextSetLineWidth(context, kSSCChartCandleLampwickWidth);
        CGContextMoveToPoint(context, viewModel.candleCenterX,viewModel.wickStartY);
        CGContextAddLineToPoint(context, viewModel.candleCenterX, viewModel.wickEndY);
        CGContextStrokePath(context);
    }
    
    CGContextStrokePath(context);
    CGContextSetAlpha(context, 1.0);
    
    // MA
    [self drawMALineContext:context type:5 color:[UIColor ssc_ma5Color]];
    [self drawMALineContext:context type:10 color:[UIColor ssc_ma10Color]];
    [self drawMALineContext:context type:20 color:[UIColor ssc_ma20Color]];
}

- (void)drawMALineContext:(CGContextRef)context type:(NSInteger)type color:(UIColor *)color{
    NSInteger count = [_viewModelList count];
    CGPoint addLines[count];
    for (NSInteger j = 0; j < count; j++) {
        SSCDayViewModel *viewModel = _viewModelList[j];
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

- (void)drawContext:(CGContextRef)context fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint{
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
}


@end
