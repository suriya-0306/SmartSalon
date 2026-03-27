import SwiftUI
import UIKit

enum FaceInputOption {
    case none
    case camera
}

struct FaceShapeResultPage: View {

    @StateObject private var faceManager = FaceLandmarkManager.shared
    @StateObject private var cameraManager = CameraManager()

    @State private var inputOption: FaceInputOption = .none
    @State private var goToStyles = false
    @State private var finalShape: String = ""
    @State private var capturedFaceImage: UIImage? = nil

    var body: some View {

        ZStack {

            // CAMERA PREVIEW
            if inputOption == .camera {
                CameraPreview(session: cameraManager.session)
                    .ignoresSafeArea()
            }

            // UI OVERLAY
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.76, blue: 0.88),
                    Color(red: 0.98, green: 0.60, blue: 0.78),
                    Color(red: 0.95, green: 0.42, blue: 0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.85)
            .ignoresSafeArea()

            VStack(spacing: 25) {

                Text("Face Shape Analysis")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                // BEFORE SCAN
                if inputOption == .none {

                    Image(systemName: "face.smiling")
                        .font(.system(size: 70))
                        .padding(.bottom, 20)

                    Button("Scan Face") {
                        faceManager.resetDetection()
                        capturedFaceImage = nil
                        inputOption = .camera
                        cameraManager.start()
                    }
                    .buttonStyle(.borderedProminent)

                } else {

                    // SCANNING UI
                    ZStack {
                        Circle()
                            .stroke(Color.black, lineWidth: 3)
                            .frame(width: 220, height: 220)

                        Image(systemName: faceManager.faceDetected ? "checkmark" : "hourglass")
                            .font(.system(size: 50))
                    }

                    VStack(spacing: 6) {
                        Text(faceManager.faceDetected ? "Scanning Completed" : "Scanning Face...")
                            .font(.headline)

                        if let shape = faceManager.detectedShape {
                            Text("Detected Shape: \(shape)")
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(.purple)
                        }
                    }

                    Spacer()

                    // CHECK STYLES BUTTON
                    if faceManager.detectedShape != nil,
                       capturedFaceImage != nil {

                        Button("Check Styles") {
                            finalShape = faceManager.detectedShape!
                            goToStyles = true
                        }
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(30)
                        .padding(.horizontal, 40)
                    }
                }

                Spacer()
            }

            // 🔹 HIDDEN NAVIGATION (SIMPLE & SAFE)
            if let faceImage = capturedFaceImage {
                NavigationLink(
                    destination: HairstylesPageView(
                        faceShape: finalShape,
                        userFaceImage: faceImage
                        
                    ),
                    isActive: $goToStyles
                ) {
                    EmptyView()
                }
            }
        }

        // CAMERA FRAME CALLBACK
        .onAppear {
            cameraManager.onFrameCaptured = { sampleBuffer in
                guard inputOption == .camera else { return }

                FaceLandmarkManager.shared.detect(sampleBuffer: sampleBuffer)

                if faceManager.faceDetected,
                   capturedFaceImage == nil,
                   let image = UIImage.from(sampleBuffer: sampleBuffer) {
                    capturedFaceImage = image
                }
            }
        }

        .onDisappear {
            cameraManager.stop()
        }
    }
}
import UIKit
import AVFoundation
import CoreImage

extension UIImage {

    static func from(sampleBuffer: CMSampleBuffer) -> UIImage? {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()

        guard let cgImage = context.createCGImage(
            ciImage,
            from: ciImage.extent
        ) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
