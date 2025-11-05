//
//  CameraView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//  Versión Deluxe: UI tipo Apple Translate con blur, idioma detectado y transiciones suaves.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct CameraView: View {
    @StateObject private var vm = CameraTranslationService()
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ZStack {
            // Fondo: cámara o imagen cargada
            SwiftUI.Group {
                if let image = selectedImage {
                    SwiftUI.Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .ignoresSafeArea()
                } else {
                    CameraPreview(sessionOwner: vm)
                        .ignoresSafeArea()
                }
            }

            // Overlay principal
            VStack {
                // 🔤 Selector de idioma + botón de galería
                HStack {
                    Picker("Destination", selection: $vm.targetLanguage) {
                        ForEach(RecognizedLanguage.allCases, id: \.self) {
                            Text($0.flaggedLabel).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(radius: 3)

                    Spacer()

                    // 📷 Botón galería
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(radius: 3)
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 20)

                Spacer()

                // 🔎 Idioma detectado + traducción
                if !vm.overlayText.isEmpty {
                    VStack(spacing: 10) {
                        if let detectedLang = vm.detectedLanguageLabel {
                            Text("Detected: \(detectedLang.flaggedLabel)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(6)
                                .background(.ultraThinMaterial, in: Capsule())
                                .shadow(radius: 2)
                        }

                        Text(vm.overlayText)
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(
                                VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            )
                            .shadow(radius: 10)
                            .padding(.horizontal, 28)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.3), value: vm.overlayText)
                    }
                    .padding(.bottom, 90)
                }

                // 🔘 Botón principal
                Button {
                    if selectedImage != nil {
                        selectedImage = nil
                        vm.overlayText = ""
                    } else {
                        vm.isRunning ? vm.stop() : vm.start()
                    }
                } label: {
                    Label(
                        selectedImage != nil ? "Close Image" :
                        (vm.isRunning ? "Stop" : "Live Translate"),
                        systemImage: selectedImage != nil ? "xmark.circle.fill" :
                            (vm.isRunning ? "stop.circle.fill" : "text.viewfinder")
                    )
                    .font(.headline)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(selectedImage != nil ? .orange : (vm.isRunning ? .red : .blue))
                .shadow(radius: 6)
                .padding(.bottom, 30)
            }
        }
        // Cuando se selecciona una imagen
        .onChange(of: selectedPhoto) { newItem in
            Task {
                guard let item = newItem else { return }
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    await vm.processImage(uiImage)
                }
            }
        }
        .task { await vm.prepare() }
    }
}

// Efecto de blur nativo
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
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
