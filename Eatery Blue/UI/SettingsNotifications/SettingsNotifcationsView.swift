//
//  SettingsNotifcationsView.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/11/25.
//

import SwiftUI

final class SettingsNotificationsViewModel: ObservableObject {
    // Top-level kill switch
    @Published var pauseAll: Bool = false

    // Individual categories
    @Published var favoriteItems: Bool = true
    @Published var appDev: Bool = true
    @Published var dining: Bool = true
    @Published var account: Bool = false
}

struct SettingsNotificationsView: View {
    @ObservedObject var viewModel = SettingsNotificationsViewModel()

    /// VC provides this to push the Privacy screen.
    var onTapPrivacy: (() -> Void)?

    var body: some View {
        List {
            Section {
                Text("Manage item and promotional notifications")
                    .foregroundColor(Color("Gray06", bundle: nil))
                    .font(Font(UIFont.preferredFont(for: .body, weight: .medium)))
            }
            .listRowSeparator(.hidden)

            // Pause all
            Section {
                HStack {
                    Text("Pause all notifications")
                        .font(Font(UIFont.preferredFont(for: .title3, weight: .semibold)))
                        .foregroundColor(Color("Black"))
                    Spacer()
                    Toggle("Pause all notifications", isOn: $viewModel.pauseAll)
                        .labelsHidden()
                        .tint(Color("EateryBlue"))
                }
            }
            .listRowSeparator(.visible, edges: .bottom)

            // Category toggles
            Section {
                categoryRow(
                    title: "Favorite Item Notifications",
                    subtitle: "Get notified when favorite items are served",
                    isOn: $viewModel.favoriteItems
                )

                categoryRow(
                    title: "Cornell AppDev Notifications",
                    subtitle: "Get notified about new releases and feedback",
                    isOn: $viewModel.appDev
                )

                categoryRow(
                    title: "Cornell Dining Notifications",
                    subtitle: "Get notified about special menus and meals",
                    isOn: $viewModel.dining
                )

                categoryRow(
                    title: "Account Notifications",
                    subtitle: "Get notified about account security and privacy",
                    isOn: $viewModel.account
                )
            }

            Section {
                Button {
                    onTapPrivacy?()
                } label: {
                    HStack {
                        Text("Privacy Settings")
                            .font(Font(UIFont.preferredFont(for: .title3, weight: .semibold)))
                            .foregroundColor(Color("Black"))
                        Spacer()
                        Image("ChevronRight")
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

    // MARK: Helpers

    private func categoryRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Spacer(minLength: 12)
                Text(title)
                    .font(Font(UIFont.preferredFont(for: .body, weight: .semibold)))
                    .foregroundColor(Color("Black"))
                Text(subtitle)
                    .font(Font(UIFont.preferredFont(for: .caption1, weight: .semibold)))
                    .foregroundColor(Color("Gray05"))
                Spacer(minLength: 12)
            }
            Spacer(minLength: 0)
            Toggle(title, isOn: isOn)
                .labelsHidden()
                .tint(Color("EateryBlue"))
        }
    }
}

struct SettingsNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNotificationsView()
            .previewDisplayName("Notifications")
    }
}
