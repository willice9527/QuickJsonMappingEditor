//
//  QJMPreDefinition.m
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "QJMPreDefinition.h"

NSString *const QJMMantleIdentifier = @"jinlin.liu.QuickJsonMappingSourceEditor.mantle";
NSString *const QJMMantleKeyName = @"Mantle(OC)";

NSString *const QJMYYModelIdentifier = @"jinlin.liu.QuickJsonMappingSourceEditor.yymodel";
NSString *const QJMYYModelKeyName = @"YYModel(OC)";

NSString *const QJMObjectMapperIdentifier = @"jinlin.liu.QuickJsonMappingSourceEditor.objectmapper";
NSString *const QJMObjectMapperKeyName = @"ObjectMapper(Swift)";

///objective-c source
NSString *const Prefix_Property = @"@property";
NSString *const Prefix_Interface = @"@interface";
NSString *const Prefix_Implementation = @"@implementation";
NSString *const Prefix_End = @"@end";
NSString *const Prefix_MacroDefinition = @"#define";
///swift source
NSString *const Swift_Prefix_Class = @"class";
NSString *const Swift_Prefix_Struct = @"struct";
NSString *const Swift_Prefix_Function = @"func";
NSString *const Swift_Prefix_Variable = @"var";


NSString *const KeypathCodeingEnable = @"Keypath_Coding_Enable";
NSString *const KeypathCodeingDisable = @"Keypath_Coding_Disable";

NSString *const QJMSupportFileTypeOCHeader = @"public.c-header";
NSString *const QJMSupportFileTypeSwiftSource = @"public.swift-source";

NSString *const QJMYYModelEnablePropertyBlackList = @"blacklist_enable";
NSString *const QJMYYModelEnablePropertyWhiteList = @"whitelist_enable";
NSString *const QJMYYModelEnableCopy = @"copy_enable";
NSString *const QJMYYModelEnableCompare = @"compare_enable";
NSString *const QJMYYModelEnableTransform = @"transform_enable";

@implementation QJMPreDefinition

+ (NSArray *)supportedFileTypes {
  return @[ QJMSupportFileTypeOCHeader, QJMSupportFileTypeSwiftSource ];
}

+ (NSArray *)swiftSupportedCommands {
  return @[ QJMObjectMapperIdentifier ];
}

+ (NSArray *)OCSupportedCommands {
  return @[ QJMMantleIdentifier, QJMYYModelIdentifier ];
}

@end
