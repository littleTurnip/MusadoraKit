//
//  LibraryPlaylistParentTests.swift
//  MusadoraKitTests
//

import Foundation
@testable import MusadoraKit
import MusicKit
import Testing

@Suite
struct LibraryPlaylistParentTests {
  @Test
  func directParentEndpointURL() throws {
    let url = try MLibrary.playlistParentFolderURL(id: "p.example")

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlists/p.example/parent"
    )
  }

  @Test
  func playlistCollectionIncludesParent() throws {
    let endpoint = try MLibrary.libraryPlaylistsURL(limit: 100, includeParent: true)
    let url = try #require(endpoint)

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlists?limit=100&include=parent"
    )
  }

  @Test
  func playlistCollectionOmitsParentByDefault() throws {
    let endpoint = try MLibrary.libraryPlaylistsURL(limit: 25)
    let url = try #require(endpoint)

    expectEndpoint(
      url,
      equals: "https://api.music.apple.com/v1/me/library/playlists?limit=25"
    )
  }

  @Test
  func decodesDirectParentResponse() throws {
    let json = Data(
      """
      {
        "data": [{
          "id": "p.folder",
          "type": "library-playlist-folders",
          "href": "/v1/me/library/playlist-folders/p.folder",
          "attributes": {
            "dateAdded": "2026-07-10T12:00:00Z",
            "name": "Road Trips"
          }
        }]
      }
      """.utf8
    )

    let folder = try MLibrary.decodePlaylistParentFolder(from: json, playlistID: "p.example")

    #expect(folder.id == "p.folder")
    #expect(folder.attributes?.name == "Road Trips")
  }

  @Test
  func emptyDirectParentResponseThrows() {
    let json = Data(#"{"data":[]}"#.utf8)

    let error = #expect(throws: MusadoraKitError.self) {
      try MLibrary.decodePlaylistParentFolder(from: json, playlistID: "p.example")
    }

    #expect(error == .notFound(for: "parent folder of p.example"))
  }

  @Test
  func decodesIncludedParentRelationship() throws {
    let json = Data(
      """
      {
        "data": [{
          "id": "p.example",
          "attributes": {
            "canEdit": true,
            "name": "Example",
            "isPublic": false,
            "hasCatalog": false,
            "playParams": {
              "id": "p.example",
              "isLibrary": true
            }
          },
          "relationships": {
            "parent": {
              "data": [{
                "id": "p.playlistsroot",
                "type": "library-playlist-folders",
                "href": "/v1/me/library/playlist-folders/p.playlistsroot"
              }]
            }
          }
        }]
      }
      """.utf8
    )

    let playlists = try JSONDecoder().decode(LibraryPlaylists.self, from: json)
    let parent = try #require(playlists.first?.relationships?.parent?.data.first)

    #expect(parent.id == "p.playlistsroot")
    #expect(parent.type == "library-playlist-folders")
    #expect(parent.href == "/v1/me/library/playlist-folders/p.playlistsroot")
  }
}
