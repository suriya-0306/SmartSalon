//
//  CameraManager.swift
//  Smart Salon
//
//  Created by SAIL on 23/12/25.
//


import AVFoundation
import UIKit

final class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {


    let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "camera.queue")

    /// Called on every camera frame
    var onFrameCaptured: ((CMSampleBuffer) -> Void)?

    override init() {
        super.init()
        checkPermission()
    }

    // MARK: - Permission
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configure()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.configure()
                    }
                }
            }
        default:
            print("❌ Camera permission denied")
        }
    }

    // MARK: - Camera Setup
    private func configure() {

        session.beginConfiguration()
        session.sessionPreset = .high

        // FRONT CAMERA
        guard let camera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            print("❌ Front camera not found")
            return
        }

        guard let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input)
        else {
            print("❌ Cannot add camera input")
            return
        }

        session.addInput(input)

        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String:
            kCVPixelFormatType_32BGRA
        ]

        output.setSampleBufferDelegate(self, queue: queue)

        guard session.canAddOutput(output) else {
            print("❌ Cannot add output")
            return
        }

        session.addOutput(output)

        session.commitConfiguration()
    }

    // MARK: - Start / Stop
    func start() {
        if !session.isRunning {
            session.startRunning()
        }
    }

    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    // MARK: - Frame Delegate
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        onFrameCaptured?(sampleBuffer)
    }
}
