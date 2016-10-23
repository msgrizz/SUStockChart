//
//  SSCCSVParser.m
//  SUStockChart
//
//  Created by Su Xiaozhou on 23/10/2016.
//  Copyright © 2016 SXZ. All rights reserved.
//

#import "SSCCSVParser.h"

@interface SSCCSVParser()
@property (assign) BOOL hasHeader;
@property (nonatomic, strong) NSMutableArray *fieldNameList;
@property (nonatomic, strong) NSArray *rowList;
@end

@implementation SSCCSVParser

- (instancetype)initWithCSVFilePath:(NSString *)path hasHeader:(BOOL)hasHeader
{
    self = [super init];
    if (self) {
        _hasHeader = hasHeader;
        NSString *fileObj = [NSString stringWithContentsOfFile:path
                                                      encoding:NSUTF8StringEncoding
                                                         error:nil];
        _rowList = [fileObj componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
    return self;
}

- (NSArray *)arrayOfParsedFile{
    if (self.rowList.count == 0) {
        return nil;
    }
    NSInteger rowCount = 0;
    NSMutableArray *result = [NSMutableArray new];
    for (NSString *str in _rowList) {
        NSDictionary *record;
        if (_hasHeader) {
            if (rowCount > 0) {
                record =  [self parseRowString:str];
            }
        }else{
           record = [self parseRowString:str];
        }
        if (record) {
            [result addObject:record];
        }
        rowCount++;
    }
    return result;
}

- (NSDictionary *)parseRowString:(NSString *)string{
    if (string.length == 0) {
        return nil;
    }
    NSInteger fieldCount = self.fieldNameList.count;
    NSMutableDictionary *record =
    [NSMutableDictionary dictionaryWithCapacity:fieldCount];
    NSArray *colArray = [string componentsSeparatedByString:@","];
    for (NSInteger i = 0; i < fieldCount; i++) {
        if (i > colArray.count) {
            break;
        }
        record[_fieldNameList[i]] = colArray[i];
    }
    return record;
}

- (NSMutableArray *)fieldNameList{
    if (!_fieldNameList) {
        _fieldNameList = [NSMutableArray new];
        NSString *rowString = _rowList[0];
        NSArray *colArray = [rowString componentsSeparatedByString:@","];
        if (_hasHeader) {
            _fieldNameList = [colArray mutableCopy];
        }else{
            for (NSInteger i = 0; i < colArray.count; i++) {
                [_fieldNameList addObject:@(i)];
            }
        }
    }
    return _fieldNameList;
}

@end
