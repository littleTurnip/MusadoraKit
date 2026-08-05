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
            Task { await returnToRoot() }
          }
          .disabled(isLoading)
        }
      }

      Section("Folders") {
        if children?.folders.isEmpty ?? true {
          Text("No subfolders").foregroundStyle(.secondary)
        }

        ForEach(children?.folders ?? [], id: \.id) { folder in
          Button {
            Task { await open(folder) }
          } label: {
            Label(folder.attributes?.name ?? folder.id, systemImage: "folder")
          }
          .disabled(isLoading)
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
        .disabled(newFolderName.isEmpty || isLoading || currentFolder == nil)
      }
    }
    .navigationTitle(currentFolder?.attributes?.name ?? "Playlist Folders")
    .task { await loadRoot() }
  }
}

// Every action is single-flight: `beginLoading()` runs on the main actor
// before the first await, so a second tap in the same frame — before the
// disabled state re-renders — bails instead of starting an overlapping load.
// `path` and `children` mutate together only after the awaited load succeeds,
// so the list can never show one level while `path` points at another, and a
// slow response can never overwrite state that belongs to a later navigation.
extension LibraryPlaylistFoldersView {
  private func beginLoading() -> Bool {
    guard !isLoading else { return false }
    isLoading = true
    return true
  }

  private func loadRoot() async {
    guard beginLoading() else { return }
    defer { isLoading = false }

    do {
      let folder = try await MLibrary.rootPlaylistsFolder()
      root = folder
      children = try await children(of: folder)
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }

  private func open(_ folder: LibraryPlaylistFolder) async {
    guard beginLoading() else { return }
    defer { isLoading = false }

    do {
      let loaded = try await children(of: folder)
      path.append(folder)
      children = loaded
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }

  private func returnToRoot() async {
    guard let root, beginLoading() else { return }
    defer { isLoading = false }

    do {
      let loaded = try await children(of: root)
      path.removeAll()
      children = loaded
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }

  private func createFolder() async {
    guard let folder = currentFolder, beginLoading() else { return }
    defer { isLoading = false }

    do {
      _ = try await MLibrary.createPlaylistFolder(name: newFolderName, parentID: MusicItemID(folder.id))
      newFolderName = ""
      children = try await children(of: folder)
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }

  private func children(of folder: LibraryPlaylistFolder) async throws -> LibraryPlaylistFolderChildren {
    try await MLibrary.playlistFolderChildren(forFolderID: MusicItemID(folder.id))
  }
}

#Preview {
  NavigationStack {
    LibraryPlaylistFoldersView()
  }
}
