import SwiftUI

@main
struct SYSY_FAMILYApp: App {
    @StateObject private var store = AppDataStore()
    @State private var showLaunchScreen = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                MainTabView()
                    .environmentObject(store)

                if showLaunchScreen {
                    LaunchSplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                withAnimation(.easeOut(duration: 0.25)) {
                    showLaunchScreen = false
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
