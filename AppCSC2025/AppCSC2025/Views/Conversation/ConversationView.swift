//
//  ConversationView.swift
//  AppCSC2025
//
//  Created by Samuel Martinez on 10/31/25.
//

import SwiftUI
import AVFoundation

struct ConversationView: View {
    @State private var messages: [ChatMessage] = []
    @State private var isRecording = false
    @State private var currentTranscription = ""
    @State private var sourceLanguage: RecognizedLanguage = .es
    @State private var targetLanguage: RecognizedLanguage = .en
    @EnvironmentObject var settings: AppSettings

    private let recognizer = SpeechRecognizerService()
    private let translator = TranslationService()
    private let tts = TTSService()

    @State private var hasWelcomed = false
    @State private var micPulse = false

    // Colores oficiales
    private let fifaGreen = Color(hexString: "006847") // México
    private let fifaRed   = Color(hexString: "CE1125") // Canadá
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94) // USA

    var body: some View {
        ZStack {
            // Fondo tricolor dinámico
            LinearGradient(
                gradient: Gradient(colors: [
                    fifaGreen.opacity(0.25),
                    Color.white,
                    fifaBlue.opacity(0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                ZStack {
                    Circle().fill(fifaRed.opacity(0.1))
                        .frame(width: 420, height: 420)
                        .blur(radius: 120)
                        .offset(x: -150, y: -200)

                    Circle().fill(fifaBlue.opacity(0.1))
                        .frame(width: 420, height: 420)
                        .blur(radius: 130)
                        .offset(x: 160, y: 260)

                    Circle().fill(fifaGreen.opacity(0.08))
                        .frame(width: 300, height: 300)
                        .blur(radius: 100)
                        .offset(x: 100, y: -320)
                }
            )

            VStack(spacing: 0) {
                header
                Divider().opacity(0.3)

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            ForEach(messages) { msg in
                                ChatBubble(message: msg, tts: tts)
                                    .id(msg.id)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 130)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let last = messages.last {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                if isRecording {
                    RecordingIndicator(transcription: currentTranscription)
                        .padding(.bottom, 8)
                        .transition(.opacity)
                }

                Spacer(minLength: 60)
            }

            VStack {
                Spacer()
                bottomBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !hasWelcomed {
                addWelcomeMessage()
                hasWelcomed = true
            }
        }
    }

    // MARK: Header Mundial 2026
    private var header: some View {
        VStack(spacing: 5) {
            HStack(spacing: 8) {
                Text("Multivoice AI")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(fifaGreen)
                    .shadow(color: fifaGreen.opacity(0.25), radius: 2, y: 1)
            }
            Text("Traduce de \(sourceLanguage.label) → \(targetLanguage.label)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(Divider(), alignment: .bottom)
    }

    // MARK: Bottom Bar — rediseñada estilo Mundial 2026
    private var bottomBar: some View {
        HStack(spacing: 18) {
            LanguagePicker(selectedLanguage: $sourceLanguage)

            Image(systemName: "arrow.right")
                .font(.title3)
                .foregroundColor(.secondary)

            LanguagePicker(selectedLanguage: $targetLanguage)

            Spacer()

            // Micrófono con halo dinámico
            RecordButton(isRecording: $isRecording) {
                handleRecording()
            }

            Button(action: clearMessages) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(fifaRed)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: fifaRed.opacity(0.3), radius: 3, y: 2)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 26)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [fifaGreen.opacity(0.15), .white.opacity(0.1), fifaBlue.opacity(0.15)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
        .padding(.horizontal, 8)
    }

    // MARK: Recording Logic
    private func handleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        Task {
            do {
                try await SpeechRecognizerService.ensurePermissions()
                isRecording = true
                currentTranscription = "Escuchando..."
                try recognizer.start(locale: Locale(identifier: sourceLanguage.localeIdentifier))
            } catch {
                print("❌ Speech error: \(error.localizedDescription)")
                isRecording = false
            }
        }
    }

    private func stopRecording() {
        recognizer.stop()
        isRecording = false
        currentTranscription = ""
    }

    private func addWelcomeMessage() {
        messages.append(ChatMessage(
            originalText: "¡Bienvenido a Multivoice AI 🇲🇽🇺🇸🇨🇦!",
            translatedText: "Welcome to Multivoice AI 🇲🇽🇺🇸🇨🇦!",
            sourceLanguage: .es,
            targetLanguage: .en
        ))
    }

    private func clearMessages() {
        withAnimation(.spring()) {
            messages.removeAll()
            addWelcomeMessage()
        }
    }
}

// MARK: Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage
    let tts: TTSService
    private let fifaGreen = Color(hexString: "006847")
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Tú \(message.sourceLanguage.flag)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(message.originalText)
                        .font(.body)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(colors: [fifaBlue.opacity(0.2), .white.opacity(0.1)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: fifaBlue.opacity(0.2), radius: 4, y: 2)
                        )
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Traducción \(message.targetLanguage.flag)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Button {
                            tts.speak(message.translatedText, language: message.targetLanguage)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(fifaGreen)
                                .font(.caption)
                        }
                    }
                    Text(message.translatedText)
                        .font(.body)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(colors: [fifaGreen.opacity(0.18), .white.opacity(0.1)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: fifaGreen.opacity(0.15), radius: 3, y: 2)
                        )
                }
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

// MARK: Record Button — rediseñado con efecto neón tricolor
struct RecordButton: View {
    @Binding var isRecording: Bool
    let action: () -> Void

    private let fifaGreen = Color(hexString: "006847")
    private let fifaRed   = Color(hexString: "CE1125")
    private let fifaBlue  = Color(red: 0.08, green: 0.47, blue: 0.94)

    @State private var glow = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(colors: [fifaGreen, fifaBlue, fifaRed]),
                            center: .center
                        ),
                        lineWidth: isRecording ? 6 : 3
                    )
                    .frame(width: 82, height: 82)
                    .scaleEffect(glow ? 1.15 : 1.0)
                    .opacity(glow ? 0.7 : 0.3)
                    .blur(radius: glow ? 8 : 0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glow)

                Circle()
                    .fill(
                        RadialGradient(colors: [
                            isRecording ? fifaRed : fifaBlue,
                            Color.black.opacity(0.5)
                        ], center: .center, startRadius: 5, endRadius: 45)
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: fifaRed.opacity(0.3), radius: 6, y: 3)

                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            }
        }
        .onAppear { glow = true }
        .scaleEffect(isRecording ? 1.1 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isRecording)
    }
}

