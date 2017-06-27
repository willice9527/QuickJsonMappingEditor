//
//  SourceEditorCommand.m
//  QuickJsonMappingSourceEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "SourceEditorCommand.h"
#import "QJMPreDefinition.h"
#import "QJMCommandHandleProtocol.h"
#import "QJMMantleCommandHandler.h"
#import "QJMYYModelCommandHandler.h"
#import "QJMObjectMapperCommandHandler.h"
#import "QJMClassInfo.h"
#import "NSString+QJMUitility.h"
#import "QJMCommandHandleError.h"

@interface SourceEditorCommand ()

@property (nonatomic, strong) id<QJMCommandHandleProtocol> commandHandler;
@property (nonatomic, assign) BOOL isSwiftCode;

@end

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
#ifdef DEBUG
  NSLog(@"all lines=%@,all buffer=%@", invocation.buffer.lines, invocation.buffer.completeBuffer);
#endif
  NSError *commandHandleError = nil;
  [self setupHandlerIfNeededWithInvocation:invocation error:&commandHandleError];
  if (commandHandleError) {
    completionHandler(commandHandleError);
    return;
  }
  
  [self.commandHandler commondDidArrivedWithInvocation:invocation];
  [self clearPreGeneratedCodeInSourceTextBuffer:invocation.buffer];
  NSArray <QJMClassInfo *>*infoArray = [self analyzeSourceTextBuffer:invocation.buffer error:&commandHandleError];
  if (commandHandleError) {
    completionHandler(commandHandleError);
    return;
  }
  
  [self generateMappingCodeWithSourceEditInfoArray:infoArray toBuffer:invocation.buffer error:&commandHandleError];
  completionHandler(commandHandleError);
}

- (void)clearPreGeneratedCodeInSourceTextBuffer:(XCSourceTextBuffer *)buffer {
  BOOL enterDeleteArea = NO;
  for (NSInteger i = buffer.lines.count - 1; i >= 0; i--) {
    NSString *currentLine = buffer.lines[i];
    BOOL shouldDeleteCurrentLine = NO;
    if ([currentLine qjm_textContentEqualTo:[self.commandHandler endMarkStringOfGeneratedCode]]) {
      shouldDeleteCurrentLine = YES;
      enterDeleteArea = YES;
    } else if ([currentLine qjm_textContentEqualTo:[self.commandHandler beginMarkStringOfGeneratedCode]]) {
      if (enterDeleteArea) {
        enterDeleteArea = NO;
      }
      shouldDeleteCurrentLine = YES;
    } else {
      if (enterDeleteArea && [currentLine hasPrefix:Prefix_End]) {
        enterDeleteArea = NO;
      }
      shouldDeleteCurrentLine = enterDeleteArea;
    }
    if (shouldDeleteCurrentLine) {
      [buffer.lines removeObjectAtIndex:i];
    }
  }
}

