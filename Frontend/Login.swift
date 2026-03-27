import SwiftUI

struct LoginPage: View {

    @State private var email = ""
    @State private var password = ""
    @State private var role = "Select Role"

    @State private var goCustomerHome = false
    @State private var goAdminHome = false
    @State private var goSignUp = false
    @State private var goReset = false

    @State private var showEmailError = false
    @State private var showPasswordError = false

    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    // ✅ SESSION STORAGE (CONSISTENT)
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("username") private var username: String = ""

    let roles = ["Customer", "Admin"]

    var body: some View {
        NavigationStack {
            ZStack {

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

                VStack(alignment: .leading, spacing: 12) {

                    Text("SMART\nSALON")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Best Stylist For You")
                        .opacity(0.7)
                        .padding(.bottom, 20)

                    // ROLE PICKER
                    Menu {
                        ForEach(roles, id: \.self) { item in
                            Button(item) { role = item }
                        }
                    } label: {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .frame(height: 50)
                            .overlay(
                                HStack {
                                    Text(role)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding(.horizontal)
                            )
                    }

                    // EMAIL
                    HStack {
                        Image(systemName: "envelope")
                        TextField("E-Mail", text: $email)
                            .foregroundColor(Color(red: 0.0, green: 0.6, blue: 0.65))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)

                    if showEmailError {
                        Text("Invalid email format")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.leading, 8)
                    }

                    // PASSWORD
                    HStack {
                        Image(systemName: "lock")
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)

                    if showPasswordError {
                        Text("Invalid password format")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.leading, 8)
                    }

                    // RESET
                    HStack {
                        Spacer()
                        Button("Reset Password?") {
                            goReset = true
                        }
                        .foregroundColor(.blue)
                    }

                    // LOGIN BUTTON
                    Button(action: loginUser) {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Log In")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(30)
                    .padding(.top, 10)
                    .disabled(isLoading)

                    // SIGN UP
                    HStack {
                        Spacer()
                        Text("Don’t have an account?")
                        Button("Sign Up") {
                            goSignUp = true
                        }
                        .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.top, 10)

                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)

                // NAVIGATION
                NavigationLink("", destination: Tabbar(), isActive: $goCustomerHome).hidden()
                NavigationLink("", destination: AdminMainView(), isActive: $goAdminHome).hidden()
                NavigationLink("", destination: SignUpPage(), isActive: $goSignUp).hidden()
                NavigationLink("", destination: ResetPasswordView(), isActive: $goReset).hidden()
            }
            .navigationBarBackButtonHidden(true)
            .alert("Message", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - LOGIN API
    func loginUser() {

        showEmailError = false
        showPasswordError = false

        guard roles.contains(role) else {
            alertMessage = "Please select role"
            showAlert = true
            return
        }

        if !isValidEmail(email) {
            showEmailError = true
            return
        }

        if password.isEmpty {
            showPasswordError = true
            return
        }

        isLoading = true

        let url = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/login.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body =
        "email=\(email)&password=\(password)&role=\(role.lowercased())"

        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in

            DispatchQueue.main.async {
                isLoading = false
            }

            guard let data = data else { return }

            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

                DispatchQueue.main.async {

                    if let status = response["status"] as? Bool, status == true {

                        let userId = response["user_id"] as? Int ?? 0
                        let userRole = (response["role"] as? String ?? "").lowercased()
                        let fetchedUsername = response["username"] as? String ?? "Guest"

                        // ✅ SAVE SESSION (FINAL & CORRECT)
                        UserDefaults.standard.set(userId, forKey: "user_id")
                        UserDefaults.standard.set(userRole, forKey: "role")
                        UserDefaults.standard.set(email, forKey: "userEmail")
                        UserDefaults.standard.set(fetchedUsername, forKey: "username")

                        if userRole == "admin" {
                            goAdminHome = true
                        } else if userRole == "customer" {
                            goCustomerHome = true
                        }

                    } else {
                        alertMessage = response["message"] as? String ?? "Login failed"
                        showAlert = true
                    }
                }
            }
        }.resume()
    }

    // VALIDATORS
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.com"
        return NSPredicate(format: "SELF MATCHES %@", regex)
            .evaluate(with: email)
    }
}
