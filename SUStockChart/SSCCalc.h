//
//  SSCCalc.h
//  SUStockChart
//
//  Created by Su Xiaozhou on 26/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCCalc : NSObject
+ (double)ssc_maxPrice:(NSArray *)list;
+ (double)ssc_minPrice:(NSArray *)list;
+ (double)ssc_maxVoturnover:(NSArray *)list;
@end
