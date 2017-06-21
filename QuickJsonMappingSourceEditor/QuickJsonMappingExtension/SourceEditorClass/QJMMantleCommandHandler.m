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
  }
  if ([purifiedLine localizedCaseInsensitiveContainsString:KeypathCodeingDisable]) {
    self.enableKPCCurrentPage = NO;
  }
  if (!info) {
    return;
  }
  if (![purifiedLine hasPrefix:@"+"]) {
    return;
  }
  if ([purifiedLine containsString:@"JSONKeyPathsByPropertyKey"]) {
    info.jsonKeyPathMapAvailable = YES;
  } else if ([purifiedLine containsString:@"JSONTransformerForKey"]) {
    info.transformerCollectionAvailable = YES;
  } else if ([purifiedLine containsString:@"JSONTransformer"]) {
    [info tagTransformerForMetaString:purifiedLine];
  }
}

- (NSArray <NSString *>*)mapMethodForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* jsonMapMethods = [NSMutableArray array];
  NSArray *keypathMethods = [self keypathForSourceInfo:info];
  NSArray *transformerMethods = [self customerTransformerForSourceInfo:info];
  if (keypathMethods.count) {
    [jsonMapMethods addObject:@"\n"];
    [jsonMapMethods addObject:@"#pragma mark - mantle keypath map\n"];
    [jsonMapMethods addObject:@"\n"];
    [jsonMapMethods addObjectsFromArray:keypathMethods];
    if (!transformerMethods.count) {
      [jsonMapMethods addObject:@"\n"];
    }
  }
  if (transformerMethods.count) {
    [jsonMapMethods addObject:@"\n"];
    [jsonMapMethods addObject:@"#pragma mark - mantle custom class / predefined transformer\n"];
    [jsonMapMethods addObject:@"\n"];
    [jsonMapMethods addObjectsFromArray:transformerMethods];
  }
  return jsonMapMethods;
}

#pragma mark - key path map

- (NSArray <NSString *>*)keypathForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* jsonMapMethods = [NSMutableArray array];
  if (info.jsonKeyPathMapAvailable) {
    return jsonMapMethods;
  }
  
  [jsonMapMethods addObject:@"+ (NSDictionary *)JSONKeyPathsByPropertyKey {\n"];
  if (self.enableKPCCurrentPage) {
    [jsonMapMethods addObject:[NSString stringWithFormat:@"\t%@ *model = nil;\n", info.modelClassName]];
  }
  [jsonMapMethods addObject:@"\treturn @{\n"];
  
  [info.propertyInfos enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if (!obj.isReadOnly && !obj.isClassProperty) {
      NSString *methodLine = nil;
      if (self.enableKPCCurrentPage) {
        methodLine = [NSString stringWithFormat:@"\t\t@keypath(model.%@) : @\"%@\",\n", obj.propertyName, obj.propertyName];
      } else {
        methodLine = [NSString stringWithFormat:@"\t\t@\"%@\" : @\"%@\",\n", obj.propertyName, obj.propertyName];
      }
      [jsonMapMethods addObject:methodLine];
    }
  }];
  
  [jsonMapMethods addObject:@"\t};\n"];
  [jsonMapMethods addObject:@"}\n"];
  return jsonMapMethods;
}

#pragma mark - custom class transformer

- (NSArray <NSString *>*)customerTransformerForSourceInfo:(QJMClassInfo *)info {
  NSMutableArray <NSString *>* customerTransformerMapMethods = [NSMutableArray array];
  if (info.transformerCollectionAvailable) {
    return customerTransformerMapMethods;
  }
  NSMutableArray <QJMPropertyInfo *>*customTransformerProp = [NSMutableArray array];
  [info.propertyInfos enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    if ([self isSelfDefinedClass:obj.typeString] ||
        [self isSelfDefinedClass:obj.innerTypeString] ||
        [self defaultTransformerNameForClass:obj.typeString]) {
      if (![info.transformerAvailablePropertyArray containsObject:obj.propertyName]) {
        [customTransformerProp addObject:obj];
      }
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
    NSString *transformerMethed = [NSString stringWithFormat:@"+ (NSValueTransformer *)%@JSONTransformer {\n", obj.propertyName];
    [methodLines addObject:transformerMethed];
    NSString *transType = obj.innerTypeString ? @"array" : @"dictionary";
    NSString *defaultTransformerName = [self defaultTransformerNameForClass:obj.typeString];
    NSString *returnPart = nil;
    if (defaultTransformerName) {
      returnPart = [NSString stringWithFormat:@"\treturn [NSValueTransformer valueTransformerForName:%@];\n", defaultTransformerName];
    } else {
      returnPart = [NSString stringWithFormat:@"\treturn [MTLJSONAdapter %@TransformerWithModelClass:[%@ class]];\n", transType, obj.innerTypeString ?: obj.typeString];
    }
    [methodLines addObject:returnPart];
    [methodLines addObject:@"}\n"];
    [methodLines addObject:@"\n"];
  }];
  return methodLines;
}

- (NSArray <NSString *>*)transformerCollectionMethodForProperties:(NSArray <QJMPropertyInfo *>*)propertyArray {
  NSMutableArray <NSString *>* methodLines = [NSMutableArray array];
  [methodLines addObject:@"+ (NSValueTransformer *)JSONTransformerForKey:(NSString *)key {\n"];
  [propertyArray enumerateObjectsUsingBlock:^(QJMPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    NSString *ifString = [NSString stringWithFormat:@"\t%@if ([key isEqualToString:@\"%@\"]) {\n", idx > 0 ? @"} else " : @"", obj.propertyName];
    [methodLines addObject:ifString];
    NSString *transType = obj.innerTypeString ? @"array" : @"dictionary";
    NSString *defaultTransformerName = [self defaultTransformerNameForClass:obj.typeString];
    NSString *returnPart = nil;
    if (defaultTransformerName) {
      returnPart = [NSString stringWithFormat:@"\t\treturn [NSValueTransformer valueTransformerForName:%@];\n", defaultTransformerName];
    } else {
      returnPart = [NSString stringWithFormat:@"\t\treturn [MTLJSONAdapter %@TransformerWithModelClass:[%@ class]];\n", transType, obj.innerTypeString ?: obj.typeString];
    }
    [methodLines addObject:returnPart];
  }];
  [methodLines addObject:@"\t} else {\n"];
  [methodLines addObject:@"\t\treturn nil;\n"];
  [methodLines addObject:@"\t}\n"];
  [methodLines addObject:@"}\n"];
  [methodLines addObject:@"\n"];
  return methodLines;
}

@end
