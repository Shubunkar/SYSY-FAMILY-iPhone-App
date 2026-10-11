import SwiftUI

extension Color {
    static let sysyNavy = Color(red: 0.015, green: 0.08, blue: 0.18)
    static let sysyGold = Color(red: 0.82, green: 0.60, blue: 0.18)
}

struct AppCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.07), radius: 10, y: 4)
    }
}

struct SYSYLogoView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.sysyNavy, Color(red: 0.04, green: 0.22, blue: 0.38)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(spacing: 4) {
                HStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.sysyGold, lineWidth: 2)
                        .overlay(
                            HStack(spacing: 2) {
                                Rectangle().fill(Color.sysyGold).frame(width: 2)
                                Rectangle().fill(Color.sysyGold).frame(width: 2)
                            }.padding(4)
                        )
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.white, lineWidth: 2)
                        .overlay(Rectangle().fill(Color.white).frame(width: 2).padding(.horizontal, 8))
                }
                .frame(height: 25)
                Text("SYSY")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("FAMILY")
                    .font(.system(size: 8, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(Color.sysyGold)
            }
            .padding(7)
        }
        .accessibilityLabel("SYSY FAMILY logo")
    }
}

struct ProfileAvatar: View {
    var size: CGFloat = 58
    var body: some View {
        SYSYLogoView()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.sysyGold, lineWidth: 2))
    }
}
