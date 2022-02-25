//
//  PreferenceManager.swift
//  Preferences
//
//  Created by yupao_ios_macmini05 on 2021/11/18.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation

// MARK: 偏好管理器
public final class PreferenceManager {
    /// 单例
    public static let shared = PreferenceManager()

    private init() {}

    let defaults = UserDefaults.standard

    /// 用户ID生成（isPublic为false时必须实现）
    public var userId: (() -> String?) = {
        return nil
    }

    // 默认值池
    private var defaultPreferences: [String: Any] = [:]

    /// 添加到默认池，不会重复添加
    private func addDefaultPreferences<T>(key: Key<T>) {
        // 有默认值则加入默认值池
        if let defaultValue = key.defaultValue,
           !defaultPreferences.keys.contains(where: { $0 == key.fullKey }) {
            
            defaultPreferences[key.fullKey] = defaultValue
            let defaultValues: [String: Any] = defaultPreferences.reduce([:]) {
                var dictionary = $0
                dictionary[$1.key] = $1.value
                return dictionary
            }
            defaults.register(defaults: defaultValues)
        }
    }

    /// 清空用户信息
    public func clearUser(by userId: String) {
        // 清空UserDefaults
        let dict = defaults.dictionaryRepresentation()
        dict.forEach { key, _ in
            if key.contains(userId) {
                defaults.removeObject(forKey: key)
            }
        }
        defaults.synchronize()
        // 清空归档
        let folderURL = PreferenceManager.folderURL(isPublic: false, userId: userId)
        do {
            try FileManager.default.removeItem(at: folderURL)
        }catch {
            // 可能是并没有创建文件夹，所以清空失败
            debugPrint("归档清空失败：\(error)")
        }
        
    }
    
    
    /// 清空所有数据
    public func clearAll() {
        // 清空UserDefaults
        let dict = defaults.dictionaryRepresentation()
        dict.forEach { key, _ in
            defaults.removeObject(forKey: key)
        }
        defaults.synchronize()
        // 清空归档
        let folderURL = PreferenceManager.folderURL(isPublic: true, userId: nil)
        let url = folderURL.deletingLastPathComponent()
        do {
            try FileManager.default.removeItem(at: url)
        }catch {
            debugPrint("归档清空失败")
        }
    }
    
}

// MARK: 偏好设置管理器 - 下标类型扩展
public extension PreferenceManager {
    
