import Foundation

protocol TranslationService {
    func translate(_ text: String, from source: String, to target: String) async throws -> String
}

// Puedes conservar NoOp si te sirve para tests, pero ya no lo usaremos en la app.
struct NoOpTranslationService: TranslationService {
    func translate(_ text: String, from source: String, to target: String) async throws -> String { text }
}
