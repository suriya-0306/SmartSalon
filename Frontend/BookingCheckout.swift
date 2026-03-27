import SwiftUI

struct BookingCheckoutView: View {

    // ✅ DATA RECEIVED FROM TimeBookingView
    let appointment: AppointmentDraft

    // Navigation trigger
    @State private var goToPayment = false

    // Simple discount logic
    private let discount: Int = 30

    private var totalAmount: Int {
        appointment.amount - discount
    }

    var body: some View {
        ZStack {

            // Background
            Color(red: 1.0, green: 0.55, blue: 0.75)
                .ignoresSafeArea()

            VStack {

                Spacer(minLength: 60)

                // CARD
                VStack(spacing: 25) {

                    Text("Booking Checkout")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(red: 0.82, green: 0.94, blue: 1.0))
                        .shadow(color: .black.opacity(0.15), radius: 5)
                        .overlay(
                            VStack(alignment: .leading, spacing: 20) {

                                // DATE & TIME
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Date")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(appointment.appointmentDate)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Start Time")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(appointment.appointmentTime)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                }

                                Divider()

                                // SERVICE
                                Text("Service")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                HStack {
                                    Text(appointment.service)
                                    Spacer()
                                    Text("Rs \(appointment.amount)")
                                        .fontWeight(.semibold)
                                }

                                Divider()

                                // PRICE BREAKDOWN
                                HStack {
                                    Text("Sub Total")
                                    Spacer()
                                    Text("Rs \(appointment.amount)")
                                        .fontWeight(.semibold)
                                }

                                HStack {
                                    Text("Discount")
                                    Spacer()
                                    Text("-Rs \(discount)")
                                        .foregroundColor(.red)
                                        .fontWeight(.bold)
                                }

                                Divider()

                                HStack {
                                    Text("Total")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("Rs \(totalAmount)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }

                                // PAYMENT METHOD CARD (UI ONLY)
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(red: 0.85, green: 1.0, blue: 0.90))
                                    .overlay(
                                        HStack {
                                            Image(systemName: "creditcard.fill")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 22))

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Suriya")
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                Text("3124325***")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 12)
                                    )
                                    .frame(height: 60)
                                    .padding(.top, 5)
                            }
                            .padding(22)
                        )
                }
                .padding(.horizontal, 22)

                Spacer(minLength: 80)

                // PAY NOW BUTTON
                Button {
                    goToPayment = true
                } label: {
                    Text("Pay Now")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.green)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 22)

                Spacer(minLength: 25)
            }
        }
        .navigationDestination(isPresented: $goToPayment) {
            // ✅ PASS FULL APPOINTMENT OBJECT
            PaymentOptionsView(
                appointment: AppointmentDraft(
                    userEmail: appointment.userEmail,
                    service: appointment.service,
                    appointmentDate: appointment.appointmentDate,
                    appointmentTime: appointment.appointmentTime,
                    hairstyleImage: appointment.hairstyleImage,
                    address: appointment.address,
                    amount: totalAmount   // final payable amount
                )
            )
        }
    }
}

