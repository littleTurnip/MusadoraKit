//
//  KeychainUserTokenStore.swift
//  MusadoraKit
//
//  Created by Codex on 02/07/26.
//

import Foundation
@preconcurrency import Security

protocol UserTokenStoring {
  func token() -> String?
  func setToken(_ token: String?)
}

struct KeychainUserTokenStore: UserTokenStoring {
  private let service = "com.musadorakit.user-token"
  private let account = "media-user-token"

  func token() -> String? {
    if let token = keychainToken() {
      return token
    }

    guard let legacyToken = UserDefaults.standard.string(forKey: MusadoraKit.userTokenKey) else {
      return nil
    }

    if storeInKeychain(legacyToken) {
      UserDefaults.standard.removeObject(forKey: MusadoraKit.userTokenKey)
    }

    return legacyToken
  }

  func setToken(_ token: String?) {
    guard let token else {
      deleteKeychainToken()
      UserDefaults.standard.removeObject(forKey: MusadoraKit.userTokenKey)
      return
    }

    _ = storeInKeychain(token)
    UserDefaults.standard.removeObject(forKey: MusadoraKit.userTokenKey)
  }

  private func keychainToken() -> String? {
    var query = baseQuery()
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)

    guard status == errSecSuccess,
          let data = item as? Data else {
      return nil
    }

    return String(data: data, encoding: .utf8)
  }

  private func storeInKeychain(_ token: String) -> Bool {
    let attributes: [String: Any] = [
      kSecValueData as String: Data(token.utf8),
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ]

    let updateStatus = SecItemUpdate(baseQuery() as CFDictionary, attributes as CFDictionary)
    if updateStatus == errSecSuccess {
      return true
    }

    guard updateStatus == errSecItemNotFound else {
      return false
    }

    var query = baseQuery()
    attributes.forEach { query[$0.key] = $0.value }

    return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
  }

  private func deleteKeychainToken() {
    SecItemDelete(baseQuery() as CFDictionary)
  }

  private func baseQuery() -> [String: Any] {
    [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account
    ]
  }
}
