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
#import "QJMClassInfo.h"
#import "NSArray+QJMUtility.h"

@interface QJMYYModelCommandHandler ()

@property (nonatomic, assign) BOOL blackListEnable;
@property (nonatomic, assign) BOOL whiteListEnable;
@property (nonatomic, assign) BOOL copyEnable;
@property (nonatomic, assign) BOOL compareEnable;
@property (nonatomic, assign) BOOL transformEnable;
@property (nonatomic, copy) NSArray <NSString *>*selfDefinedClassRegulars;
@property (nonatomic, copy) NSArray <NSString *>*autoTransformerTypes;

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
      _autoTransformerTypes = [configInfo[@"AutoTransformTypes"] copy];
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
    self.whiteListEnable = YES;
  } else if ([purifiedLine localizedCaseInsensitiveContainsString:QJMYYModelEnableCopy]) {
    self.copyEnable = YES;
  } else if ([purifiedLine localizedCaseInsensitiveContainsString:QJMYYModelEnableCompare]) {
    self.compareEnable = YES;
  }
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

- (BOOL)needCustomTransformerForType:(NSString *)type {
  return ![self.autoTransformerTypes containsObject:type];
}

- (NSArray <NSString *>*)mapMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* jsonMapMethods = [NSMutableArray array];
  if (!info.propertyInfos.count) {
    return jsonMapMethods;
  }
  NSArray *propertyMapper = [self propertyMapperForSourceInfo:info];
  NSArray *classMapper = [self propertyClassMapperForSourceInfo:info];
  NSArray *blackList = [self blackListForSourceInfo:info];
  NSArray *whiteList = [self whiteListForSourceInfo:info];
  NSArray *copy = [self copyMethodForSourceInfo:info];
  NSArray *compare = [self compareMethodForSourceInfo:info];
  NSArray *transformer = [self transformerForSourceInfo:info];
  NSArray *archive = [self archiveMethodForSourceInfo:info];
  NSArray *des = [self descriptionForSourceInfo:info];
  NSArray <NSArray *>*yymodelMappers = @[ propertyMapper, classMapper, blackList, whiteList, copy, compare, transformer, archive, des];
  [yymodelMappers enumerateObjectsUsingBlock:^(NSArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (obj.count) {
      [jsonMapMethods addObjectsFromArray:obj];
    }
  }];
  if (jsonMapMethods.count) {
    [jsonMapMethods insertObject:[self beginMarkStringOfGeneratedCode] atIndex:0];
    [jsonMapMethods addObject:[self endMarkStringOfGeneratedCode]];
  }
  return jsonMapMethods;
}

- (NSArray <NSString *>*)propertyMapperForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* jsonMapMethods = [NSMutableArray array];
  __block NSUInteger count = 0;
  [jsonMapMethods qjm_prefixPragmaMarkWithContent:@"#pragma mark - custom property map"];
  
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"+ (NSDictionary *)modelCustomPropertyMapper {", 0)];
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"return @{", 1)];
  [info.propertyInfos enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (!obj.isReadOnly && !obj.isClassProperty && !obj.isContainer) {
      NSString * methodLine = [NSString stringWithFormat:@"@\"%@\" : @\"%@\",", obj.propertyName, obj.propertyName];
      [jsonMapMethods addObject:QJMNewLineWithIndentLevel(methodLine, 2)];
      count++;
    }
  }];
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"};", 1)];
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  if (count <= 0) {
    [jsonMapMethods removeAllObjects];
  }
  return jsonMapMethods;
}

- (NSArray <NSString *>*)propertyClassMapperForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* classMap = [NSMutableArray array];
  __block NSUInteger count = 0;
  [classMap qjm_prefixPragmaMarkWithContent:@"#pragma mark - custom container map"];
  
  [classMap addObject:QJMNewLineWithIndentLevel(@"+ (NSDictionary *)modelContainerPropertyGenericClass {", 0)];
  [classMap addObject:QJMNewLineWithIndentLevel(@"return @{", 1)];
  [info.propertyInfos enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (obj.isContainer && obj.innerTypeString) {
      NSString * methodLine = [NSString stringWithFormat:@"@\"%@\" : [%@ class],", obj.propertyName, obj.innerTypeString];
      [classMap addObject:QJMNewLineWithIndentLevel(methodLine, 2)];
      count++;
    }
  }];
  [classMap addObject:QJMNewLineWithIndentLevel(@"};", 1)];
  [classMap addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  if (count <= 0) {
    [classMap removeAllObjects];
  }
  return classMap;
}

- (NSArray <NSString *>*)blackListForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* blackList = [NSMutableArray array];
  if (self.whiteListEnable || !self.blackListEnable) {
    return blackList;
  }
  [blackList qjm_prefixPragmaMarkWithContent:@"#pragma mark - black list"];
  [blackList addObject:QJMNewLineWithIndentLevel(@"+ (NSArray *)modelPropertyBlacklist {", 0)];
  [blackList addObject:QJMNewLineWithIndentLevel(@"return @[];", 1)];
  [blackList addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  return blackList;
}

- (NSArray <NSString *>*)whiteListForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* whiteList = [NSMutableArray array];
  if (!self.whiteListEnable) {
    return whiteList;
  }
  [whiteList qjm_prefixPragmaMarkWithContent:@"#pragma mark - white list"];
  [whiteList addObject:QJMNewLineWithIndentLevel(@"+ (NSArray *)modelPropertyWhitelist {", 0)];
  [whiteList addObject:QJMNewLineWithIndentLevel(@"return @[];", 1)];
  [whiteList addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  return whiteList;
}

