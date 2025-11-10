import SwiftUI

struct LoginView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var selectedCountry: String = ""
    @State private var selectedLanguage: String = ""
    @State private var didAppear = false
    @State private var bounce = false
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity = 0.0

    private let countries = [
        "México 🇲🇽", "Estados Unidos 🇺🇸", "Canadá 🇨🇦",
        "Argentina 🇦🇷", "Brasil 🇧🇷", "Alemania 🇩🇪",
        "Francia 🇫🇷", "Japón 🇯🇵"
    ]

    private let languages = [
        "Español", "English", "Français", "Deutsch", "Português"
    ]

    var body: some View {
        ZStack {
            // 🌅 Fondo dorado cálido
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.91, blue: 0.78),
                    Color(red: 0.90, green: 0.77, blue: 0.55),
                    Color(red: 0.74, green: 0.58, blue: 0.40)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    // 🏆 Imagen principal con rebote
                    Image("mascotas2026")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250)
                        .shadow(radius: 10)
                        .padding(.top, 30) // 🔽 antes estaba en 60
                        .offset(y: bounce ? -8 : 0)
                        .animation(
                            .interpolatingSpring(stiffness: 90, damping: 7)
                                .delay(0.4)
                                .repeatForever(autoreverses: true),
                            value: bounce
                        )
                        .opacity(didAppear ? 1 : 0)
                        .offset(y: didAppear ? 0 : 40)
                        .animation(.easeOut(duration: 0.6), value: didAppear)

                    // 🖋️ Título Mundial 2026
                    Text("MUNDIAL 2026")
                        .font(.custom("Orbitron-Bold", size: 32))
                        .tracking(5)
                        .foregroundStyle(.black)
                        .shadow(color: .yellow.opacity(0.3), radius: 4, x: 0, y: 0)
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                        .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.4), value: titleScale)
                        .animation(.easeInOut(duration: 0.8).delay(0.4), value: titleOpacity)

                    // 🧾 Tarjeta con formulario
                    VStack(spacing: 20) {
                        Text("Configura tu país e idioma para personalizar tu experiencia:")
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)

                        VStack(spacing: 16) {
                            PickerField(
                                title: "Selecciona tu país",
                                systemImage: "globe.americas.fill",
                                placeholder: "Selecciona",
                                selection: $selectedCountry,
                                options: countries
                            )

                            PickerField(
                                title: "Selecciona tu idioma",
                                systemImage: "character.bubble.fill",
                                placeholder: "Selecciona",
                                selection: $selectedLanguage,
                                options: languages
                            )
                        }

                        // 🎯 Botón
                        Button(action: saveSettings) {
                            Text("Continuar")
                                .font(.headline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(
                                    LinearGradient(
                                        colors: isFormValid
                                            ? [Color.black, Color(red: 0.82, green: 0.67, blue: 0.3)]
                                            : [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 5)
                                .scaleEffect(isFormValid ? 1 : 0.96)
                                .opacity(isFormValid ? 1 : 0.7)
                        }
                        .disabled(!isFormValid)
                        .animation(.spring(), value: isFormValid)

                        Text("Tus preferencias solo se usan para personalizar el contenido.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(26)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                    )
                    .padding(.horizontal, 28)
                    .padding(.bottom, 100) // ⬆️ aumentado (antes 60)
                    .opacity(didAppear ? 1 : 0)
                    .offset(y: didAppear ? 0 : 50)
                    .animation(.easeOut(duration: 0.8).delay(0.3), value: didAppear)
                }
            }
        }
        .onAppear {
            withAnimation {
                didAppear = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                bounce = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                titleOpacity = 1
                titleScale = 1
            }
        }
    }

    // MARK: - Helpers
    private var isFormValid: Bool {
        !selectedCountry.isEmpty && !selectedLanguage.isEmpty
    }

    private func saveSettings() {
        settings.selectedCountry = selectedCountry
        settings.selectedLanguage = selectedLanguage
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

// MARK: - PickerField (azul subrayado)
private struct PickerField: View {
    let title: String
    let systemImage: String
    let placeholder: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Menu {
                Picker(selection: $selection, label: EmptyView()) {
                    Text(placeholder).tag("")
                    ForEach(options, id: \.self) {
                        Text($0)
                            .foregroundStyle(.blue)
                            .tag($0)
                    }
                }
            } label: {
                HStack {
                    if selection.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.blue)
                    } else {
                        Text(selection)
                            .foregroundStyle(.primary)
                    }

                    Spacer()
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                )
            }
        }
    }
}
