import SwiftUI
import UIKit

struct GaviKeyGateView: View {
    @EnvironmentObject private var license: GaviStoreLicense
    @State private var keyInput = ""

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 22) {
                Spacer()
                Image(systemName: "key.horizontal.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(Color.orange)
                    .frame(width: 88, height: 88)
                    .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 26))

                VStack(spacing: 6) {
                    Text("GaviStore")
                        .font(.largeTitle.bold())
                    Text("Nhập key để tiếp tục")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    switch license.status {
                    case .checking:
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Đang kiểm tra key với máy chủ…")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    case .locked(let message, let expiry):
                        blockedNotice(message: message, expiry: expiry)
                    case .unavailable:
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Không kết nối được máy chủ kiểm tra key. Hãy thử lại khi có mạng.", systemImage: "wifi.exclamationmark")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                            Button("Thử kiểm tra lại") {
                                Task { await license.checkSavedKey() }
                            }
                            .font(.caption.weight(.semibold))
                        }
                    case .needsKey:
                        Text("Key chưa được xác minh trên thiết bị này.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    case .active:
                        EmptyView()
                    }

                    SecureField("Nhập key Gbao", text: $keyInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 13))

                    Button {
                        Task { await license.submitKey(keyInput) }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Kiểm tra key")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.orange)
                    .disabled(keyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isChecking)
                }
                .padding(18)
                .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22))
                .padding(.horizontal, 24)

                Text("GbaoTweaks × VFX King")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.vertical, 30)
        }
    }

    private var isChecking: Bool {
        if case .checking = license.status { return true }
        return false
    }

    private func blockedNotice(message: String, expiry: Date?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Không làm mà đòi có ăn thì…")
                .font(.headline.weight(.bold))
                .foregroundStyle(.red)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.red)
            if let expiry {
                Text("Hạn key: \(formattedDate(expiry))")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
            }
            Text("Key không hợp lệ, đã hết hạn hoặc bị khóa. Ứng dụng đang bị khóa toàn bộ chức năng.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct GaviHomeView: View {
    @EnvironmentObject private var license: GaviStoreLicense
    @EnvironmentObject private var repositoryStore: PackageRepositoryStore
    let onOpenSettings: () -> Void
    let onOpenPatchLibrary: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    brandCard
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Cộng đồng")
                            .font(.title3.bold())
                        HStack(spacing: 12) {
                            communityCard(title: "Nhóm Telegram", detail: "Chưa cấu hình liên kết", symbol: "paperplane.fill")
                            communityCard(title: "Nhóm Zalo", detail: "Chưa cấu hình liên kết", symbol: "bubble.left.and.bubble.right.fill")
                        }
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Chúc các bạn có trải nghiệm vui vẻ ♥")
                            .font(.subheadline.weight(.medium))
                        Text("@BaoTweak × VFX King")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)

                    GaviKeySummaryBar(onChangeKey: license.changeKey)
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 28)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("GaviStore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Cài đặt")
                }
            }
            .onAppear { repositoryStore.refreshAllIfNeeded() }
        }
    }

    private var brandCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image("GaviKingBanner")
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .clipped()
            LinearGradient(
                colors: [.clear, Color.black.opacity(0.78)],
                startPoint: .center,
                endPoint: .bottom
            )
            VStack(alignment: .leading, spacing: 5) {
                Text("GAVISTORE")
                    .font(.system(size: 25, weight: .black, design: .rounded))
                    .tracking(2)
                Text("QBaoTweak × VFX King")
                    .font(.subheadline.weight(.bold))
                Text("TWEAK  •  PATCH  •  PREMIUM")
                    .font(.caption2.weight(.semibold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.82))
            }
            .foregroundStyle(.white)
            .padding(17)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.purple.opacity(0.35), lineWidth: 1))
        .shadow(color: Color.purple.opacity(0.22), radius: 16, y: 7)
    }

    private func communityCard(title: String, detail: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(Color.orange)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Text(detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 17))
    }
}

