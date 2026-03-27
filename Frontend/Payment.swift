import SwiftUI
import UIKit
import Razorpay

// MARK: - Razorpay Coordinator
class RazorpayCoordinator: NSObject, RazorpayPaymentCompletionProtocolWithData {

    private var razorpay: RazorpayCheckout?
    var onPaymentSuccess: ((String) -> Void)?
    var onPaymentError: ((String) -> Void)?

    override init() {
        super.init()
        razorpay = RazorpayCheckout.initWithKey(
            "rzp_test_HhsOEvvf2Mk23e", // ✅ TEST KEY
            andDelegateWithData: self
        )
    }

    // MARK: - Find Top ViewController
    private func topViewController(
        base: UIViewController? = UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    ) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }

    // MARK: - Start Razorpay
    func startPayment(amountInRupees: Int) {

        let options: [String: Any] = [
            "amount": amountInRupees * 100, // paise
            "currency": "INR",
            "name": "Smart Salon",
            "description": "Salon Service Payment",
            "prefill": [
                "contact": "9876543210",
                "email": "test@gmail.com"
            ],
            "theme": [
                "color": "#000000"
            ]
        ]

        if let vc = topViewController() {
            razorpay?.open(options, displayController: vc)
        }
    }

    // MARK: - Razorpay Callbacks
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        onPaymentSuccess?(payment_id)
    }

    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        onPaymentError?(str)
    }
}

// MARK: - Payment Options View
struct PaymentOptionsView: View {

    // ✅ Data from previous screen
    let appointment: AppointmentDraft

    @State private var selectedOption: String? = nil
    @State private var goToAppointments = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    @State private var razorpayCoordinator = RazorpayCoordinator()
    @AppStorage("userEmail") var userEmail = ""
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 1.0, green: 0.55, blue: 0.75)
                    .ignoresSafeArea()

                VStack(spacing: 30) {

                    Text("Payment Options")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 40)

                    VStack(spacing: 20) {
                        paymentRow(
                            title: "UPI",
                            icon: "arrow.up.right.circle.fill",
                            option: "UPI"
                        )

                        paymentRow(
                            title: "Debit / Credit Card",
                            icon: "creditcard.fill",
                            option: "Debit / Credit Card"
                        )

                        paymentRow(
                            title: "Cash on Delivery",
                            icon: "banknote.fill",
                            option: "Cash on Delivery"
                        )
                    }
                    .padding(.horizontal, 25)

                    Spacer()

                    // ✅ Redirect after payment success
                    NavigationLink(
                        "",
                        destination: BookingSuccessPage(),
                        isActive: $goToAppointments
                    )

                    Button(action: handlePayment) {
                        Text("Pay ₹\(appointment.amount)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.green)
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 25)
                }
            }
            .alert("Payment Status", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    // MARK: - Payment Logic
    private func handlePayment() {

        guard let option = selectedOption else {
            alertMessage = "Please select a payment method"
            showAlert = true
            return
        }

        // ✅ CASH ON DELIVERY
        if option == "Cash on Delivery" {
            postAppointmentToDB(paymentOption: option)
            goToAppointments = true
            return
        }

        // ✅ RAZORPAY
        razorpayCoordinator.onPaymentSuccess = { paymentId in
            print("✅ Payment Success:", paymentId)
            postAppointmentToDB(paymentOption: option)

            DispatchQueue.main.async {
                goToAppointments = true
            }
        }

        razorpayCoordinator.onPaymentError = { error in
            alertMessage = "Payment Failed: \(error)"
            showAlert = true
        }

        razorpayCoordinator.startPayment(amountInRupees: appointment.amount)
    }

    // MARK: - POST Appointment to Backend
    private func postAppointmentToDB(paymentOption: String) {
        let encodedEmail = userEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "https://fbw79vn4-80.inc1.devtunnels.ms/smartsalon_api/post_appointments.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "user_email": encodedEmail,
            "service": appointment.service,
            "appointment_date": appointment.appointmentDate,
            "appointment_time": appointment.appointmentTime,
            "hairstyle_image": appointment.hairstyleImage ?? "",
            "address": appointment.address,
            "payment_option": paymentOption
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ API Error:", error)
                return
            }
            if let data = data,
               let response = try? JSONSerialization.jsonObject(with: data) {
                print("✅ DB Response:", response)
            }
        }.resume()
    }

    // MARK: - Payment Option Row
    private func paymentRow(title: String, icon: String, option: String) -> some View {
        Button {
            selectedOption = option
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)

                Spacer()

                Image(systemName: selectedOption == option
                      ? "largecircle.fill.circle"
                      : "circle")
                    .foregroundColor(.green)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.25))
            )
        }
    }
}

// MARK: - Appointment Draft Model
struct AppointmentDraft {
    let userEmail: String
    let service: String
    let appointmentDate: String   // yyyy-MM-dd
    let appointmentTime: String   // HH:mm:ss
    let hairstyleImage: String?
    let address: String
    let amount: Int
}
