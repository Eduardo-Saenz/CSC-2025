//
//  ConversationView.swift
//  
//
//  Created by Axel Castellanos on 04/11/25.
//

import SwiftUI

struct ConversationView: View {
    @State private var messages: [ChatMessage] = []
    @State private var isRecording = false
    @State private var currentTranscription = ""
    @State private var selectedTargetLanguage: Language = .spanish
    
    var body: some View {
        VStack(spacing: 0) {
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { oldValue, newValue in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Indicador de grabación
            if isRecording {
                RecordingIndicator(transcription: currentTranscription)
            }
            
            // Barra de controles inferior
            VStack(spacing: 12) {
                Divider()
                
                HStack(spacing: 20) {
                    // Selector de idioma
                    LanguagePicker(selectedLanguage: $selectedTargetLanguage)
                    
                    Spacer()
                    
                    // Botón de grabación
                    RecordButton(isRecording: $isRecording) {
                        handleRecording()
                    }
                    
                    Spacer()
                    
                    // Botón de limpiar
                    Button(action: clearMessages) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("Traductor en vivo")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            addWelcomeMessage()
        }
    }
    
    //Functions
    
    private func handleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        isRecording = true
        currentTranscription = "Escuchando..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            simulateTranslation()
        }
    }
    
    private func stopRecording() {
        isRecording = false
        currentTranscription = ""
    }
    
    private func simulateTranslation() {
        let originalText = "Hello, how are you?"
        let translatedText = "Hola, ¿cómo estás?"
        
        let message = ChatMessage(
            originalText: originalText,
            translatedText: translatedText,
            sourceLanguage: .english,
            targetLanguage: selectedTargetLanguage
        )
        
        withAnimation(.spring()) {
            messages.append(message)
        }
        
        stopRecording()
    }
    
    private func addWelcomeMessage() {
        let welcome = ChatMessage(
            originalText: "Welcome to Multivoice AI",
            translatedText: "Bienvenido a Multivoice AI",
            sourceLanguage: .english,
            targetLanguage: .spanish
        )
        messages.append(welcome)
    }
    
    private func clearMessages() {
        withAnimation {
            messages.removeAll()
            addWelcomeMessage()
        }
    }
}

// Models

struct ChatMessage: Identifiable {
    let id = UUID()
    let originalText: String
    let translatedText: String
    let sourceLanguage: Language
    let targetLanguage: Language
    let timestamp = Date()
}

enum Language: String, CaseIterable {
    case english = "English"
    case spanish = "Español"
    case french = "Français"
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .spanish: return "🇲🇽"
        case .french: return "🇨🇦"
        }
    }
    
    var color: Color {
        switch self {
        case .english: return .blue
        case .spanish: return .green
        case .french: return .red
        }
    }
}

// Components

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text(message.sourceLanguage.flag)
                    .font(.title3)
                Text(message.sourceLanguage.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(message.originalText)
                .font(.body)
                .padding()
                .background(message.sourceLanguage.color.opacity(0.1))
                .cornerRadius(12)
            
            
            HStack {
                Text(message.targetLanguage.flag)
                    .font(.title3)
                Text(message.targetLanguage.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                
                Button(action: playTranslation) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(message.targetLanguage.color)
                }
            }
            
            Text(message.translatedText)
                .font(.body)
                .padding()
                .background(message.targetLanguage.color.opacity(0.1))
                .cornerRadius(12)
        }
        .padding(.horizontal, 4)
    }
    
    private func playTranslation() {
        
        print("🔊 Playing: \(message.translatedText)")
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
        .padding()
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
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(isRecording ? 1.1 : 1.0)
        .animation(.spring(), value: isRecording)
    }
}

struct LanguagePicker: View {
    @Binding var selectedLanguage: Language
    
    var body: some View {
        Menu {
            ForEach(Language.allCases, id: \.self) { language in
                Button(action: { selectedLanguage = language }) {
                    HStack {
                        Text(language.flag)
                        Text(language.rawValue)
                        if selectedLanguage == language {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Text(selectedLanguage.flag)
                    .font(.title2)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

// Preview

#Preview {
    NavigationStack {
            ConversationView()
        }
}
