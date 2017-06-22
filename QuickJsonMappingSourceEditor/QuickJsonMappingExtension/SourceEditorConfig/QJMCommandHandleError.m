//
//  QJMCommandHandleError.m
//  QuickJsonMappingSourceEditor
//
//  Created by 刘金林 on 2017/6/22.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import "QJMCommandHandleError.h"

@implementation QJMCommandHandleError

+ (NSError *)sourceFileTypeIMPError {
  return [self errorWithUserTip:@"Please use it in header file."];
}

+ (NSError *)sourceFileTypeOCError {
  return [self errorWithUserTip:@"Please use it in Objective-C header file."];
}

+ (NSError *)sourceFileTypeSwiftError {
  return [self errorWithUserTip:@"Please use it in swift file."];
}

+ (NSError *)sourceFileContentNoPropertyError {
  return [self errorWithUserTip:@"Please check if there is any property be defined."];
}

+ (NSError *)sourceFileContentStructureError {
  return [self errorWithUserTip:@"Class source code structure may have something wrong."];
}

+ (NSError *)errorWithUserTip:(NSString *)tip {
  NSParameterAssert(tip);
  return [NSError errorWithDomain:tip code:1024 userInfo:nil];
}

@end
