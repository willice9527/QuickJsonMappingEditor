//
//  QJMPreDefinition.h
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - command config

extern NSString *const QJMMantleIdentifier;
extern NSString *const QJMMantleKeyName;

extern NSString *const QJMYYModelIdentifier;
extern NSString *const QJMYYModelKeyName;

extern NSString *const QJMObjectMapperIdentifier;
extern NSString *const QJMObjectMapperKeyName;

#pragma mark - source code identifier

extern NSString *const Prefix_Property;
extern NSString *const Prefix_Interface;
extern NSString *const Prefix_Implementation;
extern NSString *const Prefix_End;
extern NSString *const Prefix_MacroDefinition;

extern NSString *const Swift_Prefix_Class;
extern NSString *const Swift_Prefix_Struct;
extern NSString *const Swift_Prefix_Function;
extern NSString *const Swift_Prefix_Variable;

#pragma mark - key path coding mantle

extern NSString *const KeypathCodeingEnable;
extern NSString *const KeypathCodeingDisable;

#pragma mark - support source file type

extern NSString *const QJMSupportFileTypeOCHeader;
extern NSString *const QJMSupportFileTypeSwiftSource;

#pragma mark - yymodel setting

extern NSString *const QJMYYModelEnablePropertyBlackList;
extern NSString *const QJMYYModelEnablePropertyWhiteList;
extern NSString *const QJMYYModelEnableCopy;
extern NSString *const QJMYYModelEnableCompare;
extern NSString *const QJMYYModelEnableTransform;


@interface QJMPreDefinition : NSObject

@property (nonatomic, copy, class, readonly) NSArray <NSString *>*supportedFileTypes;
@property (nonatomic, copy, class, readonly) NSArray <NSString *>*swiftSupportedCommands;
@property (nonatomic, copy, class, readonly) NSArray <NSString *>*OCSupportedCommands;

@end

