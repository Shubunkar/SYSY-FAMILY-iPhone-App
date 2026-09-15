import SwiftUI

@main
struct SYSY_FAMILYApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(AppDataStore())
        }
    }
}
