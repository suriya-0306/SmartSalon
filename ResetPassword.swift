import SwiftUI

// MARK: - RESET PASSWORD (STEP 1)
struct ResetPasswordView: View {

    @State private var email: String = ""
    @State private var goNewPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {

            // BACKGROUND
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

            VStack(alignment: .leading, spacing: 24) {

                // TITLE
                Text("Reset\nPassword")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 36)

                // EMAIL FIELD
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)

                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal)
                    .frame(height: 52)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3)
                }

                // BUTTON
                Button {
                    validateEmail()
                } label: {
                    Text("Reset Password")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.black)
                        .cornerRadius(26)
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 3, y: 4)
                }
                .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal, 24)

            // NAVIGATION
            NavigationLink(
                destination: NewPasswordView(email: email),
                isActive: $goNewPassword
            ) {
                EmptyView()
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - EMAIL VALIDATION
    private func validateEmail() {

        if email.isEmpty {
            alertMessage = "Please enter email"
            showAlert = true
            return
        }

        if !email.contains("@") || !email.contains(".") {
            alertMessage = "Please enter a valid email"
            showAlert = true
            return
        }

        goNewPassword = true
    }
}

// MARK: - NEW PASSWORD (STEP 2)
struct NewPasswordView: View {

    let email: String

    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var toLogin = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        ZStack {

            // BACKGROUND
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

            VStack(alignment: .leading, spacing: 24) {

                Text("New password,")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 20)

                Text("Now, you can create new password and confirm it below")
                    .font(.system(size: 15))
                    .foregroundColor(.black.opacity(0.7))

                VStack(spacing: 16) {

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("New password", text: $newPassword)
                    }
                    .padding(.horizontal)
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.08), radius: 4)

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Confirm new password", text: $confirmPassword)
                    }
                    .padding(.horizontal)
                    .frame(height: 52)
                    .background(Color.white)
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.08), radius: 4)
                }

                Button {
                    validatePasswords()
                } label: {
                    Text("Confirm New Password")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.black)
                        .cornerRadius(26)
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 3, y: 4)
                }
                .padding(.top, 10)

                Spacer()
            }
            .padding(.horizontal, 24)

            NavigationLink(
                destination: LoginPage(),
                isActive: $toLogin
            ) {
                EmptyView()
            }
        }
        .alert("Message", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - VALIDATION
    private func validatePasswords() {

        if newPassword.isEmpty || confirmPassword.isEmpty {
            alertMessage = "Please fill all fields"
            showAlert = true
            return
        }

        if newPassword.count < 6 {
            alertMessage = "Password must be at least 6 characters"
            showAlert = true
            return
        }

        if newPassword != confirmPassword {
            alertMessage = "Passwords do not match"
            showAlert = true
            return
        }

        updatePasswordAPI()
    }

    // MARK: - API CALL
    private func updatePasswordAPI() {

        guard let url = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/newpassword.php") else {
            alertMessage = "Invalid server URL"
            showAlert = true
            return
        }

        let bodyString =
            "email=\(email)&new_password=\(newPassword)&confirm_password=\(confirmPassword)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in

            DispatchQueue.main.async {

                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                    return
                }

                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let status = json["status"] as? Bool,
                      let message = json["message"] as? String else {

                    alertMessage = "Invalid server response"
                    showAlert = true
                    return
                }

                if status {
                    alertMessage = message
                    showAlert = true
                    toLogin = true
                } else {
                    alertMessage = message
                    showAlert = true
                }
            }

        }.resume()
    }
}

// MARK: - PREVIEW
struct ResetPasswordFlow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ResetPasswordView()
        }
    }
}
