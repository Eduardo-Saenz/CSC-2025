import SwiftUI


struct Login2: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.colorScheme) private var scheme
    @State private var selectedCountry: String = ""
    @State private var selectedLanguage: String = ""
    @State private var didAppear = false

    private let countries = [
        "México 🇲🇽", "Estados Unidos 🇺🇸", "Canadá 🇨🇦",
        "Argentina 🇦🇷", "Brasil 🇧🇷", "Alemania 🇩🇪",
        "Francia 🇫🇷", "Japón 🇯🇵"
    ]

    private let languages = [
        "Español", "English", "Français", "Deutsch", "Português"
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
        
                // Contenido scrollable para alturas pequeñas
                ScrollView(showsIndicators: false) {
                    VStack {
                        // Tarjeta centrada y de ancho contenido
                        VStack(spacing: 40) {
                            header

                            PickerField(
                                title: "Selecciona tu país",
                                systemImage: "globe.americas.fill",
                                placeholder: "",
                                selection: $selectedCountry,
                                options: countries
                            )
                            

                            PickerField(
                                title: "Selecciona tu idioma",
                                systemImage: "character.bubble.fill",
                                placeholder: "",
                                selection: $selectedLanguage,
                                options: languages
                            )
                            .padding(.bottom, 20)
                            continueButton
                            footer
                        }
                        .padding(22)
                        .frame(maxWidth: 520)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .padding(.bottom, 80)
                        .opacity(didAppear ? 1 : 0)
                        .offset(y: didAppear ? 0 : 20)
                        .blur(radius: didAppear ? 0 : 6)
                        .animation(.easeOut(duration: 0.5), value: didAppear)
                    }
                    .frame(minHeight: geo.size.height, alignment: .center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { didAppear = true }
        }
      

        .onChange(of: selectedCountry) { _ in UISelectionFeedbackGenerator().selectionChanged() }
        .onChange(of: selectedLanguage) { _ in UISelectionFeedbackGenerator().selectionChanged() }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
        
            Text("Bienvenido ")
                .font(.system(size: 40))
                .bold()
                .padding(.trailing, 100)
                .padding(.bottom, 10)
            
            
            Text("Configura tu país e idioma para personalizar tu experiencia.")
                .font(.system(size: 20))
                .padding(.trailing, 40)
                .padding(.bottom, 20)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
            
        }
        .padding(.bottom, 4)
    }

    private var continueButton: some View {
        Button(action: saveSettings) {
            HStack {
                Text("Continuar")
                    .font(.headline.weight(.semibold))
           
            }
            .frame(width: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(PrimaryButtonStyle(enabled: isFormValid))
        .disabled(!isFormValid)
        .padding(.top, 6)
        .accessibilityLabel("Continuar")
        .accessibilityHint("Guarda país e idioma seleccionados")
    }

    private var footer: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "lock.shield.fill")
                    .font(.footnote)
                Text("Tus preferencias solo se usan para personalizar el contenido.")
            }
            .foregroundStyle(.secondary) // <-- adaptable
            .font(.footnote)

            // Indicador de validación (visual)
            if !isFormValid {
                Text("Selecciona un país y un idioma para continuar.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary) // <-- adaptable
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .animation(.easeInOut(duration: 0.2), value: isFormValid)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Helpers

    private var isFormValid: Bool {
        !selectedCountry.isEmpty && !selectedLanguage.isEmpty
    }

    private func saveSettings() {
        settings.selectedCountry = selectedCountry
        settings.selectedLanguage = selectedLanguage
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - PickerField (reutilizable)
private struct PickerField: View {
    let title: String
    let systemImage: String
    let placeholder: String
    @Binding var selection: String
    let options: [String]

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary) // <-- adaptable

            Menu {
                Picker(selection: $selection, label: EmptyView()) {
                    Text(placeholder).tag("")
                    ForEach(options, id: \.self) { Text($0).tag($0) }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? placeholder : selection)
                        .foregroundStyle(selection.isEmpty ? .tertiary : .primary) // <-- adaptable
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary) // <-- adaptable
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.tertiarySystemFill)) // <-- adaptable
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color(.separator), lineWidth: 1) // <-- adaptable
                        )
                )
            }
            .accessibilityLabel(title)
        }
    }
}

// MARK: - PrimaryButtonStyle
private struct PrimaryButtonStyle: ButtonStyle {
    let enabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(enabled ? .white : .primary) // texto visible en ambos estados
            .frame(width: 200)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(enabled ? Color.accentColor : Color(.tertiarySystemFill)) // <-- adaptable
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color(.separator).opacity(enabled ? 0.25 : 0.12), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(enabled ? 0.22 : 0.08), radius: enabled ? 10 : 4, x: 0, y: enabled ? 8 : 2)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

#Preview {
    Login2()
}
