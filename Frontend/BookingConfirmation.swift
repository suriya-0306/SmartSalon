import SwiftUI

struct BookingSuccessPage: View {
    
    // 0 = Upcoming, 1 = Completed, 2 = Cancelled
    @State private var selectedTab: Int = 0
    @State private var goToMySalon = false
    @State private var bookings: [CustomerBooking] = []
    
    @AppStorage("userEmail") var userEmail = ""
    
    
    var body: some View {
        
        GeometryReader { geo in
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
                
                VStack {
                    
                    // Title
                    Text("My Appointments")
                        .font(.headline)
                        .padding(.top, max(12, geo.safeAreaInsets.top))
                    
                    // Tabs
                    HStack(spacing: 10) {
                        tabButton("Upcoming", 0)
                        tabButton("Completed", 1)
                        tabButton("Cancelled", 2)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 14) {
                            
                            ForEach(filteredBookings()) { booking in
                                bookingCard(booking: booking)
                            }
                            
                            if filteredBookings().isEmpty {
                                Text("No appointments found")
                                    .foregroundColor(.white)
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                
                NavigationLink(
                    destination: MySalonView(),
                    isActive: $goToMySalon
                ) { EmptyView() }
            }
        }
        .onAppear {
            fetchAppointments()
        }
    }
    
    // MARK: - Tabs
    func tabButton(_ title: String, _ index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            Text(title)
                .font(.subheadline)
                .foregroundColor(selectedTab == index ? .white : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    selectedTab == index
                    ? Color.black
                    : Color.white.opacity(0.6)
                )
                .cornerRadius(20)
        }
    }
    func bookAppointment() {

        // 🔴 MUST NOT BE EMPTY
        guard let email = UserDefaults.standard.string(forKey: "userEmail"),
              !email.isEmpty else {
            print("❌ userEmail missing")
            return
        }

        let userName =
            UserDefaults.standard.string(forKey: "userName") ?? "Customer"

        let urlString = "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/book_appointment.php"
        guard let url = URL(string: urlString) else { return }

        let body: [String: Any] = [
            "user_email": email,
            "customer_name": userName,
            "payment_option": "UPI"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("❌ Booking API error:", error)
                return
            }

            guard let data = data else {
                print("❌ No response data")
                return
            }

            print("📦 Booking raw response:",
                  String(data: data, encoding: .utf8) ?? "")

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("✅ Booking response JSON:", json)

                if json["status"] as? Bool == true {
                    DispatchQueue.main.async {
                        // 🔥 FORCE APPOINTMENT SCREEN REFRESH
                        NotificationCenter.default.post(
                            name: Notification.Name("APPOINTMENT_REFRESH"),
                            object: nil
                        )
                    }
                }
            }

        }.resume()
    }

    // MARK: - Filtered Data
    func filteredBookings() -> [CustomerBooking] {
        switch selectedTab {
        case 0:
            return bookings.filter { $0.status == "Upcoming" }
        case 1:
            return bookings.filter { $0.status == "Completed" }
        default:
            return bookings.filter { $0.status == "Cancelled" }
        }
    }
    
    // MARK: - Booking Card
    func bookingCard(booking: CustomerBooking) -> some View {
        
        let statusColor: Color =
        booking.status == "Upcoming" ? .orange :
        booking.status == "Completed" ? .green : .red
        
        return VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Spacer()
                Text(booking.status)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .clipShape(Capsule())
            }
            
            Text(booking.service)
                .font(.headline)
            
            Text("\(booking.appointment_date) at \(booking.appointment_time)")
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))
            
            // ACTION BUTTON
            if booking.status == "Upcoming" {
                Button {
                    cancelBooking(booking)
                } label: {
                    actionButton("Cancel Booking")
                }
            }
            
            if booking.status == "Completed" {
                Button {
                    goToMySalon = true
                } label: {
                    actionButton("Book Again")
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.1), radius: 8)
    }
    
    // MARK: - Button Style
    func actionButton(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black)
            .cornerRadius(16)
    }
    // MARK: - API: Fetch
    func fetchAppointments() {
        
        let encodedEmail = userEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/customer_appointment.php?email=\(encodedEmail)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ API error:", error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(Response.self, from: data)
                DispatchQueue.main.async {
                    self.bookings = response.appointments
                    print("✅ Fetched:", response.appointments.count)
                }
            } catch {
                print("❌ Decode error:", error)
            }
        }.resume()
    }
    
    
    // MARK: - API: Cancel
    func cancelBooking(_ booking: CustomerBooking) {
        
        guard !userEmail.isEmpty else { return }
        
        guard let url = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/cancel_appointment.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body =
        "email=\(userEmail)&service=\(booking.service)&appointment_date=\(booking.appointment_date)&appointment_time=\(booking.appointment_time)"
        
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                selectedTab = 2
                fetchAppointments()
            }
        }.resume()
    }
}

// MARK: - API Response
struct Response: Codable {
    let status: Bool
    let appointments: [CustomerBooking]
}
struct CustomerBooking: Identifiable, Codable {
    let id = UUID()   // local only
    let service: String
    let appointment_date: String
    let appointment_time: String
    let status: String
}
#Preview {
    BookingSuccessPage()
}
