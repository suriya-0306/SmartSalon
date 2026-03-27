import SwiftUI

struct TimeBookingView: View {

    // ✅ Received from SlotBookingView
    let selectedDate: String        // ✅ yyyy-MM-dd (DB READY)
    let selectedService: String
    let salonAddress: String        // ✅ From MySalonView
    let userEmail = UserDefaults.standard.string(forKey: "user_email") ?? ""

    // ✅ Time selection
    @State private var selectedTime: String? = nil

    // Sample service data (can be dynamic later)
    let servicePrice: Int = 150

    // Available time slots (UI format)
    let timeSlots = [
        "09.00 AM", "10.00 AM", "11.00 AM",
        "12.00 PM", "01.00 PM", "02.00 PM",
        "03.00 PM", "04.00 PM", "06.00 PM"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {

                // TITLE
                HStack {
                    Text("Select Time")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // TIME GRID
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 3),
                    spacing: 15
                ) {
                    ForEach(timeSlots, id: \.self) { time in
                        Button {
                            selectedTime = time
                        } label: {
                            Text(time)
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    selectedTime == time
                                    ? Color.black.opacity(0.8)
                                    : Color.black.opacity(0.65)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)

                // SELECTED SERVICE INFO
                VStack(alignment: .leading, spacing: 10) {

                    Text("Selected Service")
                        .font(.headline)

                    HStack {
                        Text(selectedService)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.purple.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(25)

                        Spacer()

                        Text("Rs: \(servicePrice)")
                            .font(.subheadline)
                            .bold()
                    }
                }
                .padding(.horizontal)

                // CONFIRM BOOKING → SEND DB-SAFE DATA
                NavigationLink(
                    destination: BookingCheckoutView(
                        appointment:AppointmentDraft(
                            userEmail: UserDefaults.standard.string(forKey: "user_email") ?? "",
                            service: selectedService,
                            appointmentDate: selectedDate,
                            appointmentTime: formattedTime,
                            hairstyleImage: nil,
                            address: salonAddress,
                            amount: servicePrice
                        )
                    )
                ) {
                    Text("Confirm Booking")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedTime == nil ? Color.gray : Color.black)
                        .cornerRadius(30)
                }
                .disabled(selectedTime == nil)
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer(minLength: 40)
            }
            .padding(.top, 5)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.76, blue: 0.88),
                    Color(red: 0.98, green: 0.60, blue: 0.78),
                    Color(red: 0.95, green: 0.42, blue: 0.65)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .edgesIgnoringSafeArea(.bottom)
    }

    // ✅ FORMAT TIME FOR DB (HH:mm:ss)
    private var formattedTime: String {
        guard let selectedTime else { return "" }

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "hh.mm a"   // UI format

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "HH:mm:ss" // DB format

        if let date = inputFormatter.date(from: selectedTime) {
            return outputFormatter.string(from: date)
        }
        return ""
    }
}

struct TimeBookingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TimeBookingView(
                selectedDate: "2025-01-22",
                selectedService: "Haircut",
                salonAddress: "No:209, Chennai–Bangalore Highway, Thandalam"
            )
        }
    }
}
