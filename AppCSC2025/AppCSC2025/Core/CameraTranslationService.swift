//
//  CameraTranslationService.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//  Optimizado: soporte cámara + fotos + límite de frames + feedback háptico.
//

import Foundation
import AVFoundation
import Vision
import UIKit

@MainActor
final class CameraTranslationService: NSObject, ObservableObject {
    // MARK: - Public properties
    @Published var overlayText: String = ""
    @Published var avgConfidence: Float = 0.0
    @Published var targetLanguage: RecognizedLanguage = .en
    @Published var isRunning = false

    // MARK: - OCR settings
    var ocrConfidenceThreshold: Float = 0.5

    // MARK: - Camera session
    let previewSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var lastProcessTime = Date()

    // MARK: - Internal helpers
    private let processor = OCRProcessor()
    private var videoConnection: AVCaptureConnection?

    // MARK: - Setup
    func prepare() async {
        sessionQueue.async {
            self.configureCamera()
        }
    }

    private func configureCamera() {
        previewSession.beginConfiguration()
        previewSession.sessionPreset = .high

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device)
        else {
            print("❌ Unable to access camera.")
            return
        }

        if previewSession.canAddInput(input) {
            previewSession.addInput(input)
        }

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoOutputQueue"))
        videoOutput.alwaysDiscardsLateVideoFrames = true

        if previewSession.canAddOutput(videoOutput) {
            previewSession.addOutput(videoOutput)
        }

        videoConnection = videoOutput.connection(with: .video)
        previewSession.commitConfiguration()
    }

    // MARK: - Control
    func start() {
        if !previewSession.isRunning {
            previewSession.startRunning()
            isRunning = true
        }
    }

    func stop() {
        if previewSession.isRunning {
            previewSession.stopRunning()
            isRunning = false
        }
    }

    // MARK: - Process static images
    func processImage(_ image: UIImage) async {
        guard let cgImage = image.cgImage else { return }

        let (translated, confidence) = await processor.scanAndTranslateText(
            pixelBuffer: nil,
            target: targetLanguage,
            fromStaticImage: cgImage
        )

        self.overlayText = translated
        self.avgConfidence = confidence
    }
}

// MARK: - Video Output Delegate
extension CameraTranslationService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard isRunning else { return }

        // ⚙️ Limita frecuencia de OCR
        guard Date().timeIntervalSince(lastProcessTime) > 0.5 else { return }
        lastProcessTime = Date()

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        Task {
            let (translated, confidence) = await processor.scanAndTranslateText(
                pixelBuffer: pixelBuffer,
                target: targetLanguage,
                fromStaticImage: nil
            )

            if translated != self.overlayText {
                self.overlayText = translated
                // 💥 Feedback háptico al cambiar texto
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            self.avgConfidence = confidence
        }
    }
}
