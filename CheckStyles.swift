import SwiftUI
import Foundation
import UIKit

// MARK: - MODEL
struct Hairstyle: Identifiable {
    let id = UUID()
    let name: String
    let image: String
}

// MARK: - FACE SHAPE → HAIRSTYLE MAP
struct FaceShapeStyles {

    static let styles: [String: [String]] = [

        "Diamond": [
            "fringe", "fringe2", "fringe3",
            "Taper-Fade", "Taper-Fade2", "Taper-Fade3",
            "textured crop", "textured crop2", "textured crop3"
        ],

        "Heart": [
            "heartfringe", "heartfringe2", "heartfringe3",
            "MediumLength", "MediumLength2", "MediumLength3",
            "Side Swept", "Side Swept2", "Side Swept3"
        ],

        "Oval": [
            "bhuzz cut", "bhuzz cut2", "bhuzz cut3",
            "Pompadour", "Pompadour2", "Pompadour3",
            "Quiff-Cut", "Quiff-Cut2", "Quiff-Cut3",
            "side part", "side part2", "side part3"
        ],

        "Round": [
            "Faux-hawk_Fade2", "Faux-Hawk-Fade3",
            "High Fade", "High Fade2", "High Fade3",
            "Undercut-Fade", "Undercut-Fade2", "Undercut-Fade3"
        ],

        "Square": [
            "Crew-Cut-Quiff", "Crew-Cut-Quiff2", "Crew-Cut-Quiff3",
            "squarebhuzzcut", "squarebhuzzcut2", "squarebhuzzcut3",
            "squaretexturedcrop", "squaretexturedcrop2", "squaretexturedcrop3"
        ]
    ]
}

// MARK: - MAIN VIEW (PAGE 2)
struct HairstylesPageView: View {

    let faceShape: String
    let userFaceImage: UIImage

    @State private var selectedStyle: Hairstyle? = nil
    @State private var goToTryOn = false

    var hairstyles: [Hairstyle] {
        let images = FaceShapeStyles.styles[faceShape] ?? []
        return images.map {
            Hairstyle(name: $0.capitalized, image: $0)
        }
    }

    var body: some View {

        VStack(spacing: 18) {

            Text("AI Suggestions for \(faceShape) Face")
                .font(.title2)
                .bold()

            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 24
                ) {
                    ForEach(hairstyles) { style in
                        Button {
                            selectedStyle = style
                            goToTryOn = true
                        } label: {
                            VStack(spacing: 12) {
                                Image(style.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())

                                Text(style.name)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(22)
                        }
                    }
                }
            }

            NavigationLink(
                destination: HairstyleTryOnView(
                    selectedStyle: selectedStyle
                ),
                isActive: $goToTryOn
            ) {
                EmptyView()
            }
        }
    }
}