// MARK: Recording Indicator
struct RecordingIndicator: View {
    let transcription: String
    @State private var animationAmount = 1.0

    var body: some View {
        HStack {
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .scaleEffect(animationAmount)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                        animationAmount = 1.6
                    }
                }
            Text(transcription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(Color.red.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// MARK: Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let originalText: String
    let translatedText: String
    let sourceLanguage: RecognizedLanguage
    let targetLanguage: RecognizedLanguage
    let timestamp = Date()
}

// MARK: Language Picker
struct LanguagePicker: View {
    @Binding var selectedLanguage: RecognizedLanguage

    var body: some View {
        Menu {
            ForEach(RecognizedLanguage.allCases, id: \.self) { lang in
                Button {
                    selectedLanguage = lang
                } label: {
                    HStack {
                        Text(lang.flag)
                        Text(lang.label)
                        if selectedLanguage == lang {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selectedLanguage.flag)
                    .font(.title2)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        }
    }
}

// MARK: Color Extension
extension Color {
    init(hexString: String, alpha: Double = 1.0) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(.sRGB,
                  red: Double(r)/255,
                  green: Double(g)/255,
                  blue: Double(b)/255,
                  opacity: alpha)
    }
}

#Preview {
    NavigationStack {
        ConversationView()
            .environmentObject(AppSettings())
    }
}
