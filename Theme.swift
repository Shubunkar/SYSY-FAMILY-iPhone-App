import SwiftUI

extension Color {
    static let sysyNavy = Color(red: 0.015, green: 0.08, blue: 0.18)
    static let sysyGold = Color(red: 0.91, green: 0.69, blue: 0.24)
    static let sysyBlue = Color(red: 0.04, green: 0.22, blue: 0.40)
    static let sysyCream = Color(red: 1.00, green: 0.98, blue: 0.93)
    static let sysyGoldLight = Color(red: 1.00, green: 0.88, blue: 0.56)
}

struct AppCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding()
            .background(
                LinearGradient(
                    colors: [.white, Color.sysyCream],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.sysyGold.opacity(0.30), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.sysyNavy.opacity(0.12), radius: 10, y: 4)
    }
}

struct SYSYLogoView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.sysyNavy, Color.sysyBlue, Color(red: 0.02, green: 0.12, blue: 0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(colors: [Color.sysyGoldLight, Color.sysyGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 2
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
                    .foregroundStyle(Color.sysyGoldLight)
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
            .shadow(color: Color.sysyNavy.opacity(0.18), radius: 5, y: 2)
    }
}

/// Branded opening screen shown when SYSY FAMILY starts.
struct LaunchSplashView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.sysyNavy, Color.sysyBlue, Color(red: 0.02, green: 0.10, blue: 0.22)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 18) {
                SYSYLogoView()
                    .frame(width: 150, height: 150)
                    .shadow(color: Color.sysyGold.opacity(0.28), radius: 18, y: 8)
                Text("SYSY FAMILY")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .tracking(1.5)
                    .foregroundStyle(.white)
                Text("Aluminium Doors & Windows")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.sysyGoldLight)
            }
            .padding(24)
        }
        .ignoresSafeArea()
        .accessibilityLabel("SYSY FAMILY opening screen")
    }
}
