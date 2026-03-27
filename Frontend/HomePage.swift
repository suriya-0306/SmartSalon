import SwiftUI

// MARK: - Home Screen
struct HomeView: View {
    
    // ✅ Logged-in customer email
    @AppStorage("username") private var username: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.76, blue: 0.88),
                        Color(red: 0.98, green: 0.60, blue: 0.78),
                        Color(red: 0.95, green: 0.42, blue: 0.65)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 22) {
                    
                    // MARK: - Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hello, \(username.isEmpty ? "Guest" : username)")
                            .font(.system(size: 26, weight: .bold))
                        
                        
                        Text("Find the service you want, and treat yourself!")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Buttons Grid
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2),
                        spacing: 16
                    ) {
                        
                        NavigationLink(destination: FaceShapeResultPage()) {
                            HomeButton(title: "Try Hairstyles")
                        }
                        
                        NavigationLink(destination: MySalonView()) {
                            HomeButton(title: "My Salon")
                        }
                        
                        NavigationLink(destination: BookingSuccessPage()) {
                            HomeButton(title: "Booking Details")
                        }
                        
                        NavigationLink(destination: ProfilePage()) {
                            HomeButton(title: "Profile")
                        }
                    }
                    
                    // MARK: - Section Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Try AI Hairstyles")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("See your new look instantly")
                            .font(.system(size: 14))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    // MARK: - Camera Section
                    HStack(spacing: 16) {
                        
                        Image(systemName: "camera")
                            .font(.system(size: 26))
                            .padding(12)
                            .background(Color.white.opacity(0.95))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                        
                        NavigationLink(destination: FaceShapeResultPage()) {
                            Text("Open Camera")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(26)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

//
// MARK: - Home Button Component (✅ FIXED: NOW IN SAME FILE)
//
struct HomeButton: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(Color.black.opacity(0.35))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
    }
}

//
// MARK: - Preview
//
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
