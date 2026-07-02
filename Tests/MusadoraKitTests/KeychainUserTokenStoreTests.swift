@testable import MusadoraKit
import Foundation
@preconcurrency import Security
import Testing

@Suite
struct KeychainUserTokenStoreTests {
  @Test
  func baseQueryUsesDataProtectionKeychain() {
    let store = KeychainUserTokenStore()
    let query = store.baseQuery()

    #expect(query[kSecClass as String] as? String == kSecClassGenericPassword as String)
    #expect(query[kSecAttrService as String] as? String == "com.musadorakit.user-token")
    #expect(query[kSecAttrAccount as String] as? String == "media-user-token")
    #expect(query[kSecUseDataProtectionKeychain as String] as? Bool == true)
  }

  @Test
  func legacyBaseQueryDoesNotUseDataProtectionKeychain() {
    let store = KeychainUserTokenStore()
    let query = store.baseQuery(useDataProtectionKeychain: false)

    #expect(query[kSecClass as String] as? String == kSecClassGenericPassword as String)
    #expect(query[kSecAttrService as String] as? String == "com.musadorakit.user-token")
    #expect(query[kSecAttrAccount as String] as? String == "media-user-token")
    #expect(query[kSecUseDataProtectionKeychain as String] == nil)
  }

  @Test
  func keychainAttributesStoreProtectedTokenData() throws {
    let store = KeychainUserTokenStore()
    let attributes = store.keychainAttributes(for: "music-user-token")
    let data = try #require(attributes[kSecValueData as String] as? Data)

    #expect(String(data: data, encoding: .utf8) == "music-user-token")
    #expect(
      attributes[kSecAttrAccessible as String] as? String
        == kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
    )
  }
}
