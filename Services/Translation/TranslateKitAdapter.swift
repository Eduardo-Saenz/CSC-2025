import Foundation

// MARK: - Interfaz común (ya la tienes en TranslationService.swift)
// protocol TranslationService { func translate(_ text: String, from source: String, to target: String) async throws -> String }

#if canImport(Translate)
import Translate

@available(iOS 17.0, *)
final class TranslateKitAdapter: TranslationService {

    private let translator = Translator() // motor on-device de Apple

    // Mapea "es", "en", "fr" → TranslateLanguage
    private func lang(_ code: String) -> TranslateLanguage {
        switch code.lowercased() {
        case "es", "es-mx", "es-es": return .spanish
        case "en", "en-us", "en-gb": return .english
        case "fr", "fr-fr", "fr-ca": return .french
        default:                      return .english // fallback seguro
        }
    }

    func translate(_ text: String, from source: String, to target: String) async throws -> String {
        // Si origen y destino son iguales, no traduzcas
        let src = lang(source)
        let dst = lang(target)
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return "" }
        guard src != dst else { return text }

        // Traducción on-device
        let result = try await translator.translate(text, from: src, to: dst)
        return result.translatedText
    }
}

#else

/// Si el SDK no trae `Translate`, deja un stub local para no bloquear la app.
/// Cambia a iOS 17+ y agrega Translate.framework para usar la versión real.
final class TranslateKitAdapter: TranslationService {
    func translate(_ text: String, from source: String, to target: String) async throws -> String {
        // Fallback visible para que se note en demo que NO es traducción real.
        return "[\(target.uppercased()) - STUB] " + text
    }
}
#endif
