//
//  NSString+QJMUitility.m
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "NSString+QJMUitility.h"

static NSString *const QJMSingleLineCommentPrefix = @"//";
static NSString *const QJMMultiLinesCommentPrefix = @"/*";
static NSString *const QJMMultiLinesCommentSuffix = @"*/";
static NSString *const QJMClangAttributeMark = @"__attribute__";
static NSString *const QJMCategoryNamePartRegular = @"\\(.*?\\)";//()及中间的部分
static NSString *const QJMInterfaceClassNamePartRegular = @"(?<=@interface)\\s*\\w+\\b";// @interface 后面的第一个单词
static NSString *const QJMImplementationClassNamePartRegular = @"(?<=@implementation)\\s*\\w+\\b";// @implementation 后面的第一个单词

static NSCharacterSet *QJMSpaceAndNewLineSet = nil;

static inline NSString *QJMTrimedLine(NSString *oriString) {
  if (!QJMSpaceAndNewLineSet) {
    QJMSpaceAndNewLineSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  }
  return [oriString stringByTrimmingCharactersInSet:QJMSpaceAndNewLineSet];
}

@implementation NSString (QJMUitility)

- (NSString *)qjm_subStringWithRegular:(NSString *)regular {
  NSParameterAssert(regular);
  NSRange range = [self rangeOfString:regular options:NSRegularExpressionSearch];
  if (range.location != NSNotFound) {
    return [QJMTrimedLine([self substringWithRange:range]) copy];
  }
  return nil;
}

- (BOOL)qjm_isBlankNewLine {
  return QJMTrimedLine(self).length <= 0;
}

- (BOOL)qjm_isSingleCommentLine {
  NSString *trimedSelf = QJMTrimedLine(self);
  BOOL isSingleLineComment = NO;
  if ([trimedSelf hasPrefix:QJMSingleLineCommentPrefix]) {
    isSingleLineComment = YES;
  } else if ([trimedSelf hasPrefix:QJMMultiLinesCommentPrefix] && [trimedSelf hasSuffix:QJMMultiLinesCommentSuffix]) {
    isSingleLineComment = YES;
  }
  return isSingleLineComment;
}

- (BOOL)qjm_isMultiLinesCommentHeader {
  return [QJMTrimedLine(self) hasPrefix:QJMMultiLinesCommentPrefix];
}

- (BOOL)qjm_isMultiLinesCommentFooter {
  return [QJMTrimedLine(self) hasSuffix:QJMMultiLinesCommentSuffix];
}

- (NSString *)qjm_purify {
  //trim blankspace & newline mark & comment
  NSString *purifiedString = QJMTrimedLine(self);
  NSRange doubleSlashRange = [purifiedString rangeOfString:QJMSingleLineCommentPrefix];
  NSRange slashMarkRange = [purifiedString rangeOfString:QJMMultiLinesCommentPrefix];
  NSRange targetRange = doubleSlashRange.location == NSNotFound ? slashMarkRange : doubleSlashRange;
  if (doubleSlashRange.location != NSNotFound &&
      slashMarkRange.location != NSNotFound) {
    targetRange = doubleSlashRange.location < slashMarkRange.location ? doubleSlashRange : slashMarkRange;
  }
  if (targetRange.location != NSNotFound) {
    purifiedString = [purifiedString substringToIndex:targetRange.location];
  }
  //__attribute__  part remove
  targetRange = [purifiedString rangeOfString:QJMClangAttributeMark];
  if (targetRange.location != NSNotFound) {
    purifiedString = [purifiedString substringToIndex:targetRange.location];
    purifiedString = [purifiedString stringByAppendingString:@";"];
  }
  return purifiedString;
}

- (BOOL)qjm_isCategoryInterface {
  NSString *categoryNamePart = [self qjm_subStringWithRegular:QJMCategoryNamePartRegular];
  categoryNamePart = [categoryNamePart qjm_trimdRecursiveWithCharacterInStrings:@[ @"()"]];
  return categoryNamePart.length > 0;
}

- (BOOL)qjm_isCategoryImplementation {
  NSString *categoryNamePart = [self qjm_subStringWithRegular:QJMCategoryNamePartRegular];
  categoryNamePart = [categoryNamePart qjm_trimdRecursiveWithCharacterInStrings:@[ @"()"]];
  return categoryNamePart.length > 0;
}

- (NSString *)qjm_classNameFromInterfaceLine {
  return [self qjm_subStringWithRegular:QJMInterfaceClassNamePartRegular];
}

- (NSString *)qjm_classNameFromImplementationLine {
  return [self qjm_subStringWithRegular:QJMImplementationClassNamePartRegular];
}

- (NSString *)qjm_trimdRecursiveWithCharacterInStrings:(NSArray <NSString *>*)characterStrings {
  __block NSString *trimedString = QJMTrimedLine(self);
  [characterStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    trimedString = [trimedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:obj]];
  }];
  return QJMTrimedLine(trimedString);
}

@end
