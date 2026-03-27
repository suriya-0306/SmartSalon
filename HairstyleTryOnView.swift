import SwiftUI
import UIKit

struct HairstyleTryOnView: View {

    // ✅ DATA FROM PREVIOUS PAGE
    let selectedStyle: Hairstyle?

    // ✅ BACK NAVIGATION
    @Environment(\.dismiss) private var dismiss

    // ✅ NAVIGATION STATE
    @State private var goToMySalon = false

    var body: some View {
        NavigationStack {   // ✅ ADDED
            GeometryReader { geo in
                ZStack {

                    // BACKGROUND
                    Color.black.ignoresSafeArea()

                    VStack(spacing: 16) {

                        // TITLE
                        Text("Hairstyle Preview")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, 10)

                        // ✅ PREVIEW AREA
                        ZStack {
                            if let style = selectedStyle {
                                Image(style.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(
                                        width: geo.size.width * 0.85,
                                        height: geo.size.height * 0.6
                                    )
                                    .shadow(color: .black.opacity(0.4), radius: 8)
                            }
                        }

                        // STYLE NAME
                        if let style = selectedStyle {
                            Text(style.name)
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding(.top, 8)
                        }

                        Spacer()

                        // ACTION BUTTONS
                        HStack(spacing: 16) {

                            Button("Change Style") {
                                dismiss()
                            }
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(16)

                            Button("Book Salon") {
                                goToMySalon = true   // ✅ TRIGGER NAVIGATION
                            }
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding()
                }
            }
            // ✅ DESTINATION
            .navigationDestination(isPresented: $goToMySalon) {
                MySalonView()
            }
        }
    }
}
