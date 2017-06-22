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

@end

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
#ifdef DEBUG
  NSLog(@"all lines=%@,all buffer=%@", invocation.buffer.lines, invocation.buffer.completeBuffer);
#endif
  [self setupHandlerIfNeededWithIdentifier:invocation.commandIdentifier];
  [self.commandHandler commondDidArrivedWithInvocation:invocation];
  NSArray <QJMClassInfo *>*infoArray = [self analyzeSourceTextBuffer:invocation.buffer];
  [self generateMappingCodeWithSourceEditInfoArray:infoArray toBuffer:invocation.buffer];
  completionHandler(nil);
}

- (NSArray <QJMClassInfo *>*)analyzeSourceTextBuffer:(XCSourceTextBuffer *)buffer {
  NSMutableArray <QJMClassInfo *>*infoArray = [NSMutableArray array];
  __block QJMClassInfo *currentinfo = nil;
  __block NSUInteger impIndex = 0;
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
    if ([currentStringLine hasPrefix:Prefix_Interface]) {
      currentinfo = nil;
      if (![currentStringLine qjm_isCategoryInterface]) {
        QJMClassInfo *info = [QJMClassInfo new];
        info.modelClassName = [currentStringLine qjm_classNameFromInterfaceLine];
        [infoArray addObject:info];
      }
    } else if ([currentStringLine hasPrefix:Prefix_Property]) {
      ///@property (nonatomic, copy, readwrite) NSString *aProperty;
      QJMPropertyInfo *propertyInfo = [[QJMPropertyInfo alloc] initWithAttributeMetaStringLine:currentStringLine];
      [[infoArray lastObject].propertyInfos addObject:propertyInfo];
    } else if ([currentStringLine hasPrefix:Prefix_Implementation]) {
      ///@implementation Model
      currentinfo = nil;
      NSString *impClassName = [currentStringLine qjm_classNameFromImplementationLine];
      [infoArray enumerateObjectsUsingBlock:^(QJMClassInfo * _Nonnull innerobj, NSUInteger innerdx, BOOL * _Nonnull innterstop) {
        if ([innerobj.modelClassName isEqualToString:impClassName]) {
          currentinfo = innerobj;
          currentinfo.impIndex = impIndex;
          impIndex++;
        }
      }];
    } else if ([currentStringLine hasPrefix:Prefix_End]) {
      if (currentinfo) {
        currentinfo.impEndLine = idx;
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
                                          toBuffer:(XCSourceTextBuffer *)buffer {
  NSUInteger newLinesOffset = 0;
  for (QJMClassInfo *info in infoArray) {
    NSArray <NSString *>* jsonMapMethodLines = [self.commandHandler mapMethodForSourceInfo:info];
    [jsonMapMethodLines enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      NSUInteger index = info.impEndLine + newLinesOffset;
      [buffer.lines insertObject:obj atIndex:index];
    }];
    info.lineOffset = jsonMapMethodLines.count;
    newLinesOffset += info.lineOffset;
  }
}

- (void)setupHandlerIfNeededWithIdentifier:(NSString *)identifier {
  Class handlerClass = nil;
  if ([QJMMantleIdentifier isEqualToString:identifier]) {
    handlerClass = [QJMMantleCommandHandler class];
  } else if ([QJMYYModelIdentifier isEqualToString:identifier]) {
    handlerClass = [QJMYYModelCommandHandler class];
  } else if ([QJMTemplateIdentifier isEqualToString:identifier]) {
    handlerClass = [QJMPropertyTemplateHandler class];
  }
  NSParameterAssert(handlerClass);
  if (handlerClass && !self.commandHandler) {
    self.commandHandler = [handlerClass new];
  }
}

@end
