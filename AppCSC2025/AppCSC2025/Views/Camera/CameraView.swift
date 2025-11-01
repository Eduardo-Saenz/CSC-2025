//
//  CameraView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//  Actualizado: cámara + carga de fotos + feedback háptico + UI Apple.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct CameraView: View {
    @StateObject private var vm = CameraTranslationService()
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            // Vista principal: cámara o imagen seleccionada
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                        .scaledToFit() // ✅ Muestra toda la imagen completa sin recortarla
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                        .ignoresSafeArea()
            } else {
                CameraPreview(sessionOwner: vm)
                    .ignoresSafeArea()
            }

            VStack(spacing: 16) {
                // Idioma destino + botón de galería
                HStack {
                    Picker("Destination", selection: $vm.targetLanguage) {
                        ForEach(RecognizedLanguage.allCases, id: \.self) {
                            Text($0.flaggedLabel).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                    .padding(.horizontal)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(radius: 3)

                    Spacer()

                    // Botón para elegir foto
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                            .shadow(radius: 3)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal)

                // Texto traducido
                if !vm.overlayText.isEmpty {
                    Text(vm.overlayText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
                        .shadow(radius: 12)
                        .transition(.opacity.combined(with: .scale))
                        .animation(.easeInOut, value: vm.overlayText)
                        .padding(.horizontal, 16)
                }

                // Botón principal
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
                .padding(.bottom, 22)
            }
        }
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
