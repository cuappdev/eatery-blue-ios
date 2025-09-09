//
//  SettingsPrivacyView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/24/22.
//

import SwiftUI

class SettingsPrivacyViewModel: ObservableObject {
    @Published var isLocationAllowed: Bool = false
    @Published var isAnalyticsEnabled: Bool = false
}

struct SettingsPrivacyView: View {
    @ObservedObject var viewModel = SettingsPrivacyViewModel()

    var body: some View {
        List {
            Section {
                Text("Manage permissions and analytics")
                    .foregroundColor(Color("Gray06", bundle: nil))
                    .font(Font(UIFont.preferredFont(for: .body, weight: .medium)))
            }
            .listRowSeparator(.hidden)

            Section {
                sectionHeader(title: "Permissions")

                Button {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }

                    UIApplication.shared.open(url, options: [:], completionHandler: nil)

                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Spacer(minLength: 12)
                            Text("Location Access")
                                .font(Font(UIFont.preferredFont(for: .body, weight: .semibold)))
                                .foregroundColor(Color("Black"))
                            Text("Used to find eateries near you")
                                .font(Font(UIFont.preferredFont(for: .caption1, weight: .semibold)))
                                .foregroundColor(Color("Gray05"))
                            Spacer(minLength: 12)
                        }
                        Spacer()
                        HStack(spacing: 2) {
                            Text(viewModel.isLocationAllowed ? "Allowed" : "Denied")
                                .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                            Image("ExternalLink")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 16, height: 16)
                        }
                        .foregroundColor(viewModel.isLocationAllowed ? Color("EateryBlue") : Color("Gray05"))
                    }
                }
                .listRowSeparator(.hidden, edges: .bottom)
            }

            Section {
                sectionHeader(title: "Analytics")
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer(minLength: 12)
                        Text("Share with Cornell AppDev")
                            .font(Font(UIFont.preferredFont(for: .body, weight: .semibold)))
                            .foregroundColor(Color("Black"))
                        Text("Help us improve our products and services")
                            .font(Font(UIFont.preferredFont(for: .caption1, weight: .semibold)))
                            .foregroundColor(Color("Gray05"))
                        Spacer(minLength: 12)
                    }
                    Spacer(minLength: 0)
                    Toggle("Analytics Enabled", isOn: $viewModel.isAnalyticsEnabled)
                        .labelsHidden()
                        .tint(Color("EateryBlue"))
                }

                Link(destination: URL(string: "https://www.cornellappdev.com/privacy")!) {
                    HStack {
                        Text("Privacy Policy")
                            .font(Font(UIFont.preferredFont(for: .body, weight: .semibold)))
                            .foregroundColor(Color("Black"))
                        Spacer()
                        Image("ExternalLink")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color("EateryBlue"))
                            .frame(width: 16, height: 16)
                    }
                }
                .listRowSeparator(.hidden, edges: .bottom)
            }
        }
        .listStyle(.plain)
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(Font(UIFont.preferredFont(for: .title2, weight: .semibold)))
            .foregroundColor(Color("Black"))
            .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
    }
}

struct SettingsPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPrivacyView()
    }
}
