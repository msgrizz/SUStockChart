//
//  SSCDayModel.h
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCDayModel : NSObject

@property NSString *dateStr;
@property double tClose;
@property double high;
@property double low;
@property double tOpen;
@property double lClose;
@property double change;
@property double pChange;
@property double turnover;
@property double voTurnover;

@end
