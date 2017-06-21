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
  return nil;
}

- (void)generateMappingCodeWithSourceEditInfoArray:(NSArray <QJMClassInfo *>*)infoArray
                                          toBuffer:(XCSourceTextBuffer *)buffer {
  
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
