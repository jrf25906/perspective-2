import SwiftUI

struct ContentView: View {
    @EnvironmentObject var apiService: APIService
    @EnvironmentObject var appStateManager: AppStateManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var offlineDataManager: OfflineDataManager
    @State private var showWelcome = true
    
    var body: some View {
        Group {
            if showWelcome {
                WelcomeView {
                    print("🔄 Continue button tapped - setting showWelcome to false")
                    withAnimation {
                        showWelcome = false
                    }
                    print("🔄 showWelcome is now: \(showWelcome)")
                    print("🔄 isAuthenticated is: \(apiService.isAuthenticated)")
                }
                .onAppear {
                    print("🔄 WelcomeView appeared")
                }
            } else if apiService.isAuthenticated {
                ZStack {
                    MainTabView()
                        .environmentObject(appStateManager)
                    
                    // Offline indicator
                    if !networkMonitor.isConnected {
                        VStack {
                            Spacer()
                            OfflineIndicatorView()
                                .padding(.bottom, 100) // Above tab bar
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: networkMonitor.isConnected)
                    }
                    
                    // Sync indicator
                    if offlineDataManager.pendingSyncCount > 0 && networkMonitor.isConnected {
                        VStack {
                            SyncIndicatorView(pendingCount: offlineDataManager.pendingSyncCount)
                                .padding(.top, 50)
                            Spacer()
                        }
                        .transition(.move(edge: .top))
                        .animation(.easeInOut, value: offlineDataManager.pendingSyncCount)
                    }
                }
            } else {
                AuthenticationView()
                    .onAppear {
                        print("🔄 AuthenticationView appeared - showWelcome: \(showWelcome), isAuthenticated: \(apiService.isAuthenticated)")
                    }
            }
        }
        .onAppear {
            // Check authentication status on app launch
            if apiService.isAuthenticated {
                showWelcome = false // Skip welcome if already authenticated
            } else {
                apiService.fetchProfile()
            }
        }
    }
}

struct OfflineIndicatorView: View {
    var body: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundColor(.white)
            Text("You're offline")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.orange)
        .cornerRadius(20)
        .shadow(radius: 4)
    }
}

struct SyncIndicatorView: View {
    let pendingCount: Int
    
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            
            Text("Syncing \(pendingCount) item\(pendingCount == 1 ? "" : "s")...")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(APIService.shared)
            .environmentObject(AppStateManager.shared)
            .environmentObject(NetworkMonitor.shared)
            .environmentObject(OfflineDataManager())
    }
}
