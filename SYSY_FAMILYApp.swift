import SwiftUI

@main
struct SYSY_FAMILYApp: App {
    @StateObject private var store = AppDataStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}
