//
//  SSCDataSource.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "SSCDataSource.h"
#import "SSCCSVParser.h"
#import "SSCDayModel.h"

@implementation SSCDataSource

+ (NSArray *)loadData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"csv"];
    SSCCSVParser *parser = [[SSCCSVParser alloc] initWithCSVFilePath:path hasHeader:YES];
    NSArray *result = [parser arrayOfParsedFile];
    NSMutableArray *modelList = [[NSMutableArray alloc] initWithCapacity:result.count];
    for (NSDictionary *record in result) {
        SSCDayModel *dayModel = [SSCDayModel new];
        dayModel.dateStr = record[@"date_str"];
        dayModel.tClose = [record[@"tclose"] doubleValue];
        dayModel.high = [record[@"high"] doubleValue];
        dayModel.low = [record[@"low"] doubleValue];
        dayModel.tOpen = [record[@"topen"] doubleValue];
        dayModel.change = [record[@"change"] doubleValue];
        dayModel.pChange = [record[@"pchange"] doubleValue];
        dayModel.turnover = [record[@"turnover"] doubleValue];
        dayModel.voTurnover = [record[@"voturnover"] doubleValue];
        
        // escape closed day
        if (dayModel.tOpen > 0.) {
            [modelList addObject:dayModel];
        }
    }
    return modelList;
}
    
@end