- (NSArray <QJMClassInfo *>*)analyzeSourceTextBuffer:(XCSourceTextBuffer *)buffer error:(NSError **)error {
  NSMutableArray <QJMClassInfo *>*infoArray = [NSMutableArray array];
  __block QJMClassInfo *currentinfo = nil;
  __block BOOL inComment = NO;
  [buffer.lines enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([obj qjm_isBlankNewLine] || [obj qjm_isSingleCommentLine]) {
      return ;
    }
    if ([obj qjm_isMultiLinesCommentHeader]) {
      inComment = YES;
      return;
    }
    if ([obj qjm_isMultiLinesCommentFooter]) {
      inComment = NO;
      return;
    }
    if (inComment) {
      return ;
    }
    NSString *currentStringLine = [obj qjm_purify];
    if (self.isSwiftCode) {
      if ([currentStringLine qjm_isSwiftClassDeclaration] || [currentStringLine qjm_isSwiftStructDeclaration]) {
        if ([currentStringLine qjm_isMappable]) {
          QJMClassInfo *info = [QJMClassInfo new];
          info.modelClassName = [currentStringLine qjm_classNameFromInterfaceLine];
          [infoArray addObject:info];
          currentinfo = info;
        } else {
          currentinfo = nil;
        }
      } else if ([currentStringLine qjm_isVariableDeclarationLine]) {
        if (currentinfo) {
          QJMPropertyInfo *propertyInfo = [[QJMPropertyInfo alloc] initWithAttributeSwiftMetaStringLine:currentStringLine];
          if (!propertyInfo.isReadOnly && !propertyInfo.isClassProperty) {
            [currentinfo.propertyInfos addObject:propertyInfo];
          }
        }
      } else if ([currentStringLine qjm_isFunctionDeclarationLine]) {
        currentinfo = nil;
      }
    } else {
      if ([currentStringLine hasPrefix:Prefix_Interface] && [currentStringLine qjm_isModelDeclareInterfaceLine]) {
        QJMClassInfo *info = [QJMClassInfo new];
        info.modelClassName = [currentStringLine qjm_classNameFromInterfaceLine];
        [infoArray addObject:info];
        currentinfo = info;
      } else if ([currentStringLine hasPrefix:Prefix_Property]) {
        ///@property (nonatomic, copy, readwrite) NSString *aProperty;
        if (currentinfo) {
          QJMPropertyInfo *propertyInfo = [[QJMPropertyInfo alloc] initWithAttributeMetaStringLine:currentStringLine];
          if (!propertyInfo.isReadOnly && !propertyInfo.isClassProperty) {
            [currentinfo.propertyInfos addObject:propertyInfo];
          }
        }
      } else if ([currentStringLine hasPrefix:Prefix_End]) {
        if (currentinfo) {
          currentinfo.interfaceEndLine = idx + 1;
          currentinfo = nil;
        }
      }
    }
    [self.commandHandler scanWithLine:obj purifiedLine:currentStringLine classInfo:currentinfo];
  }];
  return infoArray;
}

- (void)analyzeLine:(NSString *)currentStringLine classInfos:(NSMutableArray *)infoArray currentInfo:(QJMClassInfo *)currentinfo  lineIndex:(NSUInteger)idx {
  
}

- (void)generateMappingCodeWithSourceEditInfoArray:(NSArray <QJMClassInfo *>*)infoArray
                                          toBuffer:(XCSourceTextBuffer *)buffer
                                             error:(NSError **)error {
  NSUInteger newLinesOffset = 0;
  for (QJMClassInfo *info in infoArray) {
    NSArray <NSString *>* jsonMapMethodLines = [self.commandHandler mapMethodForSourceInfo:info];
    
    [jsonMapMethodLines enumerateObjectsWithOptions:self.isSwiftCode ? 0 :NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      NSUInteger index = info.interfaceEndLine + newLinesOffset;
      if (self.isSwiftCode) {
        [buffer.lines addObject:obj];
      } else {
        [buffer.lines insertObject:obj atIndex:index];
      }
    }];
    newLinesOffset += jsonMapMethodLines.count;
  }
}

- (void)setupHandlerIfNeededWithInvocation:(XCSourceEditorCommandInvocation *)invocation error:(NSError **)error {
  NSString *contentUTI = invocation.buffer.contentUTI;
  if (![QJMPreDefinition.supportedFileTypes containsObject:contentUTI]) {
    *error = [QJMCommandHandleError sourceFileTypeError];
    return;
  }
  NSString *identifier = invocation.commandIdentifier;
  if ([contentUTI isEqualToString:QJMSupportFileTypeSwiftSource]) {
    if (![QJMPreDefinition.swiftSupportedCommands containsObject:identifier]) {
      *error = [QJMCommandHandleError sourceCommandTypeError];
      return;
    }
    self.isSwiftCode = YES;
  } else {
    if (![QJMPreDefinition.OCSupportedCommands containsObject:identifier]) {
      *error = [QJMCommandHandleError sourceCommandTypeError];
      return;
    }
    self.isSwiftCode = NO;
  }
  Class handlerClass = nil;
  if ([QJMMantleIdentifier isEqualToString:identifier]) {
    handlerClass = [QJMMantleCommandHandler class];
  } else if ([QJMYYModelIdentifier isEqualToString:identifier]) {
    handlerClass = [QJMYYModelCommandHandler class];
  } else if ([QJMObjectMapperIdentifier isEqualToString:identifier]) {
    handlerClass = [QJMObjectMapperCommandHandler class];
  }
  //jsonmodel /object mapper
  NSParameterAssert(handlerClass);
  if (handlerClass && !self.commandHandler) {
    self.commandHandler = [handlerClass new];
  }
}

@end
