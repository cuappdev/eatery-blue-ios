//
//  SettingsNotifcationsView.swift
//  Eatery Blue
//
//  Created by Arielle Nudelman on 10/11/25.
//

import SwiftUI

final class SettingsNotificationsViewModel: ObservableObject {
    @Published var pauseAll: Bool = false
    @Published var favoriteItems: Bool = true
    @Published var appDev: Bool = true
    @Published var systemNotificationsDenied: Bool = false
}

struct SettingsNotificationsView: View {
    @ObservedObject var viewModel = SettingsNotificationsViewModel()
    var onOpenSystemSettings: (() -> Void)?

    private var pauseAllBinding: Binding<Bool> {
        Binding(
            get: { viewModel.pauseAll },
            set: { isOn in
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.pauseAll = isOn
                }
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Manage item and promotional notifications")
                    .font(Font(UIFont.preferredFont(for: .body, weight: .medium)))
                    .foregroundColor(Color(UIColor.Eatery.gray06))
                    .fixedSize(horizontal: false, vertical: true)

                if viewModel.systemNotificationsDenied {
                    permissionDeniedCard
                }

                VStack(spacing: 16) {
                    pauseRow
                    if !viewModel.pauseAll {
                        categoryCard
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(UIColor.Eatery.default00).ignoresSafeArea())
    }

    private var pauseRow: some View {
        HStack(spacing: 12) {
            Text("Pause all notifications")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(UIColor.Eatery.primaryText))
            Spacer(minLength: 12)
            Toggle("Pause all notifications", isOn: pauseAllBinding)
                .labelsHidden()
                .tint(Color(UIColor.Eatery.blue))
                .disabled(viewModel.systemNotificationsDenied)
        }
        .padding(16)
        .background(
            Capsule()
                .fill(Color(UIColor.Eatery.card))
                .shadow(color: Color.black.opacity(0.12), radius: 6)
        )
    }

    private var permissionDeniedCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notifications are turned off")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(UIColor.Eatery.primaryText))
            Text("Turn on notifications for Eatery in iOS Settings to get alerts when favorite items are served.")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(UIColor.Eatery.gray05))
                .fixedSize(horizontal: false, vertical: true)
            Button("Open Settings") {
                onOpenSystemSettings?()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color(UIColor.Eatery.blue))
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.Eatery.card))
                .shadow(color: Color.black.opacity(0.12), radius: 6)
        )
    }

    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            categoryRow(
                title: "Favorite Item Notifications",
                subtitle: "Get notified when favorite items are served",
                isOn: $viewModel.favoriteItems
            )
            Rectangle()
                .fill(Color(UIColor.Eatery.gray01))
                .frame(height: 1)
            categoryRow(
                title: "Cornell AppDev Notifications",
                subtitle: "Get notified about new releases and feedback",
                isOn: $viewModel.appDev
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.Eatery.card))
                .shadow(color: Color.black.opacity(0.12), radius: 6)
        )
    }

    private func categoryRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(UIColor.Eatery.primaryText))
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(UIColor.Eatery.gray05))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 12)
            Toggle(title, isOn: isOn)
                .labelsHidden()
                .tint(Color(UIColor.Eatery.blue))
                .disabled(viewModel.systemNotificationsDenied)
        }
    }
}

struct SettingsNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNotificationsView()
            .previewDisplayName("Notifications")
    }
}
