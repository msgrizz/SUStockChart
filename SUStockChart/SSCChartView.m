//
//  SSCChartView.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "SSCChartView.h"
#import "SSCContextHelper.h"

@interface SSCChartView()<UIGestureRecognizerDelegate>
@property NSInteger currentIndex; //First one from right side on chart
@property NSArray *dataList;
@property NSArray *viewModelList;
@property CGFloat candleBodyWidth;

@property (nonatomic, strong) UILabel *hiLabel;

@property (nonatomic, assign) CGPoint touchStart;
@property (nonatomic, assign) CGPoint touchLast;
@property (nonatomic, assign) NSInteger indexChange;
@property (nonatomic, assign) NSInteger indexSelected;
@end

@implementation SSCChartView

#pragma mark - life circle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        _currentIndex = 0;
        _indexSelected = -1;
        _candleBodyWidth = 7.;
        
        [self addSubview:self.hiLabel];
        
        [self setupObserver];
        [self setupGestures];
    }
    return self;
}

- (void)dealloc{
    [self destroyObserver];
}

#pragma mark - data

- (void)setContent:(NSArray *)data{
    _dataList = data;
    [self setNeedsDisplay];
}

#pragma mark - Gestures

- (void)setupGestures{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    pan.delegate = self;
    [self addGestureRecognizer:pan];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = .3;
    [self addGestureRecognizer:longPress];

}

#pragma mark - select day

-  (void)handleLongPress:(UILongPressGestureRecognizer*)gestureRecognizer {
    CGPoint coords = [gestureRecognizer locationInView:self];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setValue:@(-1) forKey:kSSCChartIndexSelectedKey];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        _indexSelected = -1;
        [self checkSelectedTime:coords];
    }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged){
        [self checkSelectedTime:coords];
    }
}

- (void)checkSelectedTime:(CGPoint)touchPoint{
    NSInteger arrayCount = _viewModelList.count;
    CGFloat nodeWidth = (self.frame.size.width - kSSCChartViewMarginLeft) / arrayCount;
    NSInteger tmp = (touchPoint.x - kSSCChartViewMarginLeft) / nodeWidth + 0.5;
    NSInteger indexSelected = arrayCount - tmp;
    indexSelected = MAX(0, indexSelected);
    indexSelected = MIN(indexSelected, _viewModelList.count - 1);
    [self setValue:@(indexSelected) forKey:kSSCChartIndexSelectedKey];
    [self processSelectedIndex:indexSelected];
}

- (void)processSelectedIndex:(NSInteger)selectedIndex{
    SSCDayViewModel *viewModel = _viewModelList[selectedIndex];
    NSInteger dataIndex = selectedIndex + _currentIndex;
    dataIndex = MAX(0, dataIndex);
    dataIndex = MIN((_dataList.count - 1), dataIndex);
    SSCDayModel *dayModel = _dataList[dataIndex];
    
    CGRect frame = CGRectMake(-1., viewModel.bodyEndY - 6., kSSCChartViewMarginLeft, 12);
    _hiLabel.frame = frame;
    _hiLabel.text = [NSString stringWithFormat:@"%.2f", dayModel.tClose];
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
    if ([keyPath isEqualToString:kSSCChartIndexSelectedKey]) {
        id oldValue =  [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        NSInteger oldChange = [oldValue integerValue];
        NSInteger newChange = [newValue integerValue];
        if (newChange != oldChange) {
            [self setNeedsDisplay];
        }
    }
}

#pragma mark - Observe

- (void)setupObserver{
    [self addObserver:self forKeyPath:kSSCChartIndexChangeKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:kSSCChartIndexSelectedKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)destroyObserver{
    [self removeObserver:self forKeyPath:kSSCChartIndexChangeKey];
    [self removeObserver:self forKeyPath:kSSCChartIndexSelectedKey];
}

#pragma mark - Rolling

- (void)move:(UIPanGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan){
        _touchStart = [gesture locationInView:self];
        _indexChange = 0;
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        CGPoint touchPoint = [gesture locationInView:self];
        CGFloat dx = touchPoint.x - _touchStart.x;
        
        CGFloat itemWith = self.candleBodyWidth + kSSCChartCandleSpace;
        NSInteger indexChanged = dx / itemWith;
        
        [self setValue:@(indexChanged) forKey:kSSCChartIndexChangeKey];
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        _indexChange = 0;
    }
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    _viewModelList = [SSCContextHelper viewModelListFromRawData:_dataList viewSize:rect.size candleWidth:_candleBodyWidth currentIndex:_currentIndex];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    [[UIColor ssc_backgroundColor] setFill];
    UIRectFill(rect);
    
    // Gridding
    [SSCContextHelper gridContext:context rect:rect];
    
    // Text
    NSArray *dataDisplayList = [_dataList subarrayWithRange:NSMakeRange(_currentIndex, _viewModelList.count)];
    [SSCContextHelper textContext:context dataDisplayList:dataDisplayList rect:rect];
    
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
    [SSCContextHelper maLineContext:context type:5 color:[UIColor ssc_ma5Color] viewModelList:_viewModelList];
    [SSCContextHelper maLineContext:context type:10 color:[UIColor ssc_ma10Color] viewModelList:_viewModelList];
    [SSCContextHelper maLineContext:context type:20 color:[UIColor ssc_ma20Color] viewModelList:_viewModelList];
    
    // select
    if (_indexSelected >= 0) {
        SSCDayViewModel *viewModel = _viewModelList[_indexSelected];
        
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 1.0f);
        CGContextSetAlpha(context, .5);
        
        CGPoint top = CGPointMake(viewModel.candleCenterX, 0.);
        CGPoint bottom = CGPointMake(viewModel.candleCenterX, rect.size.height);
        CGPoint left = CGPointMake(kSSCChartViewMarginLeft, viewModel.bodyEndY);
        CGPoint right = CGPointMake(rect.size.width, viewModel.bodyEndY);
        [SSCContextHelper drawContext:context fromPoint:top toPoint:bottom];
        [SSCContextHelper drawContext:context fromPoint:left toPoint:right];
        
        CGContextStrokePath(context);
    }
    _hiLabel.hidden = !(_indexSelected >= 0);
}

#pragma mark - Properties

- (UILabel *)hiLabel{
    if (!_hiLabel) {
        _hiLabel = [UILabel new];
        _hiLabel.font = [UIFont systemFontOfSize:10.];
        _hiLabel.textColor = [UIColor whiteColor];
        _hiLabel.backgroundColor = [UIColor blackColor];
        _hiLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _hiLabel;
}

@end
