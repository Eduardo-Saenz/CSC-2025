//
//  CameraView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var vm = CameraTranslationService()

    var body: some View {
        ZStack(alignment: .bottom) {
            CameraPreview(sessionOwner: vm)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // Idioma destino + slider confianza
                HStack {
                    Picker("Destino", selection: $vm.targetLanguage) {
                        ForEach(RecognizedLanguage.allCases, id: \.self) {
                            Text($0.flaggedLabel).tag($0)
                        }
                    }
                    .pickerStyle(.menu)

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(format: "Confianza: %.0f%%", vm.avgConfidence * 100))
                            .font(.caption)
                            .monospacedDigit()
                        Slider(value: Binding(
                            get: { Double(vm.ocrConfidenceThreshold) },
                            set: { vm.ocrConfidenceThreshold = Float($0) }
                        ), in: 0.3...0.9)
                    }
                    .frame(width: 180)
                }
                .padding(.horizontal)

                Text(vm.overlayText)
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)

                Button {
                    vm.isRunning ? vm.stop() : vm.start()
                } label: {
                    Label(vm.isRunning ? "Detener" : "OCR en vivo",
                          systemImage: vm.isRunning ? "stop.fill" : "text.viewfinder")
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 18)
            }
        }
        .task { await vm.prepare() }
    }
}

#if os(iOS)
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var sessionOwner: CameraTranslationService

    func makeUIView(context: Context) -> UIView {
        let v = PreviewView()
        v.videoPreviewLayer.session = sessionOwner.previewSession
        v.videoPreviewLayer.videoGravity = .resizeAspectFill
        return v
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}
#endif
