//
//  LibraryPlaylistFolderEndpointTests.swift
//  MusadoraKitTests
//
//  Created by Rudrank Riyam on 05/08/26.
//

import Foundation
@testable import MusadoraKit
import MusicKit
import Testing

@Suite
struct LibraryPlaylistFolderEndpointTests {
  // MARK: - Endpoint URLs

  @Test
  func rootPlaylistsFolderEndpointURL() throws {
    let url = try MLibrary.rootPlaylistsFolderURL()

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlist-folders?filter%5Bidentity%5D=playlistsroot"
    )
  }

  @Test
  func playlistFolderEndpointURL() throws {
    let url = try MLibrary.playlistFolderURL(id: "p.WmzVVDOUO9pDBk")

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlist-folders/p.WmzVVDOUO9pDBk"
    )
  }

  @Test
  func playlistFoldersEndpointURL() throws {
    let url = try MLibrary.playlistFoldersURL(ids: ["p.WmzVVDOUO9pDBk", "p.RB1AA8bCv74Zkl"])

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlist-folders?ids=p.WmzVVDOUO9pDBk,p.RB1AA8bCv74Zkl"
    )
  }

  @Test
  func playlistFoldersEndpointURLWithEmptyIDsThrows() {
    let error = #expect(throws: MusadoraKitError.self) {
      try MLibrary.playlistFoldersURL(ids: [])
    }

    #expect(error == .idMissing)
  }

  @Test
  func playlistFolderChildrenEndpointURL() throws {
    let url = try MLibrary.playlistFolderChildrenURL(forFolderID: "p.WmzVVDOUO9pDBk")

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlist-folders/p.WmzVVDOUO9pDBk/children"
    )
  }

  @Test
  func playlistFolderChildrenEndpointURLWithLimit() throws {
    let url = try MLibrary.playlistFolderChildrenURL(forFolderID: "p.WmzVVDOUO9pDBk", limit: 50)

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlist-folders/p.WmzVVDOUO9pDBk/children?limit=50"
    )
  }

  @Test
  func playlistFolderParentEndpointURL() throws {
    let url = try MLibrary.playlistFolderParentURL(forFolderID: "p.WmzVVDOUO9pDBk")

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlist-folders/p.WmzVVDOUO9pDBk/parent"
    )
  }

  @Test
  func createPlaylistFolderEndpointURL() throws {
    let url = try MLibrary.createPlaylistFolderURL()

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlist-folders"
    )
  }

  @Test
  func rootPlaylistsFolderURLWithBadComponentsThrows() {
    let error = #expect(throws: URLError.self) {
      try MLibrary.rootPlaylistsFolderURL(components: BadURLAppleMusicURLComponents())
    }

    #expect(error == URLError(.badURL))
  }

  // MARK: - Creation Request Body

  @Test
  func creationRequestBodyWithParent() throws {
    let creationRequest = LibraryPlaylistFolderCreationRequest(
      attributes: .init(name: "Chill"),
      relationships: .init(parent: .init(data: [.init(id: "p.playlistsroot")]))
    )

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let body = try encoder.encode(creationRequest)

    let json = try #require(String(data: body, encoding: .utf8))
    #expect(json == #"{"attributes":{"name":"Chill"},"relationships":{"parent":{"data":[{"id":"p.playlistsroot","type":"library-playlist-folders"}]}}}"#)
  }

  @Test
  func creationRequestBodyWithoutParent() throws {
    let creationRequest = LibraryPlaylistFolderCreationRequest(attributes: .init(name: "Chill"))

    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let body = try encoder.encode(creationRequest)

    let json = try #require(String(data: body, encoding: .utf8))
    #expect(json == #"{"attributes":{"name":"Chill"}}"#)
  }
}
