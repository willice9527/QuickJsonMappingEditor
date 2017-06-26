//
//  QJMMantleCommandHandler.m
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "QJMMantleCommandHandler.h"
#import "QJMClassInfo.h"
#import "QJMPreDefinition.h"
#import "NSString+QJMUitility.h"
#import "NSArray+QJMUtility.h"

@interface QJMMantleCommandHandler ()

@property (nonatomic, assign) BOOL enableKPCGlobal;
@property (nonatomic, assign) BOOL enableKPCCurrentPage;
@property (nonatomic, assign) BOOL preferKPCTransformer;
@property (nonatomic, copy) NSArray <NSString *>*selfDefinedClassRegulars;
@property (nonatomic, copy) NSDictionary <NSString *, NSString *>*defaultTransformerMap;

@end

@implementation QJMMantleCommandHandler

- (instancetype)init {
  self = [super init];
  if (self) {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MantlePreference" ofType:@"plist"];
    NSParameterAssert(path);
    if (path) {
      NSDictionary *configInfo = [NSDictionary dictionaryWithContentsOfFile:path];
      _enableKPCGlobal = [configInfo[@"EXTKeyPathCoding"] boolValue];
      _enableKPCCurrentPage = _enableKPCGlobal;
      _preferKPCTransformer = [configInfo[@"KeyPathPrefixTransformer"] boolValue];
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
  self.enableKPCCurrentPage = self.enableKPCGlobal;
}

- (void)scanWithLine:(NSString *)oriLine purifiedLine:(NSString *)purifiedLine classInfo:(QJMClassInfo *)info {
  if ([purifiedLine localizedCaseInsensitiveContainsString:KeypathCodeingEnable]) {
    self.enableKPCCurrentPage = YES;
  } else if ([purifiedLine localizedCaseInsensitiveContainsString:KeypathCodeingDisable]) {
    self.enableKPCCurrentPage = NO;
  }
}

- (NSArray <NSString *>*)mapMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* jsonMapMethods = [NSMutableArray array];
  if (!info.propertyInfos.count) {
    return jsonMapMethods;
  }
  NSArray *keypathMethods = [self keypathForSourceInfo:info];
  NSArray *transformerMethods = [self customerTransformerForSourceInfo:info];
  if (keypathMethods.count) {
    [jsonMapMethods qjm_prefixPragmaMarkWithContent:@"#pragma mark - mantle keypath map"];
    [jsonMapMethods addObjectsFromArray:keypathMethods];
    if (!transformerMethods.count) {
      [jsonMapMethods addObject:QJMNewLineWithIndentLevel(nil, 0)];
    }
  }
  if (transformerMethods.count) {
    [jsonMapMethods qjm_prefixPragmaMarkWithContent:@"#pragma mark - mantle custom class / predefined transformer"];
    [jsonMapMethods addObjectsFromArray:transformerMethods];
  }
  if (jsonMapMethods.count) {
    [jsonMapMethods insertObject:[self beginMarkStringOfGeneratedCode] atIndex:0];
    [jsonMapMethods addObject:[self endMarkStringOfGeneratedCode]];
  }
  return jsonMapMethods;
}

#pragma mark - key path map

- (NSArray <NSString *>*)keypathForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* jsonMapMethods = [NSMutableArray array];
  
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"+ (NSDictionary *)JSONKeyPathsByPropertyKey {", 0)];
  if (self.enableKPCCurrentPage) {
    [jsonMapMethods addObject:QJMNewLineWithIndentLevel([NSString stringWithFormat:@"%@ *model = nil;", info.modelClassName], 1)];
  }
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"return @{", 1)];
  
  [info.propertyInfos enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (!obj.isReadOnly && !obj.isClassProperty) {
      NSString *methodLine = nil;
      if (self.enableKPCCurrentPage) {
        methodLine = [NSString stringWithFormat:@"@keypath(model.%@) : @\"%@\",", obj.propertyName, obj.propertyName];
      } else {
        methodLine = [NSString stringWithFormat:@"@\"%@\" : @\"%@\",", obj.propertyName, obj.propertyName];
      }
      [jsonMapMethods addObject:QJMNewLineWithIndentLevel(methodLine, 2)];
    }
  }];
  
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"};", 1)];
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  return jsonMapMethods;
}

