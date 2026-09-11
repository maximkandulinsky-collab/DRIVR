import PhotosUI
import SwiftUI
import UIKit

struct VehicleSetupView: View {
    @Bindable var state: AppState
    @State private var viewModel: VehicleSetupViewModel
    @State private var photoItem: PhotosPickerItem?
    let onFinished: (() -> Void)?

    init(state: AppState, vehicle: Vehicle? = nil, onFinished: (() -> Void)? = nil) {
        self.state = state
        _viewModel = State(initialValue: VehicleSetupViewModel(vehicle: vehicle, units: state.units))
        self.onFinished = onFinished
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    intro
                    photoPicker
                    vehicleFields
                    unitPicker
                    saveButton
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { cancelToolbar }
            .drivrBackground()
            .alert("Vehicle setup", isPresented: errorPresented) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: photoItem) { _, item in
                Task { await viewModel.loadPhoto(item) }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var intro: some View {
        VStack(spacing: 8) {
            Text("YOUR CAR. YOUR DATA.")
                .font(.title2.weight(.black))
                .tracking(1.3)
            Text("Vehicle details and every recorded drive stay on this iPhone.")
                .foregroundStyle(DrivrTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
    }

    private var photoPicker: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                photoContent
                Image(systemName: "camera.fill")
                    .foregroundStyle(Color.black)
                    .frame(width: 44, height: 44)
                    .background(DrivrTheme.lime, in: Circle())
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.imageData == nil ? "Choose vehicle photo" : "Change vehicle photo")
    }

    @ViewBuilder
    private var photoContent: some View {
        if viewModel.isProcessingPhoto {
            ProgressView()
                .frame(width: 180, height: 120)
                .background(DrivrTheme.elevated, in: RoundedRectangle(cornerRadius: 24))
        } else if let data = viewModel.imageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        } else {
            Image(systemName: "car.side.fill")
                .font(.system(size: 48))
                .foregroundStyle(DrivrTheme.lime)
                .frame(width: 180, height: 120)
                .background(DrivrTheme.elevated, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private var vehicleFields: some View {
        VStack(spacing: 14) {
            field("Make", text: $viewModel.make, contentType: .organizationName)
            field("Model", text: $viewModel.model)
            field("Year", text: $viewModel.year, keyboard: .numberPad)
            field("Engine", text: $viewModel.engine)
            field("Nickname", text: $viewModel.nickname)
        }
        .drivrCard()
    }

    private func field(
        _ label: String,
        text: Binding<String>,
        contentType: UITextContentType? = nil,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(1)
                .foregroundStyle(DrivrTheme.secondaryText)
            TextField(label, text: text)
                .textContentType(contentType)
                .keyboardType(keyboard)
                .textInputAutocapitalization(.words)
                .padding(13)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var unitPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DISPLAY UNITS")
                .font(.caption2.weight(.bold))
                .tracking(1)
                .foregroundStyle(DrivrTheme.secondaryText)
            Picker("Display units", selection: $viewModel.units) {
                ForEach(UnitSystem.allCases) { system in
                    Text(system.title).tag(system)
                }
            }
            .pickerStyle(.segmented)
            Text(viewModel.units.detail)
                .font(.caption)
                .foregroundStyle(DrivrTheme.secondaryText)
        }
        .drivrCard()
    }

    private var saveButton: some View {
        Button(viewModel.editingVehicle == nil ? "SAVE VEHICLE" : "SAVE CHANGES") {
            if viewModel.save(into: state) { onFinished?() }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(!viewModel.canSave)
        .opacity(viewModel.canSave ? 1 : 0.45)
    }

    @ToolbarContentBuilder
    private var cancelToolbar: some ToolbarContent {
        if onFinished != nil {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { onFinished?() }
            }
        }
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}