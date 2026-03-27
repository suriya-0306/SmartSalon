import SwiftUI

struct DeleteAccountPage: View {

    @Environment(\.dismiss) var dismiss
    @State private var goLogin = false

    var body: some View {
        ZStack {

            // SAME BACKGROUND GRADIENT
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

            VStack(spacing: 25) {

                Spacer()

                // WARNING ICON
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.red)

                // TITLE
                Text("Delete Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // WARNING MESSAGE
                Text("""
                Are you sure you want to delete your account?

                This action is permanent.
                All your bookings, profile data, and history
                will be permanently removed.
                """)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.75))
                .padding(.horizontal, 30)

                Spacer()

                // DELETE BUTTON → LOGIN PAGE
                Button(action: {
                    // 🔴 Call delete API here later
                    goLogin = true
                }) {
                    Text("Delete My Account")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)

                // CANCEL BUTTON → BACK TO PROFILE ✅
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                }
                .padding(.horizontal, 40)

                Spacer()
            }

            // NAVIGATION TO LOGIN
            NavigationLink(
                "",
                destination: LoginPage(),
                isActive: $goLogin
            )
            .hidden()
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    DeleteAccountPage()
}
