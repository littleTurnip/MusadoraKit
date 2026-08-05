//
//  LibraryPlaylistFolderCreationRequest.swift
//  MusadoraKit
//
//  Created by Rudrank Riyam on 05/08/26.
//

import Foundation

/// A request body to create a new playlist folder in the user's library.
///
/// This structure encapsulates the information needed to create a playlist folder,
/// including its name and an optional parent folder relationship.
///
/// Example usage:
/// ```swift
/// let request = LibraryPlaylistFolderCreationRequest(
///     attributes: .init(name: "Workout Mixes"),
///     relationships: .init(parent: .init(data: [.init(id: "p.playlistsroot")]))
/// )
/// ```
struct LibraryPlaylistFolderCreationRequest: Codable {
  /// The attributes for the new playlist folder, including its name.
  var attributes: Attributes

  /// Optional relationships for the new playlist folder, such as its parent folder.
  var relationships: Relationships?

  /// The attributes for a library playlist folder creation request.
  struct Attributes: Codable {
    /// The name of the playlist folder to create.
    var name: String
  }

  /// The relationships for a library playlist folder creation request.
  struct Relationships: Codable {
    /// The parent folder of the playlist folder to create.
    var parent: Parent
  }

  /// The parent folder relationship of the playlist folder creation request.
  struct Parent: Codable {
    /// The data of the parent folder of the playlist folder to create.
    var data: [ParentData]
  }

  /// The data for the parent folder of the playlist folder creation request.
  struct ParentData: Codable {
    /// The unique identifier of the parent playlist folder.
    ///
    /// Use `p.playlistsroot` to create the folder at the top level of the user's library.
    var id: String

    /// The type of the parent resource.
    var type: LibraryPlaylistFolderParentType = .libraryPlaylistFolders
  }
}

/// An enumeration of the resource types that can act as the parent of a library playlist folder.
enum LibraryPlaylistFolderParentType: String, Codable {
  case libraryPlaylistFolders = "library-playlist-folders"
}
