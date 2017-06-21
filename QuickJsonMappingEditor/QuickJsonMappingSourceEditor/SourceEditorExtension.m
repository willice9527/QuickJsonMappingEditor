//
//  SourceEditorExtension.m
//  QuickJsonMappingSourceEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "SourceEditorExtension.h"
#import "QJMPreDefinition.h"

@implementation SourceEditorExtension

//do all the config here

/*
- (void)extensionDidFinishLaunching
{
    // If your extension needs to do any work at launch, implement this optional method.
}
*/

- (NSArray <NSDictionary <XCSourceEditorCommandDefinitionKey, id> *> *)commandDefinitions
{
  NSDictionary *propertyTemplate = @{ XCSourceEditorCommandNameKey : QJMTemplateKeyName,
                                    XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
                                    XCSourceEditorCommandIdentifierKey : QJMTemplateIdentifier,};
  
  NSDictionary *mantleCommand = @{ XCSourceEditorCommandNameKey : QJMMantleKeyName,
                                  XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
                                  XCSourceEditorCommandIdentifierKey : QJMMantleIdentifier,};
  
  NSDictionary *yymodelCommand = @{ XCSourceEditorCommandNameKey : QJMYYModelKeyName,
                                  XCSourceEditorCommandClassNameKey : @"SourceEditorCommand",
                                  XCSourceEditorCommandIdentifierKey : QJMYYModelIdentifier,};
  return @[ propertyTemplate, mantleCommand, yymodelCommand ];
}

@end
