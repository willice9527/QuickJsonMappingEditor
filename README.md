# QuickJsonMappingSourceEditor
一款Xcode source editor，用于减轻使用Mantle/YYModel/ObjectMapper 此类ORM库时手写映射关系的负担

### Mantle

这里是一段用于演示的OC Model代码
```objc
@interface QJMOCSubModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, copy) NSArray <NSString *>*tips;

@end

@interface OCModel : NSObject

@property (nonatomic, copy, class) NSString *classTitle;
@property (nonatomic, copy, readonly) NSString *readTitle;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSUUID *uid;
@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, copy) NSArray <QJMOCSubModel *>*subModels;
@property (nonatomic, strong) QJMOCSubModel *subModel;
@property (nonatomic, copy) NSDictionary <NSString *,QJMOCSubModel *>*cacheSubModels;

@end

```
![MantleDemo~](https://github.com/willice9527/QuickJsonMappingEditor/blob/master/MantleDemo.gif)

###### Mantle相关自定义设置（可以在`MantlePreference.plist`中自行修改）
=============
参数名 |  含义
------|------
EXTKeyPathCoding | 在生成的`JSONKeyPathsByPropertyKey`这个方法中，是否使用`@keypath`宏
KeyPathPrefixTransformer | 在为某个属性生成自定义`transformer`时，是否使用`keypath+JSONTransformer`这个方式
SelfDefinedClassRegular | 一组正则表达式，如何识别自定义类
DefaultTransformerMap | 预先设置好的类型与自定义`transformer`名的对应关系

比如，如上的例子中，添加一个`^QJM\w+$`用来识别自定义类.添加`NSUUID`类型默认使用`MTLUUIDValueTransformerName`这个名称标识的`transformer`

`QJMOCSubModel`均为基本类型，其中`tips`为一个数组，但由于内部元素均为`NSString`，故无需自定义`transformer`

**重点说明OCModel中各属性的情况**

1. `classTitle`类属性，不生成映射关系
2. `readTitle`只读属性，不生成映射关系
3. `title`基本的json合法类型
4. `uid`需生成自定义`transformer`

```objc
+ (NSValueTransformer *)uidJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLUUIDValueTransformerName];
}
```

5. `count`KVO自动转换
6. `subModels`数组，且同时内部元素为自定义类型，需生成自定义`transformer`

```objc
+ (NSValueTransformer *)subModelsJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[QJMOCSubModel class]];
}
```

7. `subModel`为自定义类型，需生成自定义`transformer`

```objc
+ (NSValueTransformer *)subModelJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[QJMOCSubModel class]];
}
```

8. `cacheSubModels`dictionary,貌似`mantle`中没有处理

**最终生成的内容如下**

```objc
/*		mantle map method copy begin		

#pragma mark - mantle keypath map

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	OCModel *model = nil;
	return @{
		@keypath(model.title)          : @"title",
		@keypath(model.uid)            : @"uid",
		@keypath(model.count)          : @"count",
		@keypath(model.subModel)       : @"subModel",
		@keypath(model.subModels)      : @"subModels",
		@keypath(model.cacheSubModels) : @"cacheSubModels",
	};
}

#pragma mark - mantle custom class / predefined transformer

+ (NSValueTransformer *)uidJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLUUIDValueTransformerName];
}

+ (NSValueTransformer *)subModelJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:[QJMOCSubModel class]];
}

+ (NSValueTransformer *)subModelsJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:[QJMOCSubModel class]];
}

		mantle map method copy end		*/
```

直接将生成的内容复制进.m文件即可
	
### YYModel
```objc

```	
![YYModelDemo~](https://github.com/willice9527/QuickJsonMappingEditor/blob/master/YYModelDemo.gif)

### Swift
```swift

```	
![ObjectMapperDemo~](https://github.com/willice9527/QuickJsonMappingEditor/blob/master/ObjectMapperDemo.gif)

使用方法
==============
直接下载本工程，编译运行，即可在Xcode顶部的`Editor`菜单下最下面看到`QuickJsonMappingSourceEditor`，根据需要选择对应功能即可。

重复点击，最新生成的内容会覆盖之前产生的内容。

**`objective-c`仅可在.h文件中执行操作**

**个菜单命令都表明了适用的源文件类型**

以上请注意，留意源码编辑区顶部的报错信息

![Setup~](https://github.com/willice9527/QuickJsonMappingEditor/blob/master/Setup.gif)


系统要求
==============
该项目最低支持 `macOS 10.12` 和 `Xcode 8.0`。


许可证
==============
MIT