    // MARK: 数据类型 - Any?
    subscript(key: Key<Any>) -> Any? {
        get {
            switch key.storageMode {
            case .UserDefaults:
                return defaults.object(forKey: key.fullKey) ?? key.defaultValue
            case .Archive:
                return getArchiveData(url: key.fullURL) ?? key.defaultValue
            default:
                fatalError("Unsupport data type!")
            }
        }
        set {
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - URL?
    subscript(key: Key<URL>) -> URL? {
        get {
            switch key.storageMode {
            case .UserDefaults:
                return defaults.url(forKey: key.fullKey) ?? key.defaultValue
            case .Archive:
                return getArchiveData(url: key.fullURL) as? URL ?? key.defaultValue
            default:
                fatalError("Unsupport data type!")
            }
            
        }
        set {
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - [Any]?
    subscript(key: Key<[Any]>) -> [Any]? {
        get {
            switch key.storageMode {
            case .UserDefaults:
                return defaults.array(forKey: key.fullKey) ?? key.defaultValue
            case .Archive:
                return getArchiveData(url: key.fullURL) as? [Any]  ?? key.defaultValue
            default:
                fatalError("Unsupport data type!")
            }
        }
        set {
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - [String: Any]?
    subscript(key: Key<[String: Any]>) -> [String: Any]? {
        get {
            switch key.storageMode {
            case .UserDefaults:
                return defaults.dictionary(forKey: key.fullKey) ?? key.defaultValue
            case .Archive:
                return getArchiveData(url: key.fullURL) as? [String: Any] ?? key.defaultValue
            default:
                fatalError("Unsupport data type!")
            }
        }
        set {
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - String?
    subscript(key: Key<String>) -> String? {
        get {
            switch key.storageMode {
            case .UserDefaults:
                return defaults.string(forKey: key.fullKey) ?? key.defaultValue
            case .Archive:
                return getArchiveData(url: key.fullURL) as? String  ?? key.defaultValue
            default:
                fatalError("Unsupport data type!")
            }
            
        }
        set {
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - [String]?
    subscript(key: Key<[String]>) -> [String]? {
        get {
            switch key.storageMode {
            case .UserDefaults:
                return defaults.stringArray(forKey: key.fullKey) ?? key.defaultValue
            case .Archive:
                return getArchiveData(url: key.fullURL) as? [String]  ?? key.defaultValue
            default:
                fatalError("Unsupport data type!")
            }
        }
        set {
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - Data?
    subscript(key: Key<Data>) -> Data? {
        get {
            switch key.storageMode {
            case .UserDefaults:
                return defaults.data(forKey: key.fullKey) ?? key.defaultValue
            case .Archive:
                return getArchiveData(url: key.fullURL) as? Data  ?? key.defaultValue
            default:
                fatalError("Unsupport data type!")
            }
        }
        set {
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - Bool
    subscript(key: Key<Bool>) -> Bool {
        get {
            guard key.storageMode == .UserDefaults else { fatalError("Unsupport data type!") }
            return defaults.bool(forKey: key.fullKey)
        }
        set {
            guard key.storageMode == .UserDefaults else { fatalError("Unsupport data type!") }
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - Int
    subscript(key: Key<Int>) -> Int {
        get {
            guard key.storageMode == .UserDefaults else { fatalError("Unsupport data type!") }
            return defaults.integer(forKey: key.fullKey)
        }
        set {
            guard key.storageMode == .UserDefaults else { fatalError("Unsupport data type!") }
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - Float
    subscript(key: Key<Float>) -> Float {
        get {
            switch key.storageMode {
            case .UserDefaults:
                return defaults.float(forKey: key.fullKey)
            default:
                fatalError("Unsupport data type!")
            }
        }
        set {
            guard key.storageMode == .UserDefaults else { fatalError("Unsupport data type!") }
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - Double
    subscript(key: Key<Double>) -> Double {
        get {
            guard key.storageMode == .UserDefaults else { fatalError("Unsupport data type!") }
            return defaults.double(forKey: key.fullKey)
        }
        set {
            guard key.storageMode == .UserDefaults else { fatalError("Unsupport data type!") }
            set(key: key, data: newValue)
        }
    }
    
    // MARK: 数据类型 - Date
    subscript(key: Key<Date>) -> Date? {
        // 注意：Date虽然实现了Codable协议，但是在低版本的iOS系统中无法解析，故需要单独写
        get {
            switch key.storageMode {
            case .UserDefaults:
                return defaults.object(forKey: key.fullKey) as? Date ?? key.defaultValue
            case .Archive:
                return getArchiveData(url: key.fullURL) as? Date ?? key.defaultValue
            default:
                fatalError("Unsupport data type!")
            }
        }
        set {
            set(key: key, data: newValue)
        }
    }

    // MARK: 数据类型 - Codable
    subscript<T>(key: Key<T>) -> T? where T: Codable {
        get {
            switch key.storageMode {
            case .UserDefaults:
                guard let data = defaults.data(forKey: key.fullKey),
                      let model = try? JSONDecoder().decode(T.self, from: data)
                else { return key.defaultValue }
                return model
            case .Archive:
                guard let data = getArchiveData(url: key.fullURL) as? Data,
                      let model = try? JSONDecoder().decode(T.self, from: data) else { return key.defaultValue }
                return model
            default:
                fatalError("Unsupport data type!")
            }
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            set(key: key, data: data)
        }
    }
    
    // MARK: 数据类型 - Codable列表
    subscript<T>(key: Key<[T]>) -> [T]? where T: Codable {
        get {
            switch key.storageMode {
            case .UserDefaults:
                guard let data = defaults.data(forKey: key.fullKey),
                      let model = try? JSONDecoder().decode(Array<T>.self, from: data)
                else { return key.defaultValue }
                return model
            case .Archive:
                guard let data = getArchiveData(url: key.fullURL) as? Data,
                      let model = try? JSONDecoder().decode(Array<T>.self, from: data) else { return key.defaultValue }
                return model
            default:
                fatalError("Unsupport data type!")
            }
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            set(key: key, data: data)
        }
    }
    
    // MARK: 数据类型 - HandyJSON
//    subscript<T>(key: Key<T>) -> T? where T: HandyJSON {
//        get {
//            guard key.storageMode == .Archive else { fatalError("Unsupport data type!") }
//            let jsonStr = getArchiveData(url: key.fullURL) as? String
//            return T.deserialize(from: jsonStr) ?? key.defaultValue
//        }
//        set {
//            guard key.storageMode == .Archive else { fatalError("Unsupport data type!") }
//            let jsonStr = newValue?.toJSONString()
//            set(key: key, data: jsonStr)
//        }
//    }
//
//    // MARK: 数据类型 - HandyJSON列表
//    subscript<T>(key: Key<[T]>) -> [T]? where T: HandyJSON {
//        get {
//            guard key.storageMode == .Archive else { fatalError("Unsupport data type!") }
//            let jsonStr = getArchiveData(url: key.fullURL) as? String
//            return [T].deserialize(from: jsonStr)?.filter({ $0 != nil }).map({ $0! }) ?? key.defaultValue
//        }
//        set {
//            guard key.storageMode == .Archive else { fatalError("Unsupport data type!") }
//            let jsonStr = newValue?.toJSONString()
//            set(key: key, data: jsonStr)
//        }
//    }
    
}

// MARK: 通用设置数据扩展
extension PreferenceManager {
    
    /// 通用设置数据扩展
    func set(key: BaseKey, data: Any?) {
        switch key.storageMode {
        case .UserDefaults:
            defaults.set(data, forKey: key.fullKey)
            defaults.synchronize()
        case .Archive:
            setArchiveData(url: key.fullURL, data: data)
        default:
            fatalError("Unsupport data type!")
        }
    }
}

// MARK: 偏好设置管理器 - 类扩展
public extension PreferenceManager {
    
    /// 存储方式
    enum StorageMode {
        /// UserDefaults（轻量数据）
        case UserDefaults
        /// 归档（重量数据）
        case Archive
        /// 未知
        case Unknow
    }
    
    // MARK: 唯一标识泛型支持
    /// 唯一标识泛型支持
    final class Key<T>: BaseKey {
        
        /// 默认值
        let defaultValue: T?
        
        /// 关联值方法
        static func associatedKey<T>(_ key: Key<T>, associatedValue: String) -> Key<T> {
            if !key.isAssociated {
                // 如果使用associatedKey，key的isAssociated必须为true
                fatalError("isAssociated must be true!")
            }
            key.setAssociatedValue(associatedValue)
            return key
        }
        
        /// 初始化方法
        /// - Parameters:
        ///   - name: 名称
        ///   - isPublic: 是否是公共
        ///   - defaultValue: 默认值，注意：若为自定义类型，请转换成UserDefaults可以直接存储的类型，直接存储会导致崩溃
        ///   - isAssociated: 是否有关联值
        ///   - storageMode: 存储模式
        public init(name: String, isPublic: Bool = true, isAssociated: Bool = false, defaultValue: T? = nil, storageMode: StorageMode = .UserDefaults) {
            self.defaultValue = defaultValue
            super.init(name: name, isPublic: isPublic, isAssociated: isAssociated, storageMode: storageMode)
            if !isAssociated {
                // 加入默认值池
                PreferenceManager.shared.addDefaultPreferences(key: self)
            }
        }
        
        /// 便捷初始化方法
        /// - Parameters:
        ///   - name: 名称
        ///   - userAssociation: 是否关联用户，与isPublic相反，便于理解
        ///   - defaultValue: 默认值，注意：若为自定义类型，请转换成UserDefaults可以直接存储的类型，直接存储会导致崩溃
        ///   - isAssociated: 是否有关联值
        ///   - storageMode: 存储模式
        convenience init(name: String, userAssociation: Bool, isAssociated: Bool = false, defaultValue: T? = nil, storageMode: StorageMode = .UserDefaults) {
            self.init(name: name, isPublic: !userAssociation,isAssociated: isAssociated, defaultValue: defaultValue, storageMode: storageMode)
        }
        
        /// 设置关联值， isAssociated为true时必须设置
        func setAssociatedValue(_ value: String) {
            self.associatedValue = value
            // 加入默认值池
            PreferenceManager.shared.addDefaultPreferences(key: self)
        }
    }

    // MARK: 唯一标识
    /// 唯一标识
    class BaseKey: Hashable {
        /// 名称
        let name: String
        /// 是否是公共的
        let isPublic: Bool
        /// 存储方式
        let storageMode: StorageMode
        
        /// 是否关联值
        let isAssociated: Bool
        /// 关联值
        var associatedValue: String? = nil
        
        /// 初始化
        /// - Parameters:
        ///   - name: 名称
        ///   - isPublic: 是否是公共
        ///   - isAssociated: 是否有关联值
        ///   - storageMode: 存储模式
        public init(name: String, isPublic: Bool = true, isAssociated: Bool = false, storageMode: StorageMode = .UserDefaults) {
            self.name = name
            self.isPublic = isPublic
            self.isAssociated = isAssociated
            self.storageMode = storageMode
        }
        
        /// 完整key
        var fullKey: String {
            var paths: [String] = []
            if !isPublic {
                if let userId = PreferenceManager.shared.userId() {
                    paths.append(userId)
                }else {
                    // 如果是非公共存储数据，则必须设置userId
                    fatalError("must set userId")
                }
            }
            paths.append(name)
            if isAssociated {
                if let associatedValue = associatedValue {
                    paths.append(associatedValue)
                }else {
                    // 如果是有关联值的，必须使用associatedKey去生成完整的Key
                    fatalError("must use associatedKey to generate Key!")
                }
            }
            let fullKey = paths.joined(separator: ".")
            return fullKey
        }
        
        /// 完整路径, 用于归档路径
        var fullURL: URL {
            var paths: [String] = []
            paths.append(PreferenceManager.folderURL(isPublic: isPublic, userId: PreferenceManager.shared.userId()).path)
            paths.append(name)
            if isAssociated {
                if let associatedValue = associatedValue {
                    paths.append(associatedValue)
                }else {
                    // 如果是有关联值的，必须使用associatedKey去生成完整的Key
                    fatalError("must use associatedKey to generate Key!")
                }
            }
            let suffix = ".archive"
            let fullPath = paths.joined(separator: "/") + suffix
            return URL(fileURLWithPath: fullPath)
        }

        public static func == (lhs: BaseKey, rhs: BaseKey) -> Bool {
            return lhs.name.hashValue == rhs.name.hashValue &&
            lhs.isPublic.hashValue == rhs.isPublic.hashValue &&
            lhs.isAssociated.hashValue == rhs.isAssociated.hashValue &&
            lhs.associatedValue.hashValue == rhs.associatedValue.hashValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(isPublic)
            hasher.combine(isAssociated)
            hasher.combine(associatedValue)
        }
    }
}

// MARK: 偏好设置管理器 - 归档扩展
extension PreferenceManager {
    
    /// 归档文件夹路径
    static func folderURL(isPublic: Bool, userId: String?) -> URL {
        var paths: [String] = []
        
        guard let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last else {
            fatalError("can not find directory")
        }
        paths.append(documentPath)
        paths.append("Archive")
        if isPublic {
            paths.append("Common")
        }else {
            if let userId = userId {
                paths.append(userId)
            }else {
                // 如果是非公共存储数据，则必须设置userId
                fatalError("must set userId")
            }
        }
        let folderPath = paths.joined(separator: "/")
        return URL(fileURLWithPath: folderPath)
    }
    
    // MARK: 保存归档数据
    /// 保存归档数据
    @discardableResult
    func setArchiveData(url: URL, data: Any?) -> Bool {
        do {
            var coding: Data
            if #available(iOS 11.0, *) {
                coding = try NSKeyedArchiver.archivedData(withRootObject: data as Any, requiringSecureCoding: true)
            } else {
                coding = NSKeyedArchiver.archivedData(withRootObject: data as Any)
            }
            do {
                // 如果有未创建的目录路径，保存会出错
                let folderPath = url.deletingLastPathComponent()
                if !FileManager.default.isWritableFile(atPath: folderPath.path) {
                    print("归档写入本地失败: 目录无写入权限")
                }
                if !FileManager.default.fileExists(atPath: folderPath.path) {
                    try FileManager.default.createDirectory(atPath: folderPath.path, withIntermediateDirectories: true, attributes: nil)
                }
                try coding.write(to: url)
                return true
            } catch {
                print("归档写入本地失败: \(error)")
                return false
            }
        } catch  {
            print("归档写入本地失败: \(error)")
            return false
        }
    }
    
    // MARK: 获取归档数据
    /// 获取归档数据
    func getArchiveData(url: URL) -> Any? {
        do {
            let data = try Data(contentsOf: url)
            let model: Any? = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
            return model
        } catch {
            print("获取归档数据失败: \(error)")
            return nil
        }
        
    }
    
    // MARK: 删除归档数据
    /// 删除归档数据
    func removeArchiveData(url: URL) {
        setArchiveData(url: url, data: nil)
    }
    
}
