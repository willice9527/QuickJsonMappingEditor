//
//  NSString+QJMUitility.h
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QJMUitility)

- (NSString *)qjm_subStringWithRegular:(NSString *)regular;

- (BOOL)qjm_isBlankNewLine;

- (BOOL)qjm_isSingleCommentLine;

- (BOOL)qjm_isMultiLinesCommentHeader;

- (BOOL)qjm_isMultiLinesCommentFooter;

- (NSString *)qjm_purify;

- (BOOL)qjm_isCategoryInterface;

- (BOOL)qjm_isCategoryImplementation;

- (NSString *)qjm_classNameFromInterfaceLine;

- (NSString *)qjm_classNameFromImplementationLine;

- (NSString *)qjm_trimdRecursiveWithCharacterInStrings:(NSArray <NSString *>*)characterStrings;

- (BOOL)qjm_isModelDeclareInterfaceLine;

@end
