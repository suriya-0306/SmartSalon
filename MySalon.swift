import SwiftUI

// MARK: - MAIN VIEW
struct MySalonView: View {

    // Salon Data (static for now)
    let salon = Salon(
        name: "Suriya Salon",
        rating: "4.8",
        status: "Open Now",
        services: ["Haircut", "Beard Trim", "Shave", "Coloring"],
        address: "No:209, Chennai–Bangalore Highway, Thandalam",
        images: ["image 1", "image 2", "image 3"]
    )

    // Selected Service State
    @State private var selectedService: String? = nil

    var body: some View {
        NavigationStack {

            VStack(spacing: 0) {

                // TITLE
                HStack {
                    Text("My Salon")
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 15)

                // CONTENT
                ScrollView {
                    SalonCardView(
                        salon: salon,
                        selectedService: $selectedService
                    )
                    .padding()
                }
            }
            .background(
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
            )
        }
    }
}

// MARK: - SALON CARD VIEW
struct SalonCardView: View {

    let salon: Salon
    @Binding var selectedService: String?

    @State private var currentIndex = 0
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var statusColor: Color {
        salon.status == "Open Now" ? .green : .gray
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            // IMAGE SLIDER
            ZStack(alignment: .topLeading) {

                TabView(selection: $currentIndex) {
                    ForEach(0..<salon.images.count, id: \.self) { index in
                        Image(salon.images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 190)
                            .clipped()
                            .cornerRadius(18)
                            .tag(index)
                    }
                }
                .frame(height: 190)
                .tabViewStyle(PageTabViewStyle())
                .onReceive(timer) { _ in
                    withAnimation {
                        currentIndex = (currentIndex + 1) % salon.images.count
                    }
                }

                // STATUS TAG
                Text(salon.status)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(statusColor)
                    .cornerRadius(12)
                    .padding(10)
            }

            // SALON NAME
            Text(salon.name)
                .font(.title3)
                .bold()

            // RATING
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text(salon.rating)
            }

            // ADDRESS
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                Text(salon.address)
                    .font(.caption)
            }

            Divider().opacity(0.3)

            // SERVICES
            Text("Available Services")
                .font(.headline)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(salon.services, id: \.self) { service in
                    ServiceChip(
                        title: service,
                        isSelected: selectedService == service
                    )
                    .onTapGesture {
                        selectedService = service
                    }
                }
            }

            // ✅ BOOK BUTTON → PASS SERVICE + ADDRESS
            NavigationLink(
                destination: SlotBookingView(
                    selectedService: selectedService ?? "",
                    salonAddress: salon.address
                )
            ) {
                Text("Book Appointment")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedService == nil ? Color.gray : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(24)
            }
            .disabled(selectedService == nil)
            .padding(.top, 10)
        }
        .padding()
        .background(Color.white.opacity(0.75))
        .cornerRadius(22)
        .shadow(radius: 4)
    }
}

// MARK: - SERVICE CHIP
struct ServiceChip: View {

    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundColor(isSelected ? .white : .black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Color.black : Color.white)
            .cornerRadius(14)
    }
}

// MARK: - SALON MODEL
struct Salon: Identifiable {

    let id = UUID()
    let name: String
    let rating: String
    let status: String
    let services: [String]
    let address: String
    let images: [String]
}

// MARK: - PREVIEW
struct MySalonView_Previews: PreviewProvider {
    static var previews: some View {
        MySalonView()
    }
}
