//
//  NSArray+QJMUtility.m
//  QuickJsonMappingSourceEditor
//
//  Created by 刘金林 on 2017/6/23.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "NSArray+QJMUtility.h"
#import "NSString+QJMUitility.h"

@implementation NSArray (QJMUtility)

- (NSArray *)qjm_filterWithHandler:(QJMFilterHandler)handler {
  if (!handler) {
    return [self copy];
  }
  NSMutableArray *mArray = [NSMutableArray array];
  [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (handler(obj)) {
      [mArray addObject:obj];
    }
  }];
  return [mArray copy];
}

@end

@implementation NSMutableArray (QJMUtility)

- (void)qjm_prefixPragmaMarkWithContent:(NSString *)markContent {
  [self addObject:QJMNewLineWithIndentLevel(nil, 0)];
  [self addObject:QJMNewLineWithIndentLevel(markContent, 0)];
  [self addObject:QJMNewLineWithIndentLevel(nil, 0)];
}

@end
