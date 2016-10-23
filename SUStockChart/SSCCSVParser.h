//
//  SSCCSVParser.h
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSCCSVParser : NSObject
- (instancetype)initWithCSVFilePath:(NSString *)path hasHeader:(BOOL)hasHeader;
- (NSArray *)arrayOfParsedFile;
@end
