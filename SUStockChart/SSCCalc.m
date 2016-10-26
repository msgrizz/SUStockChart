//
//  SSCCalc.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 26/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "SSCCalc.h"

@implementation SSCCalc

+ (double)ssc_maxPrice:(NSArray *)list{
    NSNumber *maxPriceNum = [list valueForKeyPath:@"@max.high"];
    return [maxPriceNum doubleValue];
}

+ (double)ssc_minPrice:(NSArray *)list{
    NSNumber *minPriceNum = [list valueForKeyPath:@"@min.low"];
    return [minPriceNum doubleValue];
}

+ (double)ssc_maxVoturnover:(NSArray *)list{
    NSNumber *maxVoTurnoverNum = [list valueForKeyPath:@"@max.voTurnover"];
    return [maxVoTurnoverNum doubleValue];
}

@end
