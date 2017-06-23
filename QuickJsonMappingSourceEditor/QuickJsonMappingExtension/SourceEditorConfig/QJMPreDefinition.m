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

NSString *const QJMJsonModelIdentifier = @"jinlin.liu.QuickJsonMappingSourceEditor.jsonmodel";
NSString *const QJMJsonModelKeyName = @"JsonModel(OC)";

NSString *const QJMObjectMapperIdentifier = @"jinlin.liu.QuickJsonMappingSourceEditor.objectmapper";
NSString *const QJMObjectMapperKeyName = @"ObjectMapper(Swift)";

///
NSString *const Prefix_Property = @"@property";
NSString *const Prefix_Interface = @"@interface";
NSString *const Prefix_Implementation = @"@implementation";
NSString *const Prefix_End = @"@end";
NSString *const Prefix_MacroDefinition = @"#define";

NSString *const KeypathCodeingEnable = @"Keypath_Coding_Enable";
NSString *const KeypathCodeingDisable = @"Keypath_Coding_Disable";

NSString *const QJMSupportFileTypeOCHeader = @"public.c-header";
NSString *const QJMSupportFileTypeSwiftSource = @"public.swift-source";

@implementation QJMPreDefinition

+ (NSArray *)supportedFileTypes {
  return @[ QJMSupportFileTypeOCHeader, QJMSupportFileTypeSwiftSource ];
}

+ (NSArray *)swiftSupportedCommands {
  return @[ QJMObjectMapperIdentifier ];
}

+ (NSArray *)OCSupportedCommands {
  return @[ QJMMantleIdentifier, QJMYYModelIdentifier, QJMJsonModelIdentifier ];
}

@end
