//
//  SSCDayViewModel.h
//  SUStockChart
//
//  Created by Su Xiaozhou on 25/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SSCDayViewModel : NSObject
@property (nonatomic, assign) CGFloat bodyStartY;
@property (nonatomic, assign) CGFloat bodyEndY;
@property (nonatomic, assign) CGFloat wickStartY;
@property (nonatomic, assign) CGFloat wickEndY;
@property (nonatomic, assign) CGFloat candleCenterX;
@property (nonatomic, assign) CGFloat turnoverStartY;
@property (nonatomic, assign) CGFloat turnoverEndY;
@property (nonatomic, assign) CGPoint ma5Point;
@property (nonatomic, assign) CGPoint ma10Point;
@property (nonatomic, assign) CGPoint ma20Point;
@property (nonatomic, assign) CGColorRef color;
@end
