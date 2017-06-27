//
//  NSString+QJMUitility.h
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *QJMNewLineWithIndentLevel(NSString *oriString, NSUInteger indentLevel);

//oh no...utility
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

- (BOOL)qjm_textContentEqualTo:(NSString *)anotherString;

+ (BOOL)qjm_isBlank:(NSString *)string;

- (BOOL)qjm_isSwiftClassDeclaration;

- (BOOL)qjm_isSwiftStructDeclaration;

- (BOOL)qjm_isMappable;

- (BOOL)qjm_isVariableDeclarationLine;

- (BOOL)qjm_isFunctionDeclarationLine;

@end
