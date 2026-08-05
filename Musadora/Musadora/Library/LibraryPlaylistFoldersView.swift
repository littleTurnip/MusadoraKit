//
//  LibraryPlaylistFoldersView.swift
//  Musadora
//
//  Created by Rudrank Riyam on 05/08/26.
//

import MusadoraKit
import MusicKit
import SwiftUI

struct LibraryPlaylistFoldersView: View {
  @State private var path: [LibraryPlaylistFolder] = []
  @State private var root: LibraryPlaylistFolder?
  @State private var children: LibraryPlaylistFolderChildren?
  @State private var isLoading = false
  @State private var newFolderName = ""

  private var currentFolder: LibraryPlaylistFolder? {
    path.last ?? root
  }

  var body: some View {
    List {
      if isLoading {
        ProgressView().frame(maxWidth: .infinity, alignment: .leading)
      }

      if !path.isEmpty {
        Section {
          Button("Back to Root") {
            path.removeAll()
            Task { await loadChildren() }
          }
        }
      }

      Section("Folders") {
        if children?.folders.isEmpty ?? true {
          Text("No subfolders").foregroundStyle(.secondary)
        }

        ForEach(children?.folders ?? [], id: \.id) { folder in
          Button {
            path.append(folder)
            Task { await loadChildren() }
          } label: {
            Label(folder.attributes?.name ?? folder.id, systemImage: "folder")
          }
        }
      }

      Section("Playlists") {
        if children?.playlists.isEmpty ?? true {
          Text("No playlists").foregroundStyle(.secondary)
        }

        ForEach(children?.playlists ?? []) { playlist in
          Label(playlist.attributes.name, systemImage: "music.note.list")
        }
      }

      Section("Create Folder") {
        TextField("Folder name", text: $newFolderName)

        Button("Create in \(currentFolder?.attributes?.name ?? "Root")") {
          Task { await createFolder() }
        }
        .disabled(newFolderName.isEmpty || isLoading)
      }
    }
    .navigationTitle(currentFolder?.attributes?.name ?? "Playlist Folders")
    .task { await loadRoot() }
  }
}

extension LibraryPlaylistFoldersView {
  private func loadRoot() async {
    isLoading = true
    defer { isLoading = false }

    do {
      root = try await MLibrary.rootPlaylistsFolder()
      await loadChildren()
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }

  private func loadChildren() async {
    guard let folder = currentFolder else { return }

    isLoading = true
    defer { isLoading = false }

    do {
      children = try await MLibrary.playlistFolderChildren(forFolderID: MusicItemID(folder.id))
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }

  private func createFolder() async {
    isLoading = true
    defer { isLoading = false }

    do {
      let parentID = currentFolder.map { MusicItemID($0.id) }
      _ = try await MLibrary.createPlaylistFolder(name: newFolderName, parentID: parentID)
      newFolderName = ""
      await loadChildren()
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }
}

#Preview {
  NavigationStack {
    LibraryPlaylistFoldersView()
  }
}
