import MediaPipeTasksVision
import AVFoundation
import Combine
import UIKit

@MainActor
final class FaceLandmarkManager: ObservableObject {

    static let shared = FaceLandmarkManager()

    // MARK: - UI States
    @Published var detectedShape: String? = nil
    @Published var faceDetected: Bool = false

    // MARK: - MediaPipe
    private var landmarker: FaceLandmarker?

    // MARK: - Stability Logic
    private var shapeCounter: [String: Int] = [:]
    private let requiredMatches = 3      // ✅ good for demo/review
    private var locked = false

    private init() {
        setup()
    }

    // MARK: - Setup MediaPipe
    private func setup() {

        guard let modelPath = Bundle.main.path(
            forResource: "face_landmarker",
            ofType: "task"
        ) else {
            fatalError("❌ face_landmarker.task not found")
        }

        let options = FaceLandmarkerOptions()
        options.baseOptions.modelAssetPath = modelPath
        options.runningMode = .image      // ✅ correct for sync
        options.numFaces = 1

        landmarker = try? FaceLandmarker(options: options)
    }

    // MARK: - Reset (Call on page appear / new input)
    func resetDetection() {
        detectedShape = nil
        faceDetected = false
        shapeCounter.removeAll()
        locked = false
    }

    // MARK: - CAMERA FRAME DETECTION
    func detect(sampleBuffer: CMSampleBuffer) {

        guard !locked else { return }

        guard let mpImage = try? MPImage(sampleBuffer: sampleBuffer) else {
            faceDetected = false
            return
        }

        guard let result = try? landmarker?.detect(image: mpImage),
              let landmarks = result.faceLandmarks.first
        else {
            faceDetected = false
            return
        }

        faceDetected = true

        let shape = FaceShapeAnalyzer.detect(from: landmarks)
        updateDetectedShape(shape)
    }

    // MARK: - IMAGE (UPLOAD) DETECTION
    func detect(image: UIImage) {

        guard !locked else { return }

        // ✅ Force safe CGImage conversion
        guard let cgImage = image.cgImage else {
            print("❌ Image has no CGImage")
            faceDetected = false
            return
        }

        let safeImage = UIImage(
            cgImage: cgImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )

        guard let mpImage = try? MPImage(uiImage: safeImage) else {
            print("❌ MPImage creation failed")
            faceDetected = false
            return
        }

        guard let result = try? landmarker?.detect(image: mpImage),
              let landmarks = result.faceLandmarks.first
        else {
            faceDetected = false
            return
        }

        faceDetected = true
        let shape = FaceShapeAnalyzer.detect(from: landmarks)
        updateDetectedShape(shape)
    }

    // MARK: - STABLE FACE SHAPE CONFIRMATION
    private func updateDetectedShape(_ shape: String) {

        shapeCounter[shape, default: 0] += 1

        // 🔒 Reset other shapes to avoid false lock
        for key in shapeCounter.keys where key != shape {
            shapeCounter[key] = 0
        }

        if shapeCounter[shape]! >= requiredMatches {
            detectedShape = shape
            locked = true
            print("✅ Face Shape Locked:", shape)
        }
    }
}
