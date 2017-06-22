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
#import "QJMPropertyTemplateHandler.h"
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
  
  NSArray <QJMClassInfo *>*infoArray = [self analyzeSourceTextBuffer:invocation.buffer error:&commandHandleError];
  if (commandHandleError) {
    completionHandler(commandHandleError);
    return;
  }
  
  [self generateMappingCodeWithSourceEditInfoArray:infoArray toBuffer:invocation.buffer error:&commandHandleError];
  completionHandler(commandHandleError);
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
    if ([currentStringLine hasPrefix:Prefix_Interface] && [currentStringLine qjm_isModelDeclareInterfaceLine]) {
      QJMClassInfo *info = [QJMClassInfo new];
      info.modelClassName = [currentStringLine qjm_classNameFromInterfaceLine];
      [infoArray addObject:info];
      currentinfo = info;
    } else if ([currentStringLine hasPrefix:Prefix_Property]) {
      ///@property (nonatomic, copy, readwrite) NSString *aProperty;
      if (currentinfo) {
        QJMPropertyInfo *propertyInfo = [[QJMPropertyInfo alloc] initWithAttributeMetaStringLine:currentStringLine];
        [currentinfo.propertyInfos addObject:propertyInfo];
      }
    } else if ([currentStringLine hasPrefix:Prefix_End]) {
      if (currentinfo) {
        currentinfo.interfaceEndLine = idx + 1;
        currentinfo = nil;
      }
    }
    [self.commandHandler scanWithLine:obj purifiedLine:currentStringLine classInfo:currentinfo];
  }];
  [infoArray sortUsingComparator:^NSComparisonResult(QJMClassInfo * _Nonnull obj1, QJMClassInfo * _Nonnull obj2) {
    if (obj1.impIndex <= obj2.impIndex) {
      return NSOrderedAscending;
    } else return NSOrderedDescending;
  }];
  return infoArray;
}

- (void)generateMappingCodeWithSourceEditInfoArray:(NSArray <QJMClassInfo *>*)infoArray
                                          toBuffer:(XCSourceTextBuffer *)buffer
                                             error:(NSError **)error {
  NSUInteger newLinesOffset = 0;
  for (QJMClassInfo *info in infoArray) {
    NSArray <NSString *>* jsonMapMethodLines = [self.commandHandler mapMethodForSourceInfo:info];
    [jsonMapMethodLines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      NSUInteger index = info.interfaceEndLine + newLinesOffset;
      [buffer.lines insertObject:obj atIndex:index];
    }];
    info.lineOffset = jsonMapMethodLines.count;
    newLinesOffset += info.lineOffset;
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
  } else if ([QJMTemplateIdentifier isEqualToString:identifier]) {
    handlerClass = [QJMPropertyTemplateHandler class];
  }
  //jsonmodel /object mapper
  NSParameterAssert(handlerClass);
  if (handlerClass && !self.commandHandler) {
    self.commandHandler = [handlerClass new];
  }
}

@end
