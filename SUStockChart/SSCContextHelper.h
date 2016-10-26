//
//  SSCContextHelper.h
//  SUStockChart
//
//  Created by Su Xiaozhou on 26/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SSCConstaints.h"
#import "SSCCalc.h"
#import "SSCDayModel.h"
#import "SSCDayViewModel.h"
#import "UIColor+SSCColorStyle.h"

@interface SSCContextHelper : NSObject

+ (NSArray *)viewModelListFromRawData:(NSArray *)dataList viewSize:(CGSize)viewSize candleWidth:(CGFloat)candleWidth currentIndex:(NSInteger)currentIndex;

@end
