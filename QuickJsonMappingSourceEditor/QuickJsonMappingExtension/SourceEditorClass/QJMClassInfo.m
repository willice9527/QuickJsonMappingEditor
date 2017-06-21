//
//  QJMClassInfo.m
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "QJMClassInfo.h"
#import "NSString+QJMUitility.h"

static NSString *const QJMPropertyAttributeRegular = @"\\(.*?\\)";//()中间的部分
static NSString *const QJMPropertyTypeWithAttrRegular = @"(?<=\\b\\))\\s*\\w+\\b";//(nonatomic)含有这部分情况下，）后面的第一个单词
static NSString *const QJMPropertyTypeNoAttrRegular = @"(?<=property)\\s*\\w+\\b";//不含(nonatomic)情况下，property后面的第一个单词
static NSString *const QJMPropertyNameRegular = @"\\b\\w+\\s*(?=;)";//;号前面的第一个单词
static NSString *const QJMPropertyInnerTypeRegular = @"(?<=\\<)\\s*\\w+\\b";// < 后面的第一个单词
static NSString *const QJMPropertyNameForTransformerRegular = @"\\b\\w+(?=JSONTransformer)";// ) JSONTransformer 前面的第一个单词

@interface QJMPropertyInfo ()

@property (nonatomic, assign, readwrite) BOOL isClassProperty;
@property (nonatomic, assign, readwrite) BOOL isReadOnly;
@property (nonatomic, copy, readwrite) NSString *typeString;
@property (nonatomic, copy, readwrite) NSString *innerTypeString;
@property (nonatomic, copy, readwrite) NSString *propertyName;
@property (nonatomic, copy, readwrite) NSString *metaLine;

@end

@implementation QJMPropertyInfo

- (instancetype)initWithAttributeMetaStringLine:(NSString *)metaString {
  NSParameterAssert(metaString);
  self = [super init];
  if (self) {
    _isReadOnly = NO;
    _isClassProperty = NO;
    _metaLine = [metaString copy];
    NSString *attrString = [metaString qjm_subStringWithRegular:QJMPropertyAttributeRegular];
    if (attrString) {
      _isReadOnly = [attrString containsString:@"readonly"];
      _isClassProperty = [attrString containsString:@"class"];
      _typeString = [metaString qjm_subStringWithRegular:QJMPropertyTypeWithAttrRegular];
    } else {
      _typeString = [metaString qjm_subStringWithRegular:QJMPropertyTypeNoAttrRegular];
    }
    NSParameterAssert(_typeString);
    _propertyName = [metaString qjm_subStringWithRegular:QJMPropertyNameRegular];
    NSParameterAssert(_propertyName);
    if ([_typeString isEqualToString:NSStringFromClass([NSArray class])] ||
        [_typeString isEqualToString:NSStringFromClass([NSMutableArray class])]) {
      _innerTypeString = [metaString qjm_subStringWithRegular:QJMPropertyInnerTypeRegular];
    }
  }
  return self;
}

@end

@implementation QJMClassInfo

- (NSMutableArray *)propertyInfos {
  if (!_propertyInfos) {
    _propertyInfos = [NSMutableArray array];
  }
  return _propertyInfos;
}

- (NSMutableArray *)transformerAvailablePropertyArray {
  if (!_transformerAvailablePropertyArray) {
    _transformerAvailablePropertyArray = [NSMutableArray array];
  }
  return _transformerAvailablePropertyArray;
}

- (void)tagTransformerForMetaString:(NSString *)metaString {
  NSString *propertyName = [metaString qjm_subStringWithRegular:QJMPropertyNameForTransformerRegular];
  if (propertyName) {
    if ([[self.propertyInfos valueForKeyPath:@"@distinctUnionOfObjects.propertyName"] containsObject:propertyName]) {
      [self.transformerAvailablePropertyArray addObject:propertyName];
    }
  }
}

@end
