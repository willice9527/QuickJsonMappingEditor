//
//  QJMObjectMapperCommandHandler.m
//  QuickJsonMappingSourceEditor
//
//  Created by 刘金林 on 2017/6/26.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "QJMObjectMapperCommandHandler.h"
#import "QJMClassInfo.h"
#import "QJMPreDefinition.h"
#import "NSString+QJMUitility.h"
#import "NSArray+QJMUtility.h"

@interface QJMObjectMapperCommandHandler ()

@property (nonatomic, copy) NSArray <NSString *>*selfDefinedClassRegulars;
@property (nonatomic, copy) NSDictionary <NSString *, NSString *>*defaultTransformerMap;

@end

@implementation QJMObjectMapperCommandHandler

- (instancetype)init {
  self = [super init];
  if (self) {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ObjectMapperPreference" ofType:@"plist"];
    NSParameterAssert(path);
    if (path) {
      NSDictionary *configInfo = [NSDictionary dictionaryWithContentsOfFile:path];
      _selfDefinedClassRegulars = [configInfo[@"SelfDefinedClassRegular"] copy];
      _defaultTransformerMap = [configInfo[@"DefaultTransformerMap"] copy];
    }
  }
  return self;
}

- (BOOL)isSelfDefinedClass:(NSString *)className {
  if (!className) {
    return NO;
  }
  for (NSString *regular in self.selfDefinedClassRegulars) {
    NSRange range = [className rangeOfString:regular options:NSRegularExpressionSearch];
    if (range.location != NSNotFound && range.length == className.length) {
      return YES;
    }
  }
  return NO;
}

- (NSString *)defaultTransformerNameForClass:(NSString *)className {
  NSParameterAssert(className);
  return self.defaultTransformerMap[className];
}

#pragma mark - QJMCommandHandleProtocol

- (void)commondDidArrivedWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
  
}

- (void)scanWithLine:(NSString *)oriLine purifiedLine:(NSString *)purifiedLine classInfo:(QJMClassInfo *)info {
  if ([purifiedLine localizedCaseInsensitiveContainsString:KeypathCodeingEnable]) {
    
  } else if ([purifiedLine localizedCaseInsensitiveContainsString:KeypathCodeingDisable]) {
    
  }
}

- (NSArray <NSString *>*)mapMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* jsonMapMethods = [NSMutableArray array];
  if (!info.propertyInfos.count) {
    return jsonMapMethods;
  }
//  NSArray *keypathMethods = [self keypathForSourceInfo:info];
//  NSArray *transformerMethods = [self customerTransformerForSourceInfo:info];
//  if (keypathMethods.count) {
//    [jsonMapMethods qjm_prefixPragmaMarkWithContent:@"#pragma mark - mantle keypath map"];
//    [jsonMapMethods addObjectsFromArray:keypathMethods];
//    if (!transformerMethods.count) {
//      [jsonMapMethods addObject:QJMNewLineWithIndentLevel(nil, 0)];
//    }
//  }
//  if (transformerMethods.count) {
//    [jsonMapMethods qjm_prefixPragmaMarkWithContent:@"#pragma mark - mantle custom class / predefined transformer"];
//    [jsonMapMethods addObjectsFromArray:transformerMethods];
//  }
//  if (jsonMapMethods.count) {
//    [jsonMapMethods insertObject:[self beginMarkStringOfGeneratedCode] atIndex:0];
//    [jsonMapMethods addObject:[self endMarkStringOfGeneratedCode]];
//  }
  return jsonMapMethods;
}

- (NSString *)beginMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(nil, 0);
}

- (NSString *)endMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(nil, 2);
}

@end
