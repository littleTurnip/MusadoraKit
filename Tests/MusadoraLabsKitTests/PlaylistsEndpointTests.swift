//
//  PlaylistsEndpointTests.swift
//  PlaylistsEndpointTests
//
//  Created by Rudrank Riyam on 19/04/22.
//

import Foundation

@testable import MusadoraLabsKit
import XCTest

class PlaylistsEndpointTests: XCTestCase {
  // MARK: - Catalog Playlists Tests

  func testFetchACatalogPlaylistsByIDEndpoint() async throws {
    let id = "pl.f4d106fed2bd41149aaacabb233eb5eb"
    let url = try await MusadoraLabsKit.catalogPlaylist(id: id, storeFront: "us")
    let endpointURL = "https://api.music.apple.com/v1/catalog/us/playlists/pl.f4d106fed2bd41149aaacabb233eb5eb"
    XCTAssertEqualEndpoint(url, endpointURL)
  }

  func testFetchMultipleCatalogPlaylistsByIDsEndpoint() async throws {
    let ids = ["pl.f4d106fed2bd41149aaacabb233eb5eb"]
    let url = try await MusadoraLabsKit.catalogPlaylists(ids: ids, storeFront: "us")
    let endpointURL = "https://api.music.apple.com/v1/catalog/us/playlists?ids=pl.f4d106fed2bd41149aaacabb233eb5eb"
    XCTAssertEqualEndpoint(url, endpointURL)
  }

  // MARK: - Library Playlists Tests

  func testFetchALibraryPlaylistByIDEndpoint() async throws {
    let id = "p.ldvAAZ3C3Qmop9"
    let endpoint = try await MusadoraLabsKit.libraryPlaylist(id: id)
    XCTAssertEqualEndpoint(endpoint, "https://api.music.apple.com/v1/me/library/playlists/p.ldvAAZ3C3Qmop9")
  }

  func testFetchMultipleLibraryPlaylistsByIDsEndpoint() async throws {
    let ids = ["p.ldvAAZ3C3Qmop9"]
    let endpoint = try await MusadoraLabsKit.libraryPlaylists(ids: ids)
    XCTAssertEqualEndpoint(endpoint, "https://api.music.apple.com/v1/me/library/playlists?ids=p.ldvAAZ3C3Qmop9")
  }

  func testFetchAllLibraryPlaylistsEndpoint() async throws {
    let endpoint = try await MusadoraLabsKit.libraryPlaylists()
    XCTAssertEqualEndpoint(endpoint, "https://api.music.apple.com/v1/me/library/playlists")
  }
}
