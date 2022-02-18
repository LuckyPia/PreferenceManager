# PreferenceManager

[![CI Status](https://img.shields.io/badge/iOS-10.0%2B-blueviolet)](https://travis-ci.org/LuckyPia/PreferenceManager)
[![Language](https://img.shields.io/badge/swift-5.0-ff69b4)](https://cocoapods.org/pods/PreferenceManager)
[![Version](https://img.shields.io/cocoapods/v/PreferenceManager.svg?style=flat)](https://cocoapods.org/pods/PreferenceManager)
[![License](https://img.shields.io/cocoapods/l/PreferenceManager.svg?style=flat)](https://cocoapods.org/pods/PreferenceManager)
[![Platform](https://img.shields.io/cocoapods/p/PreferenceManager.svg?style=flat)](https://cocoapods.org/pods/PreferenceManager)

## 简介
iOS用户偏好设置管理器

## 安装

```ruby
pod 'PreferenceManager'
```

## 使用
```swift
// 简化名称（全局配置）
let Preferences = PreferenceManager.shared

// 第一步，设置当前用户ID，设置一次
Preferences.userId = {
    // return UserManager.shared.userId
    return "123456"
}

// 第二步，配置key
extension PreferenceKeys {
    /// 是否登录
    static let isLogin = PreferenceKey<Bool>(name: "isLogin", userAssociation: true, defaultValue: false)
}

// 第三步，使用
// 1. 设置
Preferences[.userId] = "456"
// 2. 获取
let userId = Preferences[.userId]
```

#### 优点：
1. 支持用户命名空间，每个用户有自己的偏好数据
2. 配置一次到处使用
3. 使用泛型，不用额外转换
4. 可以设置默认值
5. 读入写出便捷
6. 支持多种数据类型，同时自定数据存储


## 更新日志
### 1.0.4
1. 增加关联值支持
2. 增加归档支持

### 1.0.3
1. Date解析支持
2. 补全注释

## 联系我

可以通过邮箱来联系我: 664454335@qq.com

## License

PreferenceManager is available under the MIT license. See the LICENSE file for more info.
