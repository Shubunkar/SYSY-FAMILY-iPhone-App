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

struct ProfileAvatar: View {
    var size: CGFloat = 58
    var body: some View {
        Image("Profile")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.sysyGold, lineWidth: 2))
    }
}
