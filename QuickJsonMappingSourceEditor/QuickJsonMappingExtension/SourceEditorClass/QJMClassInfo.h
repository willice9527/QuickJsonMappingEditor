//
//  QJMClassInfo.h
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QJMCommandHandleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface QJMPropertyInfo : NSObject

@property (nonatomic, assign, readonly) BOOL isPrimitiveType;
@property (nonatomic, assign, readonly) BOOL isClassProperty;
@property (nonatomic, assign, readonly) BOOL isReadOnly;
@property (nonatomic, copy, readonly) NSString *typeString;
@property (nonatomic, copy, readonly) NSString *innerTypeString;//container only{Array,set}
@property (nonatomic, copy, readonly) NSString *propertyName;
@property (nonatomic, copy, readonly) NSString *metaLine;

- (instancetype)initWithAttributeMetaStringLine:(NSString *)metaString;

@end

@interface QJMClassInfo : NSObject

///meta info
@property (nonatomic, copy) NSString *modelClassName;
@property (nonatomic, assign) NSUInteger impEndLine;
@property (nonatomic, copy) NSMutableArray <QJMPropertyInfo *>*propertyInfos;

///reposition entry point
@property (nonatomic, assign) NSUInteger lineOffset;
@property (nonatomic, assign) BOOL jsonKeyPathMapAvailable;
@property (nonatomic, copy) NSMutableArray <NSString *>*transformerAvailablePropertyArray;
@property (nonatomic, assign) BOOL transformerCollectionAvailable;
@property (nonatomic, assign) NSUInteger impIndex;

- (void)tagTransformerForMetaString:(NSString *)metaString;

@end

NS_ASSUME_NONNULL_END
