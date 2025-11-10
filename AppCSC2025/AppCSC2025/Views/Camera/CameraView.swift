//
//  CameraView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//  Versión Mundial 2026: UI oscura tipo Apple Translate con efecto tricolor.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct CameraView: View {
    @StateObject private var vm = CameraTranslationService()
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil

    // Colores oficiales
    private let fifaGreen = Color(hexString: "006847") // 🇲🇽
    private let fifaRed   = Color(hexString: "CE1125") // 🇨🇦

    var body: some View {
        ZStack {
            // Fondo negro + halo tricolor
            Color.black.ignoresSafeArea()
                .overlay(
                    ZStack {
                        Circle().fill(fifaRed.opacity(0.08))
                            .frame(width: 400, height: 400)
                            .blur(radius: 120)
                            .offset(x: 140, y: 260)


                        Circle().fill(fifaGreen.opacity(0.1))
                            .frame(width: 450, height: 450)
                            .blur(radius: 140)
                            .offset(x: 80, y: -100)
                    }
                )

            // Contenido principal: cámara o imagen cargada
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
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

            VStack {
                // MARK: Barra superior — selección de idioma + galería
                HStack {
                    Picker("Destino", selection: $vm.targetLanguage) {
                        ForEach(RecognizedLanguage.allCases, id: \.self) {
                            Text($0.flaggedLabel).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.4), in: Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    .shadow(color: .black.opacity(0.5), radius: 3, y: 2)

                    Spacer()

                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4), in: Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            .shadow(color: .black.opacity(0.6), radius: 3, y: 2)
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 20)

                Spacer()

                // MARK: Texto detectado + overlay traducido
                if !vm.overlayText.isEmpty {
                    VStack(spacing: 10) {
                        if let detectedLang = vm.detectedLanguageLabel {
                            Text("Detectado: \(detectedLang.flaggedLabel)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.5), in: Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 0.8))
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
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.black.opacity(0.55))
                                    .overlay(
                                        LinearGradient(
                                            colors: [fifaGreen.opacity(0.15), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                    )
                                    .shadow(color: .white.opacity(0.05), radius: 8, y: 2)
                            )
                            .shadow(color: .black.opacity(0.8), radius: 10, y: 5)
                            .padding(.horizontal, 28)
                            .transition(.opacity.combined(with: .scale))
                            .animation(.easeInOut(duration: 0.3), value: vm.overlayText)
                    }
                    .padding(.bottom, 100)
                }

                // MARK: Botón inferior (Traducir / Cerrar / Detener)
                Button {
                    if selectedImage != nil {
                        selectedImage = nil
                        vm.overlayText = ""
                    } else {
                        vm.isRunning ? vm.stop() : vm.start()
                    }
                } label: {
                    Label(
                        selectedImage != nil ? "Cerrar Imagen" :
                        (vm.isRunning ? "Detener" : "Traducir en Vivo"),
                        systemImage: selectedImage != nil ? "xmark.circle.fill" :
                            (vm.isRunning ? "stop.circle.fill" : "text.viewfinder")
                    )
                    .font(.headline)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(colors: [fifaGreen, fifaRed],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                    )
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 6, y: 4)
                }
                .padding(.bottom, 36)
            }
        }
        // MARK: Cargar imagen desde galería
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
