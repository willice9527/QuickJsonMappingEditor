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
static NSString *const QJMPropertyInnerTypeRegular = @"\\b\\w+\\s*(?=\\*\\s*>)";// *> 前面的第一个单词
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
    _isPrimitiveType = NO;
    _metaLine = [metaString copy];
    NSString *attrString = [metaString qjm_subStringWithRegular:QJMPropertyAttributeRegular];
    if (attrString) {
      _isReadOnly = [attrString containsString:@"readonly"];
      _isClassProperty = [attrString containsString:@"class"];
      _isPrimitiveType = [attrString containsString:@"assign"];
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

- (instancetype)initWithAttributeSwiftMetaStringLine:(NSString *)metaString {
  NSParameterAssert(metaString);
  self = [super init];
  if (self) {
    _isReadOnly = NO;
    _isClassProperty = NO;
    _isPrimitiveType = NO;
    _metaLine = [metaString copy];
    NSString *attrString = [metaString qjm_subStringWithRegular:QJMPropertyAttributeRegular];
    if (attrString) {
      _isReadOnly = [attrString containsString:@"readonly"];
      _isClassProperty = [attrString containsString:@"class"];
      _isPrimitiveType = [attrString containsString:@"assign"];
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

- (BOOL)isContainer {
  return [self.typeString isEqualToString:NSStringFromClass([NSArray class])] ||
        [self.typeString isEqualToString:NSStringFromClass([NSSet class])] ||
        [self.typeString isEqualToString:NSStringFromClass([NSDictionary class])];
}

@end

@implementation QJMClassInfo

- (NSMutableArray *)propertyInfos {
  if (!_propertyInfos) {
    _propertyInfos = [NSMutableArray array];
  }
  return _propertyInfos;
}

@end
