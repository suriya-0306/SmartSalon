import SwiftUI
import PhotosUI

// MARK: - BACKGROUND
struct PinkBackground<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.80, blue: 0.90),
                Color(red: 0.98, green: 0.65, blue: 0.82),
                Color(red: 0.95, green: 0.45, blue: 0.70)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(content)
    }
}

// MARK: - MAIN TAB
struct AdminMainView: View {
    var body: some View {
        TabView {
            AdminDashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "rectangle.grid.2x2.fill")
                }

            AdminProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

// MARK: - DASHBOARD
struct AdminDashboardView: View {

    @State private var bookings: [AdminBooking] = []

    var body: some View {
        NavigationStack {
            PinkBackground {
                ScrollView {
                    VStack(spacing: 24) {

                        VStack(alignment: .leading) {
                            Text("Admin Dashboard")
                                .font(.largeTitle)
                                .bold()
                            Text("All customer bookings")
                                .foregroundColor(.white.opacity(0.85))
                        }

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                            stat("Total", bookings.count, .blue)
                            stat("Completed", bookings.filter { $0.status == "Completed" }.count, .green)
                            stat("Pending", bookings.filter { $0.status != "Completed" }.count, .orange)
                        }

                        ForEach(bookings.indices, id: \.self) { i in
                            NavigationLink {
                                AdminBookingDetailsView(
                                    booking: $bookings[i],
                                    onUpdate: fetchBookings   // 🔑 refresh trigger
                                )
                            } label: {
                                AdminBookingRow(booking: bookings[i])
                            }
                        }
                    }
                    .padding()
                }
            }
            .onAppear {
                fetchBookings()
            }
        }
    }

    // MARK: - API FETCH
    func fetchBookings() {
        let url = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/get_appointments.php")!

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                print("❌ API error:", error)
                return
            }

            guard let data else { return }

            do {
                let decoded = try JSONDecoder()
                    .decode(AdminBookingResponse.self, from: data)

                DispatchQueue.main.async {
                    bookings = decoded.appointments
                }
            } catch {
                print("❌ Decode error:", error)
            }
        }.resume()
    }

    func stat(_ title: String, _ value: Int, _ color: Color) -> some View {
        VStack {
            Text("\(value)")
                .font(.title)
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(.white)
        .cornerRadius(16)
    }
}

// MARK: - BOOKING ROW
struct AdminBookingRow: View {
    let booking: AdminBooking

    var body: some View {
        HStack(spacing: 14) {

            AsyncImage(url: URL(string: booking.hairstyleImageURL)) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading) {
                Text(booking.service).bold()
                Text(booking.customerName)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(booking.status)
                .font(.caption)
                .padding(8)
                .background(
                    booking.status == "Completed"
                    ? Color.green.opacity(0.25)
                    : Color.orange.opacity(0.25)
                )
                .cornerRadius(10)
        }
        .padding()
        .background(.white)
        .cornerRadius(16)
    }
}

// MARK: - BOOKING DETAILS
struct AdminBookingDetailsView: View {

    @Binding var booking: AdminBooking
    let onUpdate: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var isUpdating = false
    @State private var errorMessage: String?