#pragma mark - custom class transformer

- (NSArray <NSString *>*)customerTransformerForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* customerTransformerMapMethods = [NSMutableArray array];
  NSMutableArray <QJMPropertyInfo *>*customTransformerProp = [NSMutableArray array];
  [info.propertyInfos enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (!obj.isPrimitiveType && ([self isSelfDefinedClass:obj.typeString] ||
                                 [self isSelfDefinedClass:obj.innerTypeString] ||
                                 [self defaultTransformerNameForClass:obj.typeString])) {
      [customTransformerProp addObject:obj];
    }
  }];
  if (!customTransformerProp.count) {
    return customerTransformerMapMethods;
  }
  if (self.preferKPCTransformer) {
    return [self keypathPrefixTransformerForProperties:customTransformerProp];
  } else {
    return [self transformerCollectionMethodForProperties:customTransformerProp];
  }
}

- (NSArray <NSString *>*)keypathPrefixTransformerForProperties:(NSArray <QJMPropertyInfo *>*)propertyArray {
  NSMutableArray <NSString *>* methodLines = [NSMutableArray array];
  [propertyArray enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSString *transformerMethed = [NSString stringWithFormat:@"+ (NSValueTransformer *)%@JSONTransformer {", obj.propertyName];
    [methodLines addObject:QJMNewLineWithIndentLevel(transformerMethed, 0)];
    NSString *transType = obj.innerTypeString ? @"array" : @"dictionary";
    NSString *defaultTransformerName = [self defaultTransformerNameForClass:obj.typeString];
    NSString *returnPart = nil;
    if (defaultTransformerName) {
      returnPart = [NSString stringWithFormat:@"return [NSValueTransformer valueTransformerForName:%@];", defaultTransformerName];
    } else {
      returnPart = [NSString stringWithFormat:@"return [MTLJSONAdapter %@TransformerWithModelClass:[%@ class]];", transType, obj.innerTypeString ?: obj.typeString];
    }
    [methodLines addObject:QJMNewLineWithIndentLevel(returnPart, 1)];
    [methodLines addObject:QJMNewLineWithIndentLevel(@"}", 0)];
    [methodLines addObject:QJMNewLineWithIndentLevel(nil, 0)];
  }];
  return methodLines;
}

- (NSArray <NSString *>*)transformerCollectionMethodForProperties:(NSArray <QJMPropertyInfo *>*)propertyArray {
  NSMutableArray <NSString *>* methodLines = [NSMutableArray array];
  [methodLines addObject:QJMNewLineWithIndentLevel(@"+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {", 0)];
  [propertyArray enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSString *ifString = [NSString stringWithFormat:@"%@if ([key isEqualToString:@\"%@\"]) {", idx > 0 ? @"} else " : @"", obj.propertyName];
    [methodLines addObject:QJMNewLineWithIndentLevel(ifString, 1)];
    NSString *transType = obj.innerTypeString ? @"array" : @"dictionary";
    NSString *defaultTransformerName = [self defaultTransformerNameForClass:obj.typeString];
    NSString *returnPart = nil;
    if (defaultTransformerName) {
      returnPart = [NSString stringWithFormat:@"return [NSValueTransformer valueTransformerForName:%@];", defaultTransformerName];
    } else {
      returnPart = [NSString stringWithFormat:@"return [MTLJSONAdapter %@TransformerWithModelClass:[%@ class]];", transType, obj.innerTypeString ?: obj.typeString];
    }
    [methodLines addObject:QJMNewLineWithIndentLevel(returnPart, 2)];
  }];
  [methodLines addObject:QJMNewLineWithIndentLevel(@"} else {", 1)];
  [methodLines addObject:QJMNewLineWithIndentLevel(@"return nil;", 2)];
  [methodLines addObject:QJMNewLineWithIndentLevel(@"}", 1)];
  [methodLines addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  [methodLines addObject:QJMNewLineWithIndentLevel(nil, 0)];
  return methodLines;
}

- (NSString *)beginMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(@"/*\t\tmantle map method copy begin\t\t", 0);
}

- (NSString *)endMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(@"mantle map method copy end\t\t*/", 2);
}

@end
