# QuickJsonMappingSourceEditor
> 一款Xcode source editor，用于减轻使用Mantle/YYModel/ObjectMapper 此类ORM库时手写映射关系的负担

## Mantle

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

**Mantle相关自定义设置（可以在`MantlePreference.plist`中自行修改）**

参数名 |  含义
------|------
EXTKeyPathCoding | 在生成的`JSONKeyPathsByPropertyKey`这个方法中，是否使用`@keypath`宏
KeyPathPrefixTransformer | 在为某个属性生成自定义`transformer`时，是否使用`keypath+JSONTransformer`这个方式
SelfDefinedClassRegular | 一组正则表达式，如何识别自定义类
DefaultTransformerMap | 预先设置好的类型与自定义`transformer`名的对应关系

> 比如，如上的例子中，添加一个`^QJM\w+$`用来识别自定义类.添加`NSUUID`类型默认使用`MTLUUIDValueTransformerName`这个名称标识的`transformer`

> `QJMOCSubModel`均为基本类型，其中`tips`为一个数组，但由于内部元素均为`NSString`，故无需自定义`transformer`

> *如果在针对当前文件中的`model`，对使用`@keypath`宏有特别设置，可以在当前文件中定义宏`Keypath_Coding_Enable`来启用或 `Keypath_Coding_Disable`来禁用*

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
	
## YYModel

> 用于演示的OC Model代码参照`mantle`部分

	
![YYModelDemo~](https://github.com/willice9527/QuickJsonMappingEditor/blob/master/YYModelDemo.gif)

**YYModel相关自定义设置（可以在`YYModelPreference.plist`中自行修改）**

参数名 |  含义
------|------
SelfDefinedClassRegular | 一组正则表达式，如何识别自定义类
AutoTransformTypes | `YYModel`中自动支持的类型转换，只添加了最常用的部分

> 这里，只有当一个属性既不是自定义类型，也不包含在自动转换的类型列表中时，才会添加自行`transform`相关方法

> 比如，如上的例子中，只有`uid`这个属性需要自行`transform`

**`YYModel`中含有一些不常用的设置（仅针对特定文件）**

参数名 |  含义
------|------
blacklist_enable | 生成黑名单空列表
whitelist_enable | 生成白名单空列表，优先级高于黑名单
copy_enable | 生成NSCopy相关方法
compare_enable | 生成NSCompare相关方法
transform_enable | 生成自行`transform`相关方法


*开启方式为在文件头部定义上述列表中的宏*

**最终生成的内容如下**

```objc

/*		YYModel map method copy begin		
#pragma mark - custom property map

+ (NSDictionary *)modelCustomPropertyMapper {
	return @{
		@"title"    : @"title",
		@"uid"      : @"uid",
		@"count"    : @"count",
		@"subModel" : @"subModel",
	};
}

#pragma mark - custom container map

+ (NSDictionary *)modelContainerPropertyGenericClass {
	return @{
		@"subModels"      : [QJMOCSubModel class],
		@"cacheSubModels" : [QJMOCSubModel class],
	};
}

#pragma mark - custome transform

- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic {
	//-- custom transform for: uid --
	return dic;
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
	//-- custom transform for: uid --
	return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
	//-- custom transform for: uid --
	return YES;
}

#pragma mark - NSCoder

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[self yy_modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	return [self yy_modelInitWithCoder:aDecoder];
}

#pragma mark - description

- (NSString *)description {
	return [self yy_modelDescription];
}
		YYModel map method copy end		*/

```


## ObjectMapper

首先贴上一段用于演示的`swift`源码
```swift
class SubModel: Mappable {
  var name: String?
  var age: Int?
  var tips: [String] = []
}

class Model: Mappable {
  static var classTitle: String?
  var readTitle: String {
    return "hehe"
  }
  var data: Data
  var url: URL
  var date: Date
  var color: UIColor
  var title: String?
  var count: Int?
  var subModels: [SubModel] = []
  var cacheSubModels: [String : SubModel] = [:]
}

```	
![ObjectMapperDemo~](https://github.com/willice9527/QuickJsonMappingEditor/blob/master/ObjectMapperDemo.gif)

** *首先要声明一点，对于`swift`的支持还相当脆弱，主要是因为`swift`不同于OC那样把头文件独立出来* **

**ObjectMapper相关自定义设置（可以在`ObjectMapperPreference.plist`中自行修改）**

参数名 |  含义
------|------
DefaultTransformerMap | `ObjectMapperDemo`中自带的`transformer`（目前只添加了有限的几个）

如上的例子中`Data,URL,Date,UIColor`会使用`transformer`

最终生成的内容如下

```objc

/*		ObjectMapper map method begin		

// init with map

	required init?(map: Map) {

	};

// property map

	func mapping(map: Map) {
		name <- map["name"]
		age  <- map["age"]
		tips <- map["tips"]
	};
		ObjectMapper map method end		*/

/*		ObjectMapper map method begin		

// init with map

	required init?(map: Map) {

	};

// property map

	func mapping(map: Map) {
		data           <- (map["data"], DataTransform())
		url            <- (map["url"], URLTransform())
		date           <- (map["date"], DateTransform())
		color          <- (map["color"], HexColorTransform())
		title          <- map["title"]
		count          <- map["count"]
		subModels      <- map["subModels"]
		cacheSubModels <- map["cacheSubModels"]
	};
		ObjectMapper map method end		*/

```

** ObjectMapper中使用要注意如下几点 **

1.  `Mappable`协议最好放在：之后,以免遵守的协议过多，导致换行，`Mappable`仅在同一行中可以识别
2.  对于`compute property` 和 自定义`getter setter` 及带有`willset didset` 方法的`property`，属性声明中的方法中的属性会被误识别，还没有精确处理
3.  目前所有生成的内容都插入到文件底部

使用方法
==============
直接下载本工程，编译运行，即可在Xcode顶部的`Editor`菜单下最下面看到`QuickJsonMappingSourceEditor`，根据需要选择对应功能即可。

> 重复点击，最新生成的内容会覆盖之前产生的内容。

1. **`objective-c`仅可在.h文件中执行操作**

2. **个菜单命令都表明了适用的源文件类型**

以上请注意，留意源码编辑区顶部的报错信息

![Setup~](https://github.com/willice9527/QuickJsonMappingEditor/blob/master/Setup.gif)


系统要求
==============
该项目最低支持 `macOS 10.12` 和 `Xcode 8.0`。


许可证
==============
MIT
