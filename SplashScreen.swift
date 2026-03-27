import SwiftUI

struct SplashScreen: View {
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    @State private var goToLogin = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.76, blue: 0.88),
                    Color(red: 0.98, green: 0.60, blue: 0.78),
                    Color(red: 0.95, green: 0.42, blue: 0.65)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Image("logo1")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
                        scale = 1.0
                        opacity = 1.0
                    }

                    /// NAVIGATE AFTER ANIMATION
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        goToLogin = true
                    }
                }

            NavigationLink("", destination: LoginPage(), isActive: $goToLogin)
                .hidden()
        }
    }
}
