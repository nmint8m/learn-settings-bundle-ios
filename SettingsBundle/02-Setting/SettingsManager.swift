//
//  SettingsManager.swift
//  SettingsBundle
//
//  Created by Tam Nguyen M. on 3/28/19.
//  Copyright © 2019 Tam Nguyen M. All rights reserved.
//

import Foundation

let ud = UserDefaults.standard

/// For saving app state to User defaults
///
/// - kBuild: Build number
/// - kVersion: Version  number
/// - kCopyright: Copyright description
/// - kDidOpenApp: Clarifying app was opend or not
/// - kEndpoint: Endpoint
enum InfoKey: String {
    // IP = Info.plist, defined the same as in Info.plist
    case kBuild = "IP_APP_BUILD"
    case kVersion = "IP_APP_VERSION"
    case kCopyright = "IP_APP_COPYRIGHT"

    // K = Other keys, save app state
    case kDidOpenApp = "K_DID_OPEN_APP"
    case kEndpoint = "K_APP_ENDPOINT"
}

final class SettingsManager {

    /// Defined the same as in Root.plist
    ///
    /// - kBuild: Build number
    /// - kVersion: Version  number
    /// - kCopyright: Copyright description
    /// - kReset: Clarifying reset or not
    /// - kEndpoint: Endpoint
    enum SettingKey: String {
        // SK = SettingKey
        // Keys which have constant value
        case kBuild = "SK_APP_BUILD"
        case kVersion = "SK_APP_VERSION"
        case kCopyright = "SK_APP_COPYRIGHT"

        // Keys which have changing value
        case kReset = "SK_RESET_APP"
        case kEndpoint = "SK_APP_ENDPOINT"
    }

    static let shared = SettingsManager()

    private init() {}

    /// Config app setting when starting app / after restarting app
    func configAppSetting() {
        // Config when reset is true, reset all app
        if ud.bool(forKey: SettingKey.kReset.rawValue) {
            resetUserDefaults()
        }

        // Config titles: build number, version number, copyright info
        // Bind from Info.plist to Settings
        change(getValueWith: .kBuild,
               setForSettingValueWith: .kBuild)
        change(getValueWith: .kVersion,
               setForSettingValueWith: .kVersion)
        change(getValueWith: .kCopyright,
               setForSettingValueWith: .kCopyright)

        // Bind from User defaults to Setting
        if let endpoint = getSettingStringValue(forInfoKey: .kEndpoint) {
            change(endpoint, forSettingValueWith: .kEndpoint)
        } else {
            let defaultValue = "https://server0.t8m.dev"
            change(defaultValue, forSettingValueWith: .kEndpoint)
            change(defaultValue, forInfoValueWith: .kEndpoint)
        }

        // Config observer
        configObserver()
    }

    /// Observer values in user defaults changing
    private func configObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(udValuesDidChange),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
    }

    /// Handle values in user defaults changing
    @objc private func udValuesDidChange() {
        // If kReset = true, then reset and restart app
        if ud.bool(forKey: SettingKey.kReset.rawValue) {
            resetUserDefaults()
            AppDelegate.shared.restart()
            return
        }

        if let newEndpoint = getSettingStringValue(forSettingKey: SettingsManager.SettingKey.kEndpoint),
            let oldEndpoint = getSettingStringValue(forInfoKey: InfoKey.kEndpoint),
            newEndpoint != oldEndpoint {
            change(newEndpoint, forInfoValueWith: .kEndpoint)
        }
    }

    /// Reset all data in user defaults, keys are defined in InfoKey
    private func resetUserDefaults() {
        change(false, forSettingValueWith: .kReset)
        change(nil, forSettingValueWith: .kEndpoint)

        change(nil, forInfoValueWith: .kDidOpenApp)
        change(nil, forInfoValueWith: .kEndpoint)
    }

    /// Get value from file Infor.plist with ipKey, then set for user defaults value with udKey
    ///
    /// - Parameters:
    ///   - ipKey: Key defined for InforKey Info.plist value
    ///   - udKey: Key defined for user defaults value
    private func change(getValueWith ipKey: InfoKey, setForSettingValueWith sKey: SettingKey) {
        guard let ipValue = getInfoPlistStringValue(forInfoKey: ipKey) else { return }
        change(ipValue, forSettingValueWith: sKey)
    }

    /// Get value from Info.plist file
    ///
    /// - Parameter key: Defined in InforKey ~ Info.plist file
    /// - Returns: String value
    private func getInfoPlistStringValue(forInfoKey key: InfoKey) -> String? {
        guard let dic = Bundle.main.infoDictionary,
            let value = dic[key.rawValue] as? String else { return nil }
        return value
    }

    /// If value = nil then remove that key, if not then change it
    ///
    /// - Parameters:
    ///   - value: New value
    ///   - key: Defined in SettingKey
    func change(_ value: Any?, forSettingValueWith key: SettingKey) {
        if let value = value {
            ud.set(value, forKey: key.rawValue)
        } else {
            ud.removeObject(forKey: key.rawValue)
        }
    }

    /// Get string value from setting
    ///
    /// - Parameter key: Defined in SettingKey
    /// - Returns: String value
    func getSettingStringValue(forSettingKey key: SettingKey) -> String? {
        return getStringValue(for: key.rawValue)
    }

    /// If value = nil then remove that key, if not then change it
    ///
    /// - Parameters:
    ///   - value: New value
    ///   - key: Defined in InfoKey
    func change(_ value: Any?, forInfoValueWith key: InfoKey) {
        if let value = value {
            ud.set(value, forKey: key.rawValue)
        } else {
            ud.removeObject(forKey: key.rawValue)
        }
    }

    /// Get string value from user default
    ///
    /// - Parameter key: Defined in InfoKey
    /// - Returns: String value
    func getSettingStringValue(forInfoKey key: InfoKey) -> String? {
        return getStringValue(for: key.rawValue)
    }

    /// Get string value for key
    ///
    /// - Parameter key: Key
    /// - Returns: String value
    private func getStringValue(for key: String) -> String? {
        if let value = ud.string(forKey: key), value != "" {
            return value
        } else {
            return nil
        }
    }
}
