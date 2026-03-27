import SwiftUI

struct SlotBookingView: View {

    // ✅ Received from MySalonView
    let selectedService: String
    let salonAddress: String        // ✅ NEW (from MySalonView)

    // ✅ Date selection
    @State private var selectedDate: Date = Date()

    // ✅ Navigation trigger
    @State private var goTimeBooking = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // TITLE
                Text("Available on")
                    .font(.headline)
                    .padding(.horizontal)

                // DATE PICKER
                VStack(alignment: .leading) {

                    Text("Choose Date")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .accentColor(.black)
                    .padding(.horizontal, -10)
                }
                .padding(.horizontal)

                // SHOW TIMINGS BUTTON
                Button(action: {
                    goTimeBooking = true
                }) {
                    Text("Show Timings")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(30)
                }
                .padding(.horizontal)
                .padding(.top, 25)

                // ✅ HIDDEN NAVIGATION → PASS DATE + SERVICE + ADDRESS
                NavigationLink(
                    "",
                    destination: TimeBookingView(
                        selectedDate: formattedDate,     // ✅ yyyy-MM-dd
                        selectedService: selectedService,
                        salonAddress: salonAddress
                    ),
                    isActive: $goTimeBooking
                )
                .hidden()
            }
            .padding(.top, 10)
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

    // ✅ FORMAT DATE FOR BACKEND (DB SAFE)
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: selectedDate)
    }
}

struct SlotBookingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SlotBookingView(
                selectedService: "Haircut",
                salonAddress: "No:209, Chennai–Bangalore Highway, Thandalam"
            )
        }
    }
}
