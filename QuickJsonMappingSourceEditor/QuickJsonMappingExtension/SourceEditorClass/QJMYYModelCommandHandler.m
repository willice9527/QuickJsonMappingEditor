//
//  QJMYYModelCommandHandler.m
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "QJMYYModelCommandHandler.h"

@implementation QJMYYModelCommandHandler

- (void)commondDidArrivedWithInvocation:(XCSourceEditorCommandInvocation *)invocation {

}

- (void)scanWithLine:(NSString *)oriLine purifiedLine:(NSString *)purifiedLine classInfo:(QJMClassInfo *)info {

}

- (NSArray <NSString *>*)mapMethodForSourceInfo:(QJMClassInfo *)info {
  return nil;
}

- (NSString *)beginMarkStringOfGeneratedCode {
  return @"/*\t\tYYModel map method copy begin\t\t\n";
}

- (NSString *)endMarkStringOfGeneratedCode {
  return @"\t\tYYModel map method copy end\t\t*/\n";
}

@end
