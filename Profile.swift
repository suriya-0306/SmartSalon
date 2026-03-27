import SwiftUI
import PhotosUI

struct ProfilePage: View {

    // Navigation
    @State private var goLogin = false
    @State private var goBooking = false

    // Delete confirmation
    @State private var showDeleteConfirm = false

    // Image
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?

    // Profile data
    @State private var profile: UserProfile?
    @State private var showAlert = false
    @State private var alertMessage = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {

                // Background
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.76, blue: 0.88),
                        Color(red: 0.98, green: 0.60, blue: 0.78),
                        Color(red: 0.95, green: 0.42, blue: 0.65)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {

                    // PROFILE IMAGE + INFO
                    VStack(spacing: 12) {
                        ZStack {
                            if let profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 95, height: 95)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 95, height: 95)
                                    .foregroundColor(.black.opacity(0.85))
                            }

                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Image(systemName: "camera.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                                    .background(Color.white.clipShape(Circle()))
                            }
                            .offset(x: 34, y: 30)
                        }

                        Text(profile?.username ?? "Loading...")
                            .font(.system(size: 20, weight: .semibold))

                        Text(profile?.email ?? "")
                            .font(.system(size: 15))
                            .foregroundColor(.black.opacity(0.7))

                        Text(profile?.phone ?? "")
                            .font(.system(size: 15))
                            .foregroundColor(.black.opacity(0.7))
                    }

                    // MY BOOKINGS
                    Button {
                        goBooking = true
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.rectangle")
                                .font(.system(size: 22, weight: .bold))
                            Text("My Bookings")
                                .font(.system(size: 19, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)

                    Spacer()

                    // LOGOUT + DELETE
                    VStack(spacing: 18) {

                        Button { dismiss() } label: {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.black)
                        }

                        Button {
                            logout()
                        } label: {
                            Text("Log Out")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal, 50)

                        Button {
                            showDeleteConfirm = true
                        } label: {
                            Text("Delete Account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.red, lineWidth: 2)
                                )
                        }
                        .padding(.horizontal, 50)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.top, 60)
            }

            // Navigation
            NavigationLink("", destination: LoginPage(), isActive: $goLogin).hidden()
            NavigationLink("", destination: BookingSuccessPage(), isActive: $goBooking).hidden()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: fetchProfile)

        // IMAGE PICKER → UPLOAD
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {

                    profileImage = Image(uiImage: uiImage)
                    uploadProfileImage(imageData: data)
                }
            }
        }

        // NORMAL ALERT
        .alert("Message", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }

        // DELETE CONFIRMATION
        .alert("Delete Account", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. Are you sure?")
        }
    }

    // MARK: - FETCH PROFILE
    private func fetchProfile() {

        // ✅ FIX: use correct key everywhere
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        guard !email.isEmpty else {
            alertMessage = "Please login again"
            showAlert = true
            return
        }

        let encodedEmail =
            email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let url =
            URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/getprofile.php?email=\(encodedEmail)")!

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data else { return }

            if let decoded = try? JSONDecoder().decode(ProfileResponse.self, from: data) {
                DispatchQueue.main.async {

                    // ✅ existing assignment
                    self.profile = decoded.data

                    // ✅ NEW: pass ONLY username to HomeView
                    UserDefaults.standard.set(
                        decoded.data.username,
                        forKey: "username"
                    )

                    // existing image logic
                    if let imagePath = decoded.data.profile_image {
                        loadServerImage(imagePath: imagePath)
                    }
                }
            }
        }.resume()
    }

    // MARK: - LOAD SERVER IMAGE
    private func loadServerImage(imagePath: String) {

        let fullURL =
        "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/\(imagePath)"

        guard let url = URL(string: fullURL) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }

    // MARK: - UPLOAD PROFILE IMAGE
    private func uploadProfileImage(imageData: Data) {

        let email = UserDefaults.standard.string(forKey: "user_email") ?? ""
        guard !email.isEmpty else { return }

        let url = URL(string:
          "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/updateprofile.php"
        )!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        // EMAIL
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(email)\r\n".data(using: .utf8)!)

        // IMAGE
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"profile_image\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request).resume()
    }

    // MARK: - DELETE ACCOUNT
    private func deleteAccount() {

        let email = UserDefaults.standard.string(forKey: "user_email") ?? ""
        guard !email.isEmpty else { return }

        let url = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/deleteaccount.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        let body =
        "email=\(email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        request.httpBody = body.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }

            if let response =
                try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = response["status"] as? Bool {

                DispatchQueue.main.async {
                    if status {
                        UserDefaults.standard.removeObject(forKey: "user_id")
                        UserDefaults.standard.removeObject(forKey: "user_email")
                        goLogin = true
                    } else {
                        alertMessage = response["message"] as? String ?? "Delete failed"
                        showAlert = true
                    }
                }
            }
        }.resume()
    }

    // MARK: - LOGOUT
    private func logout() {
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "user_email")
        goLogin = true
    }
}

// MARK: - MODELS
struct ProfileResponse: Codable {
    let status: Bool
    let data: UserProfile
}

struct UserProfile: Codable {
    let username: String
    let email: String
    let phone: String
    let profile_image: String?
}

#Preview {
    ProfilePage()
}