    var body: some View {
        PinkBackground {
            ScrollView {
                VStack(spacing: 20) {

                    AsyncImage(url: URL(string: booking.hairstyleImageURL)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 220)
                    .cornerRadius(20)

                    info("Customer", booking.customerName)
                    info("Service", booking.service)
                    info("Date", booking.appointment_date)
                    info("Time", booking.appointment_time)
                    info("Payment", booking.payment_option)
                    info("Status", booking.status)

                    if booking.status != "Completed" {
                        Button {
                            updateStatus()
                        } label: {
                            if isUpdating {
                                ProgressView().tint(.white)
                            } else {
                                Text("Mark as Completed")
                                    .bold()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .disabled(isUpdating)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - UPDATE STATUS (FIXED)
    func updateStatus() {
        let url = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/update_appointment_status.php")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = "id=\(booking.id)&status=Completed".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, _, error in

            if let error {
                print("❌ Network error:", error)
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let response: StatusUpdateResponse =
                    try JSONDecoder().decode(StatusUpdateResponse.self, from: data)

                DispatchQueue.main.async {
                    if response.status {
                        onUpdate()   // refresh dashboard
                    } else {
                        print("ℹ️", response.message)
                    }
                    dismiss()
                }

            } catch {
                print("❌ Decode error:", error)
            }

        }.resume()
    }

    func info(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundColor(.gray)
            Spacer()
            Text(value).bold()
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
    }
}
struct StatusUpdateResponse: Codable {
    let status: Bool
    let message: String
}


// MARK: - PROFILE
// MARK: - PROFILE
struct AdminProfileView: View {

    @State private var selectedItem: PhotosPickerItem?
    @State private var profileUIImage: UIImage?
    @State private var goToLogin = false   // ✅ NEW

    let adminEmail = "suriya0000@gmail.com"

    var body: some View {
        NavigationStack {
            PinkBackground {
                VStack(spacing: 20) {

                    // ✅ PROFILE IMAGE + CAMERA (UNCHANGED)
                    ZStack {
                        if let img = profileUIImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.white)
                        }

                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Image(systemName: "camera.fill")
                                .padding(10)
                                .background(.white)
                                .clipShape(Circle())
                        }
                        .offset(x: 40, y: 40)
                    }

                    Text("Admin")
                        .font(.title)
                        .bold()

                    Text(adminEmail)
                        .foregroundColor(.white.opacity(0.85))

                    // ✅ ONLY ADDITION — LOGOUT BUTTON
                    Button {
                        logout()
                    } label: {
                        Text("Logout")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // ✅ Navigation after logout
                    NavigationLink("", destination: LoginPage(), isActive: $goToLogin)
                }
                .padding()
            }
        }
        .onAppear(perform: fetchProfile)
        .onChange(of: selectedItem) { uploadImage($0) }
    }

    // MARK: - LOGOUT LOGIC (NEW)
    func logout() {
        UserDefaults.standard.removeObject(forKey: "adminEmail")
        goToLogin = true
    }

    // MARK: - FETCH PROFILE (UNCHANGED)
    func fetchProfile() {
        let url = URL(string:
            "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/get_admin_profile.php?email=\(adminEmail)"
        )!

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data,
                  let decoded = try? JSONDecoder()
                    .decode(AdminProfileResponse.self, from: data),
                  let path = decoded.profile.profile_image
            else { return }

            let imgURL = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/\(path)")!

            URLSession.shared.dataTask(with: imgURL) { data, _, _ in
                if let data, let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        profileUIImage = img
                    }
                }
            }.resume()
        }.resume()
    }

    // MARK: - UPLOAD IMAGE (UNCHANGED)
    func uploadImage(_ item: PhotosPickerItem?) {
        Task {
            guard let data = try? await item?.loadTransferable(type: Data.self) else { return }

            let url = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/update_admin_profile_image.php")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)",
                             forHTTPHeaderField: "Content-Type")

            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(adminEmail)\r\n".data(using: .utf8)!)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"profile_image\"; filename=\"admin.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

            request.httpBody = body

            URLSession.shared.dataTask(with: request) { _, _, _ in
                fetchProfile()
            }.resume()
        }
    }
}


// MARK: - MODELS
struct AdminBookingResponse: Codable {
    let status: Bool
    let appointments: [AdminBooking]
}

struct AdminBooking: Identifiable, Codable {
    let id: String
    let user_email: String
    let customerName: String
    let service: String
    let appointment_date: String
    let appointment_time: String
    let payment_option: String
    var status: String
    let hairstyle_image: String

    var hairstyleImageURL: String {
        hairstyle_image.isEmpty
        ? "https://via.placeholder.com/300"
        : "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/\(hairstyle_image)"
    }

    enum CodingKeys: String, CodingKey {
        case id, user_email, service, status, hairstyle_image
        case customerName = "customer_name"
        case appointment_date, appointment_time, payment_option
    }
}

struct AdminProfileResponse: Codable {
    let status: Bool
    let profile: AdminProfile
}

struct AdminProfile: Codable {
    let email: String
    let profile_image: String?
}
