import SwiftUI

struct SignUpPage: View {
    @Environment(\.dismiss) var dismiss

    @State private var role = "Role"
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""

    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    let roles = ["Customer", "Admin"]

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

            VStack(alignment: .leading, spacing: 18) {

                Text("Create a Account")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 40)

                // Role Picker
                Menu {
                    ForEach(roles, id: \.self) { item in
                        Button(item) { role = item }
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white.opacity(0.95))
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

                // Username
                TextField("User Name", text: $username)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(25)

                // Email
                HStack {
                    Image(systemName: "envelope")
                    TextField("E - Mail", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                .padding()
                .frame(height: 50)
                .background(Color.white.opacity(0.95))
                .cornerRadius(25)

                // Phone
                HStack {
                    Image(systemName: "phone")
                    TextField("Phone", text: $phone)
                        .keyboardType(.numberPad)
                }
                .padding()
                .frame(height: 50)
                .background(Color.white.opacity(0.95))
                .cornerRadius(25)

                // Password
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $password)
                }
                .padding()
                .frame(height: 50)
                .background(Color.white.opacity(0.95))
                .cornerRadius(25)

                // JOIN NOW (API CALL)
                Button(action: signupUser) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Join Now")
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .cornerRadius(30)
                .padding(.top, 10)
                .disabled(isLoading)

                // OR Divider
                HStack {
                    Rectangle().frame(height: 1).opacity(0.3)
                    Text("or").opacity(0.6)
                    Rectangle().frame(height: 1).opacity(0.3)
                }
                .padding(.top, 6)

                // Back to Login
                HStack {
                    Text("Already have an account?")
                    Button("Log In") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                .font(.footnote)
                .padding(.bottom, 30)

                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .alert("Message", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage == "Signup successful" {
                    dismiss()   // ✅ Go back to Login
                }
            }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - SIGNUP API
    func signupUser() {

        guard role != "Role",
              !username.isEmpty,
              !email.isEmpty,
              !phone.isEmpty,
              !password.isEmpty else {
            alertMessage = "All fields are required"
            showAlert = true
            return
        }

        isLoading = true

        let url = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/signup.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body =
        "role=\(role.lowercased())&username=\(username)&email=\(email)&phone=\(phone)&password=\(password)"

        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
            }

            guard let data = data else { return }

            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    alertMessage = response["message"] as? String ?? "Something went wrong"
                    showAlert = true
                }
            }
        }.resume()
    }
}

struct SignUpPage_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPage()
    }
}
