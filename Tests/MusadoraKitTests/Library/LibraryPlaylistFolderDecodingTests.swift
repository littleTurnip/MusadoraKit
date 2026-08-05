//
//  LibraryPlaylistFolderDecodingTests.swift
//  MusadoraKitTests
//
//  Created by Rudrank Riyam on 05/08/26.
//

import Foundation
@testable import MusadoraKit
import MusicKit
import Testing

@Suite
struct LibraryPlaylistFolderDecodingTests {
  @Test
  func decodesPlaylistFolder() throws {
    let json = Data(
      """
      {
        "data": [{
          "id": "p.WmzVVDOUO9pDBk",
          "type": "library-playlist-folders",
          "href": "/v1/me/library/playlist-folders/p.WmzVVDOUO9pDBk",
          "attributes": {
            "name": "Chill",
            "dateAdded": "2022-03-19T06:07:33Z"
          }
        }]
      }
      """.utf8
    )

    let folder = try MLibrary.decodePlaylistFolder(from: json, id: "p.WmzVVDOUO9pDBk")

    let expectedDate = try #require(ISO8601DateFormatter().date(from: "2022-03-19T06:07:33Z"))
    #expect(folder.id == "p.WmzVVDOUO9pDBk")
    #expect(folder.type == "library-playlist-folders")
    #expect(folder.href == "/v1/me/library/playlist-folders/p.WmzVVDOUO9pDBk")
    #expect(folder.attributes?.name == "Chill")
    #expect(folder.attributes?.dateAdded == expectedDate)
  }

  @Test
  func emptyPlaylistFolderResponseThrows() {
    let json = Data(#"{"data":[]}"#.utf8)

    let error = #expect(throws: MusadoraKitError.self) {
      try MLibrary.decodePlaylistFolder(from: json, id: "p.WmzVVDOUO9pDBk")
    }

    #expect(error == .notFound(for: "p.WmzVVDOUO9pDBk"))
  }

  @Test
  func emptyPlaylistFolderParentResponseThrows() {
    let json = Data(#"{"data":[]}"#.utf8)

    let error = #expect(throws: MusadoraKitError.self) {
      try MLibrary.decodePlaylistFolderParent(from: json, folderID: "p.WmzVVDOUO9pDBk")
    }

    #expect(error == .notFound(for: "parent folder of p.WmzVVDOUO9pDBk"))
  }

  @Test
  func decodesRootFolderFromMetaFilters() throws {
    let json = Data(
      """
      {
        "data": [],
        "meta": {
          "filters": {
            "identity": {
              "playlistsroot": [{
                "id": "p.playlistsroot",
                "type": "library-playlist-folders",
                "href": "/v1/me/library/playlist-folders/p.playlistsroot"
              }]
            }
          }
        }
      }
      """.utf8
    )

    let folder = try MLibrary.decodeRootPlaylistsFolder(from: json)

    #expect(folder.id == "p.playlistsroot")
    #expect(folder.type == "library-playlist-folders")
    #expect(folder.href == "/v1/me/library/playlist-folders/p.playlistsroot")
    #expect(folder.attributes == nil)
  }

  @Test
  func decodesRootFolderFromData() throws {
    let json = Data(
      """
      {
        "data": [{
          "id": "p.playlistsroot",
          "type": "library-playlist-folders",
          "href": "/v1/me/library/playlist-folders/p.playlistsroot",
          "attributes": {
            "name": "Playlists",
            "dateAdded": "2021-06-14T09:00:00Z"
          }
        }]
      }
      """.utf8
    )

    let folder = try MLibrary.decodeRootPlaylistsFolder(from: json)

    #expect(folder.id == "p.playlistsroot")
    #expect(folder.attributes?.name == "Playlists")
  }

  @Test
  func missingRootFolderThrows() {
    let json = Data(#"{"data":[]}"#.utf8)

    let error = #expect(throws: MusadoraKitError.self) {
      try MLibrary.decodeRootPlaylistsFolder(from: json)
    }

    #expect(error == .notFound(for: "root playlists folder"))
  }

  @Test
  func decodesFolderChildren() throws {
    let json = Data(
      """
      {
        "data": [
          {
            "id": "p.RB1AA8bCv74Zkl",
            "type": "library-playlists",
            "href": "/v1/me/library/playlists/p.RB1AA8bCv74Zkl",
            "attributes": {
              "name": "Chill JPop",
              "description": { "standard": "" },
              "dateAdded": "2021-12-03T19:06:29Z",
              "isPublic": false,
              "canEdit": true,
              "hasCatalog": false,
              "playParams": {
                "id": "p.RB1AA8bCv74Zkl",
                "kind": "playlist",
                "isLibrary": true
              }
            }
          },
          {
            "id": "p.8B1uu3JS0ap2xq",
            "type": "library-playlist-folders",
            "href": "/v1/me/library/playlist-folders/p.8B1uu3JS0ap2xq",
            "attributes": {
              "name": "Focus",
              "dateAdded": "2022-01-05T11:30:00Z"
            }
          }
        ],
        "meta": { "total": 2 }
      }
      """.utf8
    )

    let children = try MLibrary.decodePlaylistFolderChildren(from: json)

    #expect(children.playlists.count == 1)
    #expect(children.folders.count == 1)

    let playlist = try #require(children.playlists.first)
    #expect(playlist.id == "p.RB1AA8bCv74Zkl")
    #expect(playlist.attributes.name == "Chill JPop")
    #expect(playlist.attributes.canEdit == true)

    let folder = try #require(children.folders.first)
    #expect(folder.id == "p.8B1uu3JS0ap2xq")
    #expect(folder.attributes?.name == "Focus")
  }

  @Test
  func decodesCreatedFolderResponse() throws {
    let json = Data(
      """
      {
        "data": [{
          "id": "p.WmzVVDOUO9pDBk",
          "type": "library-playlist-folders",
          "href": "/v1/me/library/playlist-folders/p.WmzVVDOUO9pDBk",
          "attributes": {
            "name": "Chill",
            "dateAdded": "2022-03-19T06:07:33Z"
          }
        }],
        "meta": { "total": 1 }
      }
      """.utf8
    )

    let folders = try MLibrary.decodePlaylistFolders(from: json)

    let folder = try #require(folders.first)
    #expect(folder.id == "p.WmzVVDOUO9pDBk")
    #expect(folder.attributes?.name == "Chill")
  }
}
