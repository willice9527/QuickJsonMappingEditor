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

extern NSString *const QJMJsonModelIdentifier;
extern NSString *const QJMJsonModelKeyName;

extern NSString *const QJMObjectMapperIdentifier;
extern NSString *const QJMObjectMapperKeyName;

#pragma mark - source code identifier

extern NSString *const Prefix_Property;
extern NSString *const Prefix_Interface;
extern NSString *const Prefix_Implementation;
extern NSString *const Prefix_End;
extern NSString *const Prefix_MacroDefinition;

#pragma mark - key path coding

extern NSString *const KeypathCodeingEnable;
extern NSString *const KeypathCodeingDisable;

#pragma mark - support source file type

extern NSString *const QJMSupportFileTypeOCHeader;
extern NSString *const QJMSupportFileTypeSwiftSource;

@interface QJMPreDefinition : NSObject

@property (nonatomic, copy, class, readonly) NSArray <NSString *>*supportedFileTypes;
@property (nonatomic, copy, class, readonly) NSArray <NSString *>*swiftSupportedCommands;
@property (nonatomic, copy, class, readonly) NSArray <NSString *>*OCSupportedCommands;

@end

