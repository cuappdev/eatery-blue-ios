//
//  SettingsPrivacyView.swift
//  Eatery Blue
//
//  Created by William Ma on 1/24/22.
//

import SwiftUI

class SettingsPrivacyViewModel: ObservableObject {
    @Published var isLocationAllowed: Bool = false
    @Published var isNotificationAllowed: Bool = false
    @Published var isAnalyticsEnabled: Bool = false
}

struct SettingsPrivacyView: View {
    @ObservedObject var viewModel = SettingsPrivacyViewModel()
    var onOpenSystemSettings: (() -> Void)?
    var onOpenNotificationSettings: (() -> Void)?

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
                    onOpenSystemSettings?()
                } label: {
                    permissionRow(
                        title: "Location Access",
                        subtitle: "Used to find eateries near you",
                        isAllowed: viewModel.isLocationAllowed
                    )
                }

                Button {
                    onOpenSystemSettings?()
                } label: {
                    permissionRow(
                        title: "Notification Access",
                        subtitle: "Used to send device notifications",
                        isAllowed: viewModel.isNotificationAllowed
                    )
                }

                Button {
                    onOpenNotificationSettings?()
                } label: {
                    HStack {
                        Text("Notification Settings")
                            .font(Font(UIFont.preferredFont(for: .body, weight: .semibold)))
                            .foregroundColor(Color(UIColor.Eatery.primaryText))
                        Spacer()
                        Image("ChevronRight")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(UIColor.Eatery.blue))
                            .frame(width: 16, height: 16)
                    }
                    .padding(.vertical, 8)
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
                            .foregroundColor(Color(UIColor.Eatery.primaryText))
                        Text("Help us improve our products and services")
                            .font(Font(UIFont.preferredFont(for: .caption1, weight: .semibold)))
                            .foregroundColor(Color(UIColor.Eatery.secondaryText))
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
                            .foregroundColor(Color(UIColor.Eatery.primaryText))
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

    private func permissionRow(title: String, subtitle: String, isAllowed: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Font(UIFont.preferredFont(for: .body, weight: .semibold)))
                    .foregroundColor(Color(UIColor.Eatery.primaryText))
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(UIColor.Eatery.gray05))
            }
            Spacer()
            HStack(spacing: 2) {
                Text(isAllowed ? "Allowed" : "Denied")
                    .font(Font(UIFont.preferredFont(for: .footnote, weight: .semibold)))
                Image("ExternalLink")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
            }
            .foregroundColor(isAllowed
                ? Color(UIColor.Eatery.blue)
                : Color(UIColor.Eatery.secondaryText))
        }
        .padding(.vertical, 8)
    }

    private func sectionHeader(title: String) -> some View {
        Text(title)
            .font(Font(UIFont.preferredFont(for: .title2, weight: .semibold)))
            .foregroundColor(Color(UIColor.Eatery.primaryText))
            .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
            .listRowSeparator(.hidden)
    }
}

struct SettingsPrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPrivacyView()
    }
}
