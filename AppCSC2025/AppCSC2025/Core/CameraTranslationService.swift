//
//  CameraTranslationService.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//

import Foundation
import AVFoundation
import Vision
import Combine

@MainActor
final class CameraTranslationService: NSObject, ObservableObject {
    @Published var overlayText: String = "Apunta a un texto…"
    @Published var isRunning: Bool = false
    @Published var targetLanguage: RecognizedLanguage = .en
    @Published var avgConfidence: Float = 0.0
    @Published var ocrConfidenceThreshold: Float = 0.5

    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "camera.translation.queue")
    private let processor = OCRProcessor()
    private var isProcessingFrame = false

    var previewSession: AVCaptureSession { session }

    func prepare() async {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        guard granted else {
            print("⚠️ Permiso de cámara no concedido")
            return
        }

        do { try await Permissions.requestAll() }
        catch { print("⚠️ Permisos no concedidos: \(error)") }

        setupCamera()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        session.startRunning()
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        session.stopRunning()
    }

    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("⚠️ No se encontró cámara")
            session.commitConfiguration()
            return
        }

        if session.canAddInput(input) { session.addInput(input) }

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) { session.addOutput(output) }

        session.commitConfiguration()
    }
}

extension CameraTranslationService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isRunning,
              !isProcessingFrame,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        isProcessingFrame = true
        processor.confidenceThreshold = ocrConfidenceThreshold

        Task {
            let (translated, confidence) = await processor.scanAndTranslateText(
                pixelBuffer: pixelBuffer,
                target: targetLanguage,
                forceSource: nil
            )

            await MainActor.run {
                self.avgConfidence = confidence
                self.overlayText = translated.isEmpty ? "…" : translated
            }
            isProcessingFrame = false
        }
    }
}
