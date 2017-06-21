//
//  NSString+QJMUitility.m
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "NSString+QJMUitility.h"

@implementation NSString (QJMUitility)

- (NSString *)qjm_subStringWithRegular:(NSString *)regular {
  NSParameterAssert(regular);
  NSRange range = [self rangeOfString:regular options:NSRegularExpressionSearch];
  if (range.location != NSNotFound) {
    NSCharacterSet *blankSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [[[self substringWithRange:range] stringByTrimmingCharactersInSet:blankSet] copy];
  }
  return nil;
}

@end
