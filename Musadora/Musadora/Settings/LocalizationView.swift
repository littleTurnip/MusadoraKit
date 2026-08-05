//
//  LocalizationView.swift
//  Musadora
//
//  Created by Rudrank Riyam on 05/08/26.
//

import MusadoraKit
import MusicKit
import SwiftUI

struct LocalizationView: View {
  @State private var storefrontID: String = ""
  @State private var storefront: MusicStorefront?
  @State private var bestTag: String?
  @State private var isResolving = false

  private var preferredLanguages: [String] {
    Array(Locale.preferredLanguages.prefix(5))
  }

  var body: some View {
    List {
      Section("Storefront") {
        LabeledContent("Identifier", value: storefrontID.isEmpty ? "—" : storefrontID.uppercased())

        if let storefront {
          LabeledContent("Name", value: storefront.name)
          LabeledContent("Default Language", value: storefront.defaultLanguageTag)
        }
      }

      Section("Device Preferred Languages") {
        ForEach(preferredLanguages, id: \.self) { language in
          Text(language)
        }
      }

      if let storefront {
        Section("Supported by Storefront") {
          ForEach(storefront.supportedLanguageTags, id: \.self) { tag in
            HStack {
              Text(tag)
              Spacer()
              if tag == bestTag {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundStyle(.green)
              }
            }
          }
        }
      }

      Section {
        if isResolving {
          ProgressView().frame(maxWidth: .infinity, alignment: .leading)
        } else if let bestTag {
          LabeledContent("Best Match", value: bestTag)
        }

        Button("Resolve Best Language") {
          Task { await resolveBestTag() }
        }
        .disabled(storefrontID.isEmpty || isResolving)
      } footer: {
        Text("Apple resolves your preferred languages against the storefront's supported tags and returns the tag to pass as `l` on other requests.")
      }
    }
    .navigationTitle("Localization")
    .task { await loadStorefront() }
  }
}

extension LocalizationView {
  private func loadStorefront() async {
    do {
      storefrontID = try await MusicDataRequest.currentCountryCode
      storefront = try await MCatalog.storefront(id: storefrontID)
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }

  private func resolveBestTag() async {
    isResolving = true
    defer { isResolving = false }

    do {
      bestTag = try await MCatalog.bestLanguageTag(for: storefrontID)
    } catch {
      ErrorPresenter.shared.present(error)
    }
  }
}

#Preview {
  NavigationStack {
    LocalizationView()
  }
}