- (NSArray <NSString *>*)copyMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* copyMethod = [NSMutableArray array];
  if (!self.copyEnable) {
    return copyMethod;
  }
  [copyMethod qjm_prefixPragmaMarkWithContent:@"#pragma mark - NSCopy"];
  [copyMethod addObject:QJMNewLineWithIndentLevel(@"- (void)encodeWithCoder:(NSCoder *)aCoder {", 0)];
  [copyMethod addObject:QJMNewLineWithIndentLevel(@"[self yy_modelEncodeWithCoder:aCoder];", 1)];
  [copyMethod addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  return copyMethod;
}

- (NSArray <NSString *>*)compareMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* compareMethod = [NSMutableArray array];
  if (!self.compareEnable) {
    return compareMethod;
  }
  [compareMethod qjm_prefixPragmaMarkWithContent:@"#pragma mark - compare"];
  [compareMethod addObject:QJMNewLineWithIndentLevel(@"- (NSUInteger)hash {", 0)];
  [compareMethod addObject:QJMNewLineWithIndentLevel(@"return [self yy_modelHash];", 1)];
  [compareMethod addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  [compareMethod addObject:QJMNewLineWithIndentLevel(nil, 0)];
  [compareMethod addObject:QJMNewLineWithIndentLevel(@"- (BOOL)isEqual:(id)object {", 0)];
  [compareMethod addObject:QJMNewLineWithIndentLevel(@"return [self yy_modelIsEqual:object];", 1)];
  [compareMethod addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  return compareMethod;
}

- (NSArray <NSString *>*)transformerForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <QJMPropertyInfo *>*transInfo = [NSMutableArray array];
  [info.propertyInfos enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (!obj.isReadOnly &&
        !obj.isClassProperty &&
        !obj.isContainer &&
        ![self isSelfDefinedClass:obj.typeString] &&
        [self needCustomTransformerForType:obj.typeString]) {
      [transInfo addObject:obj];
    }
  }];
  NSMutableArray <NSString *>* transformer = [NSMutableArray array];
  if (!self.transformEnable && !transInfo.count) {
    return transformer;
  }
  [transformer qjm_prefixPragmaMarkWithContent:@"#pragma mark - custome transform"];
  NSString *transformTip = nil;
  if (transInfo.count) {
    transformTip = [[transInfo valueForKeyPath:@"@distinctUnionOfObjects.propertyName"] componentsJoinedByString:@"/"];
    transformTip = [NSString stringWithFormat:@"//-- custom transform for: %@ --", transformTip];
  }
  [transformer addObject:QJMNewLineWithIndentLevel(@"- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {", 0)];
  [transformer addObject:QJMNewLineWithIndentLevel(transformTip, 1)];
  [transformer addObject:QJMNewLineWithIndentLevel(@"return dic;", 1)];
  [transformer addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  [transformer addObject:QJMNewLineWithIndentLevel(nil, 0)];
  
  [transformer addObject:QJMNewLineWithIndentLevel(@"- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {", 0)];
  [transformer addObject:QJMNewLineWithIndentLevel(transformTip, 1)];
  [transformer addObject:QJMNewLineWithIndentLevel(@"return YES;", 1)];
  [transformer addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  [transformer addObject:QJMNewLineWithIndentLevel(nil, 0)];
  
  [transformer addObject:QJMNewLineWithIndentLevel(@"- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {", 0)];
  [transformer addObject:QJMNewLineWithIndentLevel(transformTip, 1)];
  [transformer addObject:QJMNewLineWithIndentLevel(@"return YES;", 1)];
  [transformer addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  return transformer;
}

- (NSArray <NSString *>*)archiveMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* archiveMethod = [NSMutableArray array];
  [archiveMethod qjm_prefixPragmaMarkWithContent:@"#pragma mark - NSCoder"];
  [archiveMethod addObject:QJMNewLineWithIndentLevel(@"- (void)encodeWithCoder:(NSCoder *)aCoder {", 0)];
  [archiveMethod addObject:QJMNewLineWithIndentLevel(@"[self yy_modelEncodeWithCoder:aCoder];", 1)];
  [archiveMethod addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  [archiveMethod addObject:QJMNewLineWithIndentLevel(nil, 0)];
  [archiveMethod addObject:QJMNewLineWithIndentLevel(@"- (id)initWithCoder:(NSCoder *)aDecoder {", 0)];
  [archiveMethod addObject:QJMNewLineWithIndentLevel(@"self = [super init];", 1)];
  [archiveMethod addObject:QJMNewLineWithIndentLevel(@"return [self yy_modelInitWithCoder:aDecoder];", 1)];
  [archiveMethod addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  return archiveMethod;
}

- (NSArray <NSString *>*)descriptionForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* desMethod = [NSMutableArray array];
  [desMethod qjm_prefixPragmaMarkWithContent:@"#pragma mark - description"];
  [desMethod addObject:QJMNewLineWithIndentLevel(@"- (NSString *)description {", 0)];
  [desMethod addObject:QJMNewLineWithIndentLevel(@"return [self yy_modelDescription];", 1)];
  [desMethod addObject:QJMNewLineWithIndentLevel(@"}", 0)];
  return desMethod;
}

- (NSString *)beginMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(@"/*\t\tYYModel map method copy begin\t\t", 0);
}

- (NSString *)endMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(@"YYModel map method copy end\t\t*/", 2);
}

@end
