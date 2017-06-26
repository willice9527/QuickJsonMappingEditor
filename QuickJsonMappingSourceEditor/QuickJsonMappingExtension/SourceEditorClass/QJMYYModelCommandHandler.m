//
//  QJMYYModelCommandHandler.m
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "QJMYYModelCommandHandler.h"
#import "QJMPreDefinition.h"
#import "NSString+QJMUitility.h"

@interface QJMYYModelCommandHandler ()

@property (nonatomic, assign) BOOL blackListEnable;
@property (nonatomic, assign) BOOL whiteListEnable;
@property (nonatomic, assign) BOOL copyEnable;
@property (nonatomic, assign) BOOL compareEnable;
@property (nonatomic, copy) NSArray <NSString *>*selfDefinedClassRegulars;
@property (nonatomic, copy) NSArray <NSString *>*customeTransformerClasses;

@end

@implementation QJMYYModelCommandHandler

- (instancetype)init {
  self = [super init];
  if (self) {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"YYModelPreference" ofType:@"plist"];
    NSParameterAssert(path);
    if (path) {
      NSDictionary *configInfo = [NSDictionary dictionaryWithContentsOfFile:path];
      _selfDefinedClassRegulars = [configInfo[@"SelfDefinedClassRegular"] copy];
      _customeTransformerClasses = [configInfo[@"JsonToModelCustomTransformClass"] copy];
    }
  }
  return self;
}

- (void)commondDidArrivedWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
  self.blackListEnable = NO;
  self.whiteListEnable = NO;
  self.copyEnable = NO;
  self.compareEnable = NO;
}

- (void)scanWithLine:(NSString *)oriLine purifiedLine:(NSString *)purifiedLine classInfo:(QJMClassInfo *)info {
  if ([purifiedLine localizedCaseInsensitiveContainsString:QJMYYModelEnablePropertyBlackList]) {
    self.blackListEnable = YES;
  } else if ([purifiedLine localizedCaseInsensitiveContainsString:QJMYYModelEnablePropertyWhiteList]) {
    self.whiteListEnable = NO;
  } else if ([purifiedLine localizedCaseInsensitiveContainsString:QJMYYModelEnableCopy]) {
    self.copyEnable = NO;
  } else if ([purifiedLine localizedCaseInsensitiveContainsString:QJMYYModelEnableCompare]) {
    self.compareEnable = NO;
  }
}

- (NSArray <NSString *>*)mapMethodForSourceInfo:(QJMClassInfo *)info {
  return nil;
}

- (NSString *)beginMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(@"/*\t\tYYModel map method copy begin\t\t", 0);
}

- (NSString *)endMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(@"YYModel map method copy end\t\t*/", 2);
}

@end
