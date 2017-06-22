//
//  QJMCommandHandleError.h
//  QuickJsonMappingSourceEditor
//
//  Created by 刘金林 on 2017/6/22.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QJMCommandHandleError : NSObject

+ (NSError *)sourceFileTypeError;
+ (NSError *)sourceCommandTypeError;
+ (NSError *)sourceFileContentNoPropertyError;
+ (NSError *)sourceFileContentStructureError;

@end
