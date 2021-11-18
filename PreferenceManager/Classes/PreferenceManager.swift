//
//  PreferenceManager.swift
//  Preferences
//
//  Created by yupao_ios_macmini05 on 2021/11/18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

/// 偏好设置管理器
public final class PreferenceManager {
    public static let shared = PreferenceManager()

    private init() {}

    let defaults = UserDefaults.standard

    /// 用户ID生成（isPublic为false时必须实现）
    public var userId: (() -> String) = {
        return "tourist"
    }

    // 默认值池
    var defaultPreferences: [PreferenceKeys: Any] = [:]

    /// 注册所有默认值
    private func registerDefaultPreferences() {
        let defaultValues: [String: Any] = defaultPreferences.reduce([:]) {
            var dictionary = $0
            dictionary[$1.key.fullKey] = $1.value
            return dictionary
        }
        defaults.register(defaults: defaultValues)
    }

    /// 添加默认值
    func addDefaultPreferences(key: PreferenceKeys) {
        // 有默认值则加入默认值池
        if let defaultValue = key.defaultValue {
            defaultPreferences[key] = defaultValue
            registerDefaultPreferences()
        }
    }

    /// 清空用户信息
    public func clearUser(by userId: String) {
        let dict = defaults.dictionaryRepresentation()
        dict.forEach { key, _ in
            if key.starts(with: userId + ".") {
                defaults.removeObject(forKey: key)
            }
        }
    }
}

public extension PreferenceManager {
    subscript(key: PreferenceKey<Any>) -> Any? {
        get { return defaults.object(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<URL>) -> URL? {
        get { return defaults.url(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<[Any]>) -> [Any]? {
        get { return defaults.array(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<[String: Any]>) -> [String: Any]? {
        get { return defaults.dictionary(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<String>) -> String? {
        get { return defaults.string(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<[String]>) -> [String]? {
        get { return defaults.stringArray(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<Data>) -> Data? {
        get { return defaults.data(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<Bool>) -> Bool {
        get { return defaults.bool(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<Int>) -> Int {
        get { return defaults.integer(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<Float>) -> Float {
        get { return defaults.float(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript(key: PreferenceKey<Double>) -> Double {
        get { return defaults.double(forKey: key.fullKey) }
        set {
            defaults.set(newValue, forKey: key.fullKey)
            defaults.synchronize()
        }
    }

    subscript<T>(key: PreferenceKey<T>) -> T? where T: Codable {
        get {
            guard let data = defaults.data(forKey: key.fullKey),
                  let model = try? JSONDecoder().decode(T.self, from: data)
            else { return nil }
            return model
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults.set(data, forKey: key.fullKey)
            defaults.synchronize()
        }
    }
}

/// 泛型支持
public final class PreferenceKey<T>: PreferenceKeys {}

/// 唯一白标识
public class PreferenceKeys: Hashable {
    /// 名称
    let name: String
    /// 是否是公共的
    let isPublic: Bool
    /// 默认值
    let defaultValue: Any?

    /// 初始化方法
    /// - Parameters:
    ///   - name: 名称
    ///   - isPublic: 是否是公共
    ///   - defaultValue: 默认值，注意：若为自定义类型，请转换成UserDefaults可以直接存储的类型，直接存储会导致崩溃
    public init(name: String, isPublic: Bool = true, defaultValue: Any? = nil) {
        self.name = name
        self.isPublic = isPublic
        self.defaultValue = defaultValue
        // 加入默认值池
        PreferenceManager.shared.addDefaultPreferences(key: self)
    }

    /// 完整key
    var fullKey: String {
        // isPublic为false时前面用userId分开，并用.分割
        let fullKey = isPublic ? name : PreferenceManager.shared.userId() + "." + name
        return fullKey
    }

    public static func == (lhs: PreferenceKeys, rhs: PreferenceKeys) -> Bool {
        return lhs.name.hashValue == rhs.name.hashValue && lhs.isPublic.hashValue == rhs.isPublic.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isPublic)
    }
}
