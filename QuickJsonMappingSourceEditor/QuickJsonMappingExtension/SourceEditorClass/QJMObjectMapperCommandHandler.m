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

- (NSString *)defaultTransformerNameForClass:(NSString *)className {
  if ([NSString qjm_isBlank:className]) {
    return nil;
  }
  return self.defaultTransformerMap[className];
}

#pragma mark - QJMCommandHandleProtocol

- (void)commondDidArrivedWithInvocation:(XCSourceEditorCommandInvocation *)invocation {
  
}

- (void)scanWithLine:(NSString *)oriLine purifiedLine:(NSString *)purifiedLine classInfo:(QJMClassInfo *)info {

}

- (NSArray <NSString *>*)mapMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* jsonMapMethods = [NSMutableArray array];
  if (!info.propertyInfos.count) {
    return jsonMapMethods;
  }
  NSArray *initMethods = [self modelInitMethodForSourceInfo:info];
  NSArray *mapperMethods = [self mapperMethodForSourceInfo:info];
  if (initMethods.count) {
    [jsonMapMethods addObjectsFromArray:initMethods];
  }
  if (mapperMethods.count) {
    [jsonMapMethods addObjectsFromArray:mapperMethods];
  }
  if (jsonMapMethods.count) {
    [jsonMapMethods insertObject:[self beginMarkStringOfGeneratedCode] atIndex:0];
    [jsonMapMethods addObject:[self endMarkStringOfGeneratedCode]];
    [jsonMapMethods addObject:QJMNewLineWithIndentLevel(nil, 0)];
  }
  return jsonMapMethods;
}

- (NSArray <NSString *>*)modelInitMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* jsonMapMethods = [NSMutableArray array];
  [jsonMapMethods qjm_prefixPragmaMarkWithContent:@"// init with map"];
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"required init?(map: Map) {", 1)];
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(nil, 0)];
  [jsonMapMethods addObject:QJMNewLineWithIndentLevel(@"};", 1)];
  return jsonMapMethods;
}

- (NSArray <NSString *>*)mapperMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* mapMethod = [NSMutableArray array];
  __block NSUInteger count = 0;
  [mapMethod qjm_prefixPragmaMarkWithContent:@"// property map"];
  
  [mapMethod addObject:QJMNewLineWithIndentLevel(@"func mapping(map: Map) {", 1)];
  NSUInteger maxProNameLenth = [info maxLengthOfPropertyNameWithUsefullTargetFilter:^BOOL(QJMPropertyInfo * _Nonnull proInfo) {
    return (!proInfo.isReadOnly && !proInfo.isClassProperty);
  }];
  [info.propertyInfos enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (!obj.isReadOnly && !obj.isClassProperty) {
      NSString *mapPart = [NSString stringWithFormat:@"map[\"%@\"]", obj.propertyName];
      NSString *transformer = [self defaultTransformerNameForClass:obj.isContainer ? obj.innerTypeString : obj.typeString];
      NSString *indent = QJMIndetForStrings(obj.propertyName, maxProNameLenth);
      if (transformer) {
        mapPart = [NSString stringWithFormat:@"(map[\"%@\"], %@())", obj.propertyName, transformer];
      } 
      NSString * methodLine = [NSString stringWithFormat:@"%@%@<- %@", obj.propertyName, indent, mapPart];
      [mapMethod addObject:QJMNewLineWithIndentLevel(methodLine, 2)];
      count++;
    }
  }];
  [mapMethod addObject:QJMNewLineWithIndentLevel(@"};", 1)];
  if (count <= 0) {
    [mapMethod removeAllObjects];
  }
  return mapMethod;
}

- (NSString *)beginMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(@"/*\t\tObjectMapper map method begin\t\t", 0);
}

- (NSString *)endMarkStringOfGeneratedCode {
  return QJMNewLineWithIndentLevel(@"ObjectMapper map method end\t\t*/", 2);
}

@end
