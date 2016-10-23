//
//  SSCDataSource.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "SSCDataSource.h"
#import "SSCCSVParser.h"

@implementation SSCDataSource

+ (void)loadData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"csv"];
    SSCCSVParser *parser = [[SSCCSVParser alloc] initWithCSVFilePath:path hasHeader:YES];
    NSArray *result = [parser arrayOfParsedFile];
    NSLog(@"x%@", result);
}
    
@end
