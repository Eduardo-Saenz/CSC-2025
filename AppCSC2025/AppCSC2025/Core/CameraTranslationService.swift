//
//  CameraTranslationService.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//  Gestiona la cámara, reconocimiento de texto y traducción on-device.
//

import AVFoundation
import Vision
import NaturalLanguage
import SwiftUI

@MainActor
final class CameraTranslationService: NSObject, ObservableObject {

    // MARK: - Estados observables
    @Published var overlayText: String = ""
    @Published var isRunning: Bool = false
    @Published var targetLanguage: RecognizedLanguage = .en
    @Published var detectedLanguageLabel: RecognizedLanguage? = nil

    // MARK: - Sesión de cámara
    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "camera.translation.queue")

    var previewSession: AVCaptureSession { session }

    // MARK: - Inicialización
    func prepare() async {
        guard !session.isRunning else { return }

        session.beginConfiguration()
        session.sessionPreset = .high

        // Cámara trasera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera)
        else {
            print("⚠️ No se pudo acceder a la cámara.")
            return
        }

        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setSampleBufferDelegate(self, queue: queue)
        }

        session.commitConfiguration()
    }

    // MARK: - Control de flujo
    func start() {
        guard !session.isRunning else { return }
        isRunning = true
        queue.async { self.session.startRunning() }
    }

    func stop() {
        guard session.isRunning else { return }
        isRunning = false
        queue.async { self.session.stopRunning() }
    }

    // MARK: - Procesamiento de imagen (desde galería)
    func processImage(_ image: UIImage) async {
        guard let cgImage = image.cgImage else { return }
        await recognizeText(in: cgImage)
    }

    // MARK: - OCR + Traducción
    private func recognizeText(in image: CGImage) async {
        let request = VNRecognizeTextRequest { [weak self] req, _ in
            guard let self = self else { return }

            let observations = req.results as? [VNRecognizedTextObservation] ?? []
            let fullText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")

            Task { @MainActor in
                self.overlayText = fullText
                self.detectedLanguageLabel = self.detectLanguage(for: fullText)
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
    }

    private func detectLanguage(for text: String) -> RecognizedLanguage? {
        guard !text.isEmpty else { return nil }
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)

        guard let lang = recognizer.dominantLanguage?.rawValue.prefix(2) else { return nil }
        return RecognizedLanguage(rawValue: String(lang))
    }
}

// MARK: - Extensión: Captura de frames
extension CameraTranslationService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard isRunning,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        Task { await recognizeText(in: cgImage) }
    }
}
