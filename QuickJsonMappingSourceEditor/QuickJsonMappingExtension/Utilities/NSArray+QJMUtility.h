//
//  NSArray+QJMUtility.h
//  QuickJsonMappingSourceEditor
//
//  Created by 刘金林 on 2017/6/23.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^QJMFilterHandler)(id item);

@interface NSArray (QJMUtility)

- (NSArray *)qjm_filterWithHandler:(QJMFilterHandler)handler;

@end

NS_ASSUME_NONNULL_END