struct GaviFunctionsView: View {
    @EnvironmentObject private var license: GaviStoreLicense
    @EnvironmentObject private var repositoryStore: PackageRepositoryStore
    @EnvironmentObject private var patchStore: PatchProjectStore
    let onOpenSettings: () -> Void
    let onOpenPatchLibrary: () -> Void

    @State private var selectedFolder = "Tất cả"
    @State private var selectedPackageID: String?
    @State private var selectedApp = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var patchRecords: [RepositoryPackageRecord] {
        repositoryStore.packages.filter { $0.package.kind == .patch }
    }

    private var folders: [String] {
        let names = Set(patchRecords.flatMap { record in
            record.package.tags.isEmpty ? ["Khác"] : record.package.tags
        })
        return ["Tất cả"] + names.sorted {
            $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
        }
    }

    private var visibleRecords: [RepositoryPackageRecord] {
        guard selectedFolder != "Tất cả" else { return patchRecords }
        return patchRecords.filter { record in
            record.package.tags.contains {
                $0.localizedCaseInsensitiveCompare(selectedFolder) == .orderedSame
            } || (record.package.tags.isEmpty && selectedFolder == "Khác")
        }
    }

    private var selectedRecord: RepositoryPackageRecord? {
        visibleRecords.first { $0.id == selectedPackageID }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if selectedApp {
                        HStack(spacing: 12) {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                    selectedApp = false
                                    selectedPackageID = nil
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.purple.gradient, in: RoundedRectangle(cornerRadius: 13))
                            }
                            VStack(alignment: .leading, spacing: 3) {
                                Text("FFVN")
                                    .font(.title2.bold())
                                Text("Thư viện patch FFVN")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if repositoryStore.isRefreshing {
                                ProgressView()
                            } else {
                                Button { repositoryStore.refreshAll() } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.headline)
                                        .foregroundStyle(.purple)
                                }
                                .accessibilityLabel("Làm mới patch")
                            }
                        }

                        ZStack(alignment: .bottomLeading) {
                            Image("GaviKingBanner")
                                .resizable()
                                .scaledToFill()
                                .frame(height: 112)
                                .frame(maxWidth: .infinity)
                                .clipped()
                            LinearGradient(colors: [.clear, .black.opacity(0.72)], startPoint: .center, endPoint: .bottom)
                            Text("FFVN PATCH COLLECTION")
                                .font(.headline.weight(.black))
                                .tracking(1.1)
                                .foregroundStyle(.white)
                                .padding(13)
                        }
                        .frame(height: 112)
                        .clipShape(RoundedRectangle(cornerRadius: 17))

                        Menu {
                            ForEach(folders, id: \.self) { folder in
                                Button {
                                    selectedFolder = folder
                                    selectedPackageID = nil
                                } label: {
                                    if selectedFolder == folder {
                                        Label(folder, systemImage: "checkmark")
                                    } else {
                                        Text(folder)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "folder.fill").foregroundStyle(.purple)
                                Text(selectedFolder).fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.down").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                            }
                            .padding(14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                        }
                        .accessibilityLabel("Chọn thư mục patch")

                        if visibleRecords.isEmpty {
                            emptyPatchState
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(visibleRecords) { record in patchCard(record) }
                            }
                        }

                        if let selectedRecord {
                            Button {
                                repositoryStore.install(selectedRecord, using: patchStore)
                                selectedPackageID = nil
                            } label: {
                                Label("Tải patch: \(selectedRecord.package.name)", systemImage: "arrow.down.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.purple)
                            .disabled(repositoryStore.isDownloading(selectedRecord))
                        }

                        Button(action: onOpenPatchLibrary) {
                            Label("Kho patch đã tải · \(patchStore.items.count)", systemImage: "tray.full")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .tint(.purple)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Chức năng")
                                .font(.largeTitle.bold())
                            Text("Chọn ứng dụng để mở thư viện patch")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)

                        Button {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
                                selectedApp = true
                                repositoryStore.refreshAllIfNeeded()
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Image("GaviAppTile")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 76, height: 76)
                                    .clipShape(RoundedRectangle(cornerRadius: 19))
                                    .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color.purple.opacity(0.45), lineWidth: 1))
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("FFVN")
                                        .font(.headline.bold())
                                        .foregroundStyle(.primary)
                                    Text("Patch FFVN · AIM · Mod Skin")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Label("Mở ứng dụng", systemImage: "arrow.up.right")
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.purple)
                                        .padding(.top, 2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.black))
                                    .foregroundStyle(.purple)
                            }
                            .padding(13)
                            .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 21))
                            .overlay(RoundedRectangle(cornerRadius: 21).stroke(Color.purple.opacity(0.22), lineWidth: 1))
                            .shadow(color: Color.purple.opacity(0.10), radius: 12, y: 5)
                        }
                        .buttonStyle(.plain)

                        GaviKeySummaryBar(onChangeKey: license.changeKey)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 28)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("GaviStore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onOpenSettings) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Cài đặt")
                }
            }
            .onAppear { repositoryStore.refreshAllIfNeeded() }
            .onChange(of: folders) { newFolders in
                if !newFolders.contains(selectedFolder) { selectedFolder = "Tất cả" }
            }
        }
    }

    private var emptyPatchState: some View {
        VStack(spacing: 10) {
            Image(systemName: repositoryStore.isRefreshing ? "arrow.triangle.2.circlepath" : "folder.badge.questionmark")
                .font(.system(size: 34))
                .foregroundStyle(.orange)
            Text(repositoryStore.isRefreshing ? "Đang tải danh sách patch…" : "Chưa có patch trong thư mục này")
                .font(.headline)
            Text("Các thư mục và tên patch sẽ hiển thị theo tags và name trong repo.json trên website.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 38)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private func patchCard(_ record: RepositoryPackageRecord) -> some View {
        let isSelected = selectedPackageID == record.id
        let isDownloading = repositoryStore.isDownloading(record)
        let resolvedID = repositoryStore.resolvedPackageID(for: record)
        let isImported = resolvedID.map { id in patchStore.items.contains(where: { $0.id == id }) } ?? false

        return Button {
            selectedPackageID = isSelected ? nil : record.id
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: isImported ? "checkmark.seal.fill" : "square.stack.3d.up.fill")
                        .font(.title2)
                        .foregroundStyle(isSelected ? Color.white : Color.orange)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white)
                    }
                }
                Text(record.package.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
                Text(record.package.summary)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.white.opacity(0.82) : Color.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing: 5) {
                    Circle()
                        .fill(isImported ? Color.green : (isDownloading ? Color.orange : Color.secondary))
                        .frame(width: 6, height: 6)
                    Text(isImported ? "Đã tải" : (isDownloading ? "Đang tải" : "Chạm để chọn"))
                        .font(.caption2.weight(.medium))
                }
                .foregroundStyle(isSelected ? Color.white.opacity(0.9) : Color.secondary)
            }
            .padding(13)
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
            .background(
                isSelected ? Color.purple : Color(uiColor: .secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 17)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 17)
                    .stroke(isSelected ? Color.purple : Color.primary.opacity(0.05), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(isDownloading)
    }
}

private struct GaviKeySummaryBar: View {
    @EnvironmentObject private var license: GaviStoreLicense
    let onChangeKey: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(license.maskedKey)
                    .font(.system(.caption, design: .monospaced).weight(.semibold))
                if let expiry = license.currentExpiry {
                    Text("Hạn sử dụng: \(formattedDate(expiry))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Key đang hoạt động")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 8)
            Button("Đổi key", action: onChangeKey)
                .font(.caption.weight(.semibold))
                .buttonStyle(.bordered)
                .tint(.orange)
        }
        .padding(13)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
