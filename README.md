# MLReleaseDetector

MLReleaseDetector is a page-based automatic memory leak detection tool on the iOS platform. It can automatically detect memory leaks during development, debugging, testing, or online, and give location hints for leaks in DEBUG mode, developers don’t need to spend extra time for this.

## Capability

MLReleaseDetector can automatically detect memory leaks including UIViewController, UIView, strongly referenced custom properties or instance variables.

### UIViewController

If a page is closed for 1 second and not released, an alert will appear indicating the class of the page that was not released.

### UIView

After the page is released for 1 second, an alert will appear if a view in the view-viewController satck has not released, and use `->` to connect the class name of the view in the View-ViewController stack.
The last element in the alert is the unreleased view.

### Strongly referenced custom properties or instance variables (hereafter called Object)

After the page is released for 1.5 second, an alert will appear if an Object in the ViewController reference satck has not released, and use `->` to connect the class name of the Object in the ViewController reference satck.
The last element in the alert is the unreleased Object.

### Supported languages

|Language|ViewController|View|Object|
|-|-|-|-|
|Objective-C|&check;|&check;|&check;|
|Swift|&check;|&check;|&cross;|

## Usage

1. Call the following method to enable memory leak detection before the rootViewController is initialized.

```objc
[MLReleaseDetector startupWithWhiteList:@[@"ClassAString", @"ClassBString"] leakCallback:^(NSString *leakMsg, NSString *pageName, VSLeakType leakType) {
    
}];
```

- Add the class name of the singleton to the whitelist, the whitelisted class will not be detected.
- When a leak is detected, an alert will be displayed (only in DEBUG mode) and the leakCallback will be called (both in DEBUG mode and Release mode).
- You can report leakMsg in leakCallback to the backend for leak statistics.
- If you only need to detect leaks in DEBUG mode, embed the code above in the DEBUG macro.

2. If the ViewController is cached by another ViewController and you have not called the UIViewController's addChildViewController method, please call the following method to change the detection timing of the subViewController.

```objc
[MLReleaseDetector addSubViewController:subViewController forMainViewController:mainViewController];
```
- If the above method is called before memory leak detection is enabled, it will do nothing.

## Delayed release

### Leak or delayed release

After the alert is displayed, open Xcode's Debug memory Graph.
- **Unreleased object is custom class**：Enter the class name of the unreleased object at the bottom left of xcode to filter, check whether the object is in memory, and then repeat to show the alert several times. If the number of objects of this class is increased, it is a memory leak. If there is always only 1, it is a single instance. If there is none, it is a delayed release.
- **Unreleased object is UIView class**：Enter the address of the unreleased object at the bottom left of xcode to filter, check whether the object is in memory, if it is, it is a memory leak. If it is not, it is a delayed release.

### How to deal with delayed release

If the class of the delayed-release object is added to the whitelist, all objects of this class will lose the ability to detect. If nothing is done, the leakMsg in leakCallback will be contaminated, so it is recommended to release the object in time.

## Example

Clone the repository and run the Demo project in the Example folder to see the effect.

## Installation

### CocoaPods
1. Add `pod 'MLReleaseDetector'` to your Podfile.
2. Run `pod install` or `pod update`.
3. Import \<MLReleaseDetector/MLReleaseDetector.h\>.

## Requirements

This library requires `iOS 9.0+`.

## Author

mazhipeng108@gmail.com

## License

MLReleaseDetector is available under the MIT license. See the LICENSE file for more info.



<br/><br/>
# 中文介绍

MLReleaseDetector是iOS平台下基于页面的自动内存泄漏检测工具。 它可以在开发、调试、测试过程中或者线上自动检测内存泄漏，并且在DEBUG模式下给出泄漏点的定位提示，不需要占用开发人员额外的时间。

## 能力

MLReleaseDetector可以自动检测内存泄漏，包括UIViewController，UIView，强引用的自定义属性或实例变量。

### UIViewController

页面关闭1秒之后，如果没有释放，将会弹窗提示没有释放的页面

### UIView

页面释放1秒之后，对页面的View-ViewController栈进行检测，将会弹窗提示没有释放的View，并用`->`将View-ViewController栈中View的类名连接起来，弹窗中最后一个元素为没有释放的View。

### 强引用的自定义属性或实例变量（后续称之为Object）

页面释放1.5秒之后，对页面持有的所有Object进行检测，将会弹窗提示没有释放且没有被其他页面持有的Object，并用`->`将页面中Object的持有栈中的类名连接起来，其中最后一个元素为没有释放的Object。

### 支持的语言

|Language|ViewController|View|Object|
|-|-|-|-|
|Objective-C|&check;|&check;|&check;|
|Swift|&check;|&check;|&cross;|

## 使用方法

1. 在根视图控制器初始化之前调用如下方法开启内存泄漏检测。
```objc
[MLReleaseDetector startupWithWhiteList:@[@"ClassAString", @"ClassBString"] leakCallback:^(NSString *leakMsg, NSString *pageName, VSLeakType leakType) {
    
}];
```

- 将单例添加到白名单，添加到白名单的类将不会进行检测。
- 当检测到泄漏之后会弹窗提示（只会在DEBUG模式下弹窗）并回调leakCallback（DEBUG和Release模式下都会回调）。
- 可以在leakCallback中上报leakMsg给后台做泄漏统计。
- 如果只需要在DEBUG模式检测泄漏，请将上面的代码嵌入DEBUG宏中。

2. 如果ViewController被其他页面缓存，并且你没有调用UIViewController的addChildViewController方法，请调用如下方法以变更subViewController的检测时机。
```objc
[MLReleaseDetector addSubViewController:subViewController forMainViewController:mainViewController];
```

- 如果在开启内存泄漏检测之前调用上述方法，它将不执行任何操作。

## 延迟释放

### 如何判断是泄漏还是延迟释放

显示弹窗之后，打开Xcode的Debug memory Graph。
- **未释放的对象为自定义的类**：在Xcode左下角输入未释放对象的类名进行筛选，查看对象是否在内存中，然后再重复显示弹窗几次，如果筛选出该类的对象个数递增，则是内存泄漏，如果永远只有1个，则是单例，如果1个都没有，则是延迟释放。
- **未释放的对象为系统的View**：在Xcode左下角输入未释放对象的地址进行筛选，查看对象是否在内存中，如果在则是内存泄漏，如果不在则是延迟释放。

### 延迟释放如何处理

如果把延迟释放的对象的类加到白名单，那么该类所有的对象都会失去检测的能力，如果不做任何处理，leakCallback中的leakMsg数据会被污染，所以建议把延迟释放的对象修改为及时释放。

## 示例

克隆本仓库，运行Example文件夹中的Demo工程，查看效果。

## 安装

### CocoaPods
1. 在 Podfile 中添加 `pod 'MLReleaseDetector'`。
2. 执行 `pod install` 或 `pod update`。
3. 导入 \<MLReleaseDetector/MLReleaseDetector.h\>。

## 系统要求

该项目最低支持 `iOS 9.0`。

## 作者

mazhipeng108@gmail.com

## 许可证

MLReleaseDetector 使用 MIT 许可证，详情见 LICENSE 文件。