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
#import "SSCCalc.h"

#define MPOINT(x, y) CGPointMake(x, y)

static CGFloat const kSSCChartViewMarginLeft = 30.;
static CGFloat const kSSCChartViewGap = 9.;
static CGFloat const kSSCChartMainBoxHeightPercent = 0.7;
static CGFloat const kSSCChartCandleSpace = 1.;
static CGFloat const kSSCChartCandleLampwickWidth = 1.;
static NSString *kSSCChartIndexChangeKey = @"indexChange";

@interface SSCChartView()<UIGestureRecognizerDelegate>
@property NSInteger currentIndex; //First one from right side on chart
@property NSArray *dataList;
@property NSMutableArray *viewModelList;
@property CGFloat candleBodyWidth;

@property (nonatomic, assign) CGPoint touchStart;
@property (nonatomic, assign) CGPoint touchLast;
@property (nonatomic, assign) NSInteger indexChange;
@end

@implementation SSCChartView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        _currentIndex = 0;
        _candleBodyWidth = 7.;
        
        [self addObserver:self forKeyPath:kSSCChartIndexChangeKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        [self setupGestures];
    }
    return self;
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:kSSCChartIndexChangeKey];
}

#pragma mark - data

- (void)setContent:(NSArray *)data{
    _dataList = data;
}

#pragma mark - kvo

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:kSSCChartIndexChangeKey]) {
        id oldValue =  [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        NSInteger oldChange = [oldValue integerValue];
        NSInteger newChange = [newValue integerValue];
        if (newChange != oldChange) {
            NSInteger change = newChange - oldChange;
            _currentIndex += change;
            _currentIndex = MAX(0, _currentIndex);
            [self setNeedsDisplay];
        }
    }
}


#pragma mark - Gestures

- (void)setupGestures{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    
//    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
//    pinch.delegate = self;
//    [self addGestureRecognizer:pinch];
}

#pragma mark - Rolling

- (void)move:(UIPanGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        _touchStart = [gesture locationInView:self];
        _indexChange = 0;
    }
    else if(gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint touchPoint = [gesture locationInView:self];
        CGFloat dx = touchPoint.x - _touchStart.x;
        
        CGFloat itemWith = self.candleBodyWidth + kSSCChartCandleSpace;
        NSInteger indexChanged = dx / itemWith;
        
        [self setValue:@(indexChanged) forKey:kSSCChartIndexChangeKey];
    }
    else if(gesture.state == UIGestureRecognizerStateEnded)
    {
        _indexChange = 0;
    }
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)buildViewData:(CGSize)viewSize candleWidth:(CGFloat)candleWidth currentIndex:(NSInteger)currentIndex{

    if (currentIndex < 0) {
        return;
    }

    // make view model for chart
    CGFloat canvasWidth = viewSize.width - kSSCChartViewMarginLeft;
    CGFloat mainBoxheight = viewSize.height * kSSCChartMainBoxHeightPercent;
    CGFloat subBoxHeight = viewSize.height - mainBoxheight - kSSCChartViewGap;
    NSUInteger candleCount = canvasWidth / (candleWidth + kSSCChartCandleSpace);
    
    candleCount = MIN(candleCount, (_dataList.count - currentIndex));
    _viewModelList = [[NSMutableArray alloc] initWithCapacity:candleCount];
    
    // data will display
    NSArray *dataWillDisplayList = [_dataList subarrayWithRange:NSMakeRange(currentIndex, candleCount)];
    
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

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    [[UIColor ssc_backgroundColor] setFill];
    UIRectFill(rect);
    
    // Gridding
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
//    CGFloat boxWidth = rect.size.width - marginLeft;
    CGFloat rightX = rect.size.width;
    
    [self buildViewData:rect.size candleWidth:_candleBodyWidth currentIndex:_currentIndex];
    
    // horizontal line
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_0) toPoint:MPOINT(rightX, hLineY_0)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_1) toPoint:MPOINT(rightX, hLineY_1)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_2) toPoint:MPOINT(rightX, hLineY_2)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_3) toPoint:MPOINT(rightX, hLineY_3)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_4) toPoint:MPOINT(rightX, hLineY_4)];
    
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_a) toPoint:MPOINT(rightX, hLineY_a)];
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_b) toPoint:MPOINT(rightX, hLineY_b)];
    
    // vertical line
    [self drawContext:context fromPoint:MPOINT(marginLeft, 0.) toPoint:MPOINT(marginLeft, mainBoxheight)];
    [self drawContext:context fromPoint:MPOINT(rightX, 0.) toPoint:MPOINT(rightX, mainBoxheight)];
    
    [self drawContext:context fromPoint:MPOINT(marginLeft, hLineY_a) toPoint:MPOINT(marginLeft, hLineY_b)];
    [self drawContext:context fromPoint:MPOINT(rightX, hLineY_a) toPoint:MPOINT(rightX, hLineY_b)];
    
    CGContextStrokePath(context);
    CGContextSetAlpha(context, 1.0);
    
    // Text
    NSArray *dataDisplayList = [_dataList subarrayWithRange:NSMakeRange(_currentIndex, _viewModelList.count)];

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
    
    CGRect rectA0 = CGRectMake(0., 0., marginLeft - 5., 8.);
    CGRect rectA1 = CGRectMake(0., hLineY_1-8, marginLeft - 5., 8.);
    CGRect rectA2 = CGRectMake(0., hLineY_2-8, marginLeft - 5., 8.);
    CGRect rectA3 = CGRectMake(0., hLineY_3-8, marginLeft - 5., 8.);
    CGRect rectA4 = CGRectMake(0., hLineY_4-8, marginLeft - 5., 8.);
    
    [textA0 drawInRect:rectA0 withAttributes:attr];
    [textA1 drawInRect:rectA1 withAttributes:attr];
    [textA2 drawInRect:rectA2 withAttributes:attr];
    [textA3 drawInRect:rectA3 withAttributes:attr];
    [textA4 drawInRect:rectA4 withAttributes:attr];
    
    CGRect rectB0 = CGRectMake(0., hLineY_a, marginLeft - 5., 8.);
    CGRect rectB1 = CGRectMake(0., rect.size.height - 10., marginLeft - 5., 8.);
    
    NSString *textB0 = [NSString stringWithFormat:@"%.2f万", maxVoTurnover / 10000 / 100];
    NSString *textB1 = [NSString stringWithFormat:@"万手"];
    [textB0 drawInRect:rectB0 withAttributes:attr];
    [textB1 drawInRect:rectB1 withAttributes:attr];
    
    // Candle
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
    NSMutableArray *lineArray = [[NSMutableArray alloc] initWithCapacity:_viewModelList.count];
    for (SSCDayViewModel *viewModel in _viewModelList) {
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
