import SwiftUI

@available(iOS 17.0, *)
struct ContentView: View {
    // MARK: - Estado UI
    @State private var partial = ""
    @State private var finals: [String] = []
    @State private var detectedLang: String?
    @State private var translatedText: String?
    @State private var isRecording = false
    @State private var targetLang: String = "en" // "es", "en", "fr"

    // MARK: - Servicios
    private let speech = SpeechRecognizerService()
    private let nlp = LanguageDetectionService()
    private let translator: TranslationService = TranslateKitAdapter()
    private let tts = TTSService()

    var body: some View {
        VStack(spacing: 16) {
            Text("Voz → Texto → Traducción → Voz")
                .font(.title3).bold()

            Picker("Idioma destino", selection: $targetLang) {
                Text("🇪🇸 Español").tag("es")
                Text("🇬🇧 Inglés").tag("en")
                Text("🇫🇷 Francés").tag("fr")
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            RoundedRectangle(cornerRadius: 12)
                .fill(.gray.opacity(0.12))
                .frame(height: 80)
                .overlay(
                    Text(partial.isEmpty ? "Habla para comenzar…" : partial)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                )

            if let lang = detectedLang {
                Text("Idioma detectado: \(lang)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let translated = translatedText {
                Text("Traducción: \(translated)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }

            List(finals, id: \.self) { Text($0) }

            // Iniciar/Detener reconocimiento
            Button(isRecording ? "Detener" : "Iniciar") {
                if isRecording {
                    speech.stop()
                    isRecording = false
                } else {
                    startRecognition()
                }
            }
            .buttonStyle(.borderedProminent)

            // TTS
            Button("🔊 Reproducir traducción") {
                guard let txt = translatedText else { return }
                let voice: String = (targetLang == "es") ? "es-MX" : (targetLang == "fr" ? "fr-FR" : "en-US")
                tts.speak(txt, lang: voice)
            }
            .buttonStyle(.bordered)
            .disabled(translatedText == nil)
        }
        .padding()
        .onDisappear { speech.stop() }
    }

    // MARK: - Reconocimiento de voz
    private func startRecognition() {
        Task {
            do {
                try await SpeechRecognizerService.ensurePermissions()

                speech.onPartial = { txt in partial = txt }

                speech.onFinal = { txt in
                    partial = ""
                    finals.append(txt)

                    if let src = nlp.detectLanguage(for: txt) {
                        detectedLang = src
                        Task {
                            do {
                                let translated = try await translator.translate(txt, from: src, to: targetLang)
                                await MainActor.run { translatedText = translated }
                            } catch {
                                print("Error traduciendo:", error.localizedDescription)
                            }
                        }
                    }
                }

                speech.onError = { err in
                    print("ASR error:", err.localizedDescription)
                }

                // Ajusta el locale a lo que vayas a hablar principalmente
                try speech.start(locale: Locale(identifier: "es-MX"))
                isRecording = true
            } catch {
                print("Error al iniciar SpeechRecognizer:", error.localizedDescription)
            }
        }
    }
}
//a
