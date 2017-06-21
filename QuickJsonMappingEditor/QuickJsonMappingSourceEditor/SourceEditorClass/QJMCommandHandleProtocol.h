//
//  QJMCommandHandleProtocol.h
//  QuickJsonMappingEditor
//
//  Created by 刘金林 on 2017/6/21.
//  Copyright © 2017年 LJL. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QJMCommandHandleProtocol <NSObject>

@required //简化起见，全部设置为必须实现

///performCommandWithInvocation 头部调用
- (void)commondDidArrivedWithInvocation:(XCSourceEditorCommandInvocation *)invocation;

- (void)scanWithLine:(NSString *)oriLine purifiedLine:(NSString *)purifiedLine;

@end
