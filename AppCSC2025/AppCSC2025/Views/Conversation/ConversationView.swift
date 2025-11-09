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
    @State private var sourceLanguage: RecognizedLanguage = .es // 👈 Usuario habla en español
    @State private var targetLanguage: RecognizedLanguage = .en // 👈 Traduce al inglés
    @EnvironmentObject var settings: AppSettings

    private let recognizer = SpeechRecognizerService()
    private let translator = TranslationService()
    private let tts = TTSService()
    @State private var lastSpokenText: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header dinámico
            Text("Traduce de \(sourceLanguage.label) → \(targetLanguage.label)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
                .transition(.opacity)

            Divider()

            // Chat scrollable
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(messages) { message in
                            ChatBubble(message: message, tts: tts)
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            if isRecording {
                RecordingIndicator(transcription: currentTranscription)
                    .transition(.opacity)
                    .padding(.vertical, 8)
            }

            controlBar
        }
        .navigationTitle("Modo intérprete")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                TopBarSettingsButton()
            }
        }
        .task {
            addWelcomeMessage()
        }
        .onChange(of: sourceLanguage) { _, _ in
            Task { await retranslateAll() }
        }
        .onChange(of: targetLanguage) { _, _ in
            Task { await retranslateAll() }
        }
    }

    // MARK: - Bottom Bar
    private var controlBar: some View {
        VStack(spacing: 12) {
            Divider()
            HStack(spacing: 20) {
                LanguagePicker(selectedLanguage: $sourceLanguage)
                Image(systemName: "arrow.right")
                    .foregroundColor(.secondary)
                LanguagePicker(selectedLanguage: $targetLanguage)
                Spacer()
                RecordButton(isRecording: $isRecording) { handleRecording() }
                Button(action: clearMessages) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .background(.ultraThinMaterial)
        .animation(.easeInOut, value: isRecording)
    }

    // MARK: - Recording
    private func handleRecording() {
        isRecording ? stopRecording() : startRecording()
    }

    private func startRecording() {
        Task {
            do {
                try await SpeechRecognizerService.ensurePermissions()
                isRecording = true
                currentTranscription = "Escuchando..."

                recognizer.onPartial = { text in
                    Task { await handleLiveTranslation(for: text) }
                }

                recognizer.onFinal = { text in
                    Task { await processFinalTranslation(for: text) }
                }

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

    // MARK: - Live translation
    private func handleLiveTranslation(for text: String) async {
        guard !text.isEmpty else { return }
        currentTranscription = text

        let translated = await translator.translate(text, from: sourceLanguage, to: targetLanguage)
        guard !translated.isEmpty else { return }

        withAnimation(.easeInOut) {
            messages.append(ChatMessage(
                originalText: text,
                translatedText: translated,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            ))
        }

        if translated != lastSpokenText {
            lastSpokenText = translated
            tts.speak(translated, language: targetLanguage, rate: 0.45)
        }
    }

    // MARK: - Final translation
    private func processFinalTranslation(for text: String) async {
        guard !text.isEmpty else { return }
        let translated = await translator.translate(text, from: sourceLanguage, to: targetLanguage)
        withAnimation(.spring()) {
            messages.append(ChatMessage(
                originalText: text,
                translatedText: translated,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            ))
        }
        tts.speak(translated, language: targetLanguage, rate: 0.45)
    }

    // MARK: - Retranslation
    private func retranslateAll() async {
        guard !messages.isEmpty else { return }
        var newMessages: [ChatMessage] = []
        for msg in messages {
            let newTranslation = await translator.translate(msg.originalText, from: sourceLanguage, to: targetLanguage)
            newMessages.append(ChatMessage(
                originalText: msg.originalText,
                translatedText: newTranslation,
                sourceLanguage: sourceLanguage,
                targetLanguage: targetLanguage
            ))
        }
        withAnimation(.easeInOut) {
            messages = newMessages
        }
    }

    // MARK: - Messages
    private func addWelcomeMessage() {
        messages.append(
            ChatMessage(
                originalText: "Bienvenido a Multivoice AI",
                translatedText: "Welcome to Multivoice AI",
                sourceLanguage: .es,
                targetLanguage: .en
            )
        )
    }

    private func clearMessages() {
        withAnimation {
            messages.removeAll()
            addWelcomeMessage()
        }
    }
}

// MARK: - Models & Components

struct ChatMessage: Identifiable {
    let id = UUID()
    let originalText: String
    let translatedText: String
    let sourceLanguage: RecognizedLanguage
    let targetLanguage: RecognizedLanguage
    let timestamp = Date()
}

struct ChatBubble: View {
    let message: ChatMessage
    let tts: TTSService

    var body: some View {
        VStack(spacing: 6) {
            // Original (derecha)
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Tú (\(message.sourceLanguage.flag))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(message.originalText)
                        .padding(10)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(12)
                        .foregroundColor(.primary)
                }
            }

            // Traducción (izquierda)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Traducción (\(message.targetLanguage.flag))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Button {
                            tts.speak(message.translatedText, language: message.targetLanguage)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                    Text(message.translatedText)
                        .padding(10)
                        .background(Color.green.opacity(0.15))
                        .cornerRadius(12)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
        }
        .padding(.horizontal)
        .transition(.opacity)
    }
}

struct RecordingIndicator: View {
    let transcription: String
    @State private var animationAmount = 1.0

    var body: some View {
        HStack {
            Circle()
                .fill(Color.red)
                .frame(width: 12, height: 12)
                .scaleEffect(animationAmount)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        animationAmount = 1.5
                    }
                }
            Text(transcription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct RecordButton: View {
    @Binding var isRecording: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red : Color.blue)
                    .frame(width: 70, height: 70)
                    .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .scaleEffect(isRecording ? 1.1 : 1.0)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isRecording)
    }
}

struct LanguagePicker: View {
    @Binding var selectedLanguage: RecognizedLanguage

    var body: some View {
        Menu {
            ForEach(RecognizedLanguage.allCases, id: \.self) { lang in
                Button(action: { selectedLanguage = lang }) {
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
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationStack {
        ConversationView()
    }
}
