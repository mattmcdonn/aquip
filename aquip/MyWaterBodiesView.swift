import SwiftUI

// MARK: - Limit reached popup

struct LimitReachedPopup: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color(red: 254/255, green: 243/255, blue: 199/255))
                        .frame(width: 64, height: 64)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(red: 217/255, green: 119/255, blue: 6/255))
                }
                .padding(.top, 28)
                .padding(.bottom, 16)

                Text("Limit Reached")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    .padding(.bottom, 10)

                Text("You can only add up to 5 pools and spas combined. Remove an existing entry before adding a new one.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                Divider()

                Button {
                    withAnimation(.easeIn(duration: 0.18)) { isPresented = false }
                } label: {
                    Text("OK")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Detail info row

private struct DetailInfoRow: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
                .frame(width: 46, height: 46)
                .background(iconBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Water body detail view

struct WaterBodyDetailView: View {
    @Environment(WaterBodyStore.self) private var store

    let waterBodyID: UUID
    var onBack: () -> Void

    @State private var showingEdit = false

    private var waterBody: UserWaterBody? {
        store.bodies.first { $0.id == waterBodyID }
    }

    private var displayVolume: String {
        guard let wb = waterBody else { return "—" }
        let val = wb.volumeUnit == "liters"
            ? wb.volumeLiters
            : wb.volumeLiters / 3.78541
        let unit = wb.volumeUnit == "liters" ? "L" : "gal"
        let formatted = val >= 1000
            ? String(format: "%.0f", val)
            : String(format: "%.1f", val)
        return "\(formatted) \(unit)"
    }

    private var sanitizerDisplay: (icon: String, label: String, color: Color, bg: Color) {
        switch waterBody?.sanitizer {
        case "salt":
            return ("waveform", "Salt / Saltwater",
                    Color(red: 8/255, green: 145/255, blue: 178/255),
                    Color(red: 207/255, green: 250/255, blue: 254/255))
        case "bromine":
            return ("flame.fill", "Bromine",
                    Color(red: 217/255, green: 119/255, blue: 6/255),
                    Color(red: 254/255, green: 243/255, blue: 199/255))
        default:
            return ("drop.fill", "Chlorine",
                    Color(red: 37/255, green: 99/255, blue: 235/255),
                    Color(red: 219/255, green: 234/255, blue: 254/255))
        }
    }

    private let gradient = LinearGradient(
        colors: [
            Color(red: 37/255, green: 99/255, blue: 235/255),
            Color(red: 6/255, green: 182/255, blue: 212/255)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        ZStack {
            if let wb = waterBody {
                detailContent(wb)

                if showingEdit {
                    AddWaterBodyView(
                        existing: wb,
                        onDone: {
                            withAnimation(.easeInOut(duration: 0.3)) { showingEdit = false }
                        },
                        onDelete: {
                            store.delete(id: waterBodyID)
                            onBack()
                        }
                    )
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingEdit)
    }

    @ViewBuilder
    private func detailContent(_ wb: UserWaterBody) -> some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 15))
                        }
                        .foregroundStyle(.white.opacity(0.9))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) { showingEdit = true }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "pencil")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Edit")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.22))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 20)

                HStack(spacing: 16) {
                    Image(systemName: wb.type == "spa" ? "drop.fill" : "water.waves")
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(wb.name)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                        Text(wb.type == "spa" ? "Hot Tub / Spa" : "Swimming Pool")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 72)
            .padding(.bottom, 28)
            .background(gradient)

            // Info
            ScrollView {
                VStack(spacing: 12) {
                    DetailInfoRow(
                        icon: "drop.fill",
                        iconColor: wb.type == "spa"
                            ? Color(red: 8/255, green: 145/255, blue: 178/255)
                            : Color(red: 37/255, green: 99/255, blue: 235/255),
                        iconBg: wb.type == "spa"
                            ? Color(red: 207/255, green: 250/255, blue: 254/255)
                            : Color(red: 219/255, green: 234/255, blue: 254/255),
                        label: "Volume",
                        value: displayVolume
                    )

                    if wb.type == "pool" {
                        DetailInfoRow(
                            icon: "thermometer.medium",
                            iconColor: wb.hasHeater
                                ? Color(red: 239/255, green: 68/255, blue: 68/255)
                                : Color(red: 107/255, green: 114/255, blue: 128/255),
                            iconBg: wb.hasHeater
                                ? Color(red: 254/255, green: 226/255, blue: 226/255)
                                : Color(red: 243/255, green: 244/255, blue: 246/255),
                            label: "Pool Heater",
                            value: wb.hasHeater ? "Installed" : "Not Installed"
                        )
                    }

                    DetailInfoRow(
                        icon: "drop.triangle.fill",
                        iconColor: Color(red: 5/255, green: 150/255, blue: 105/255),
                        iconBg: Color(red: 209/255, green: 250/255, blue: 229/255),
                        label: "Water Source",
                        value: wb.waterSource == "well" ? "Well Water" : "Freshwater"
                    )

                    let san = sanitizerDisplay
                    DetailInfoRow(
                        icon: san.icon,
                        iconColor: san.color,
                        iconBg: san.bg,
                        label: "Sanitizer",
                        value: san.label
                    )
                }
                .padding(24)
                .padding(.bottom, 100)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        }
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
    }
}

// MARK: - Main list view

struct MyWaterBodiesView: View {
    @Environment(WaterBodyStore.self) private var store
    @State private var showingAddForm = false
    @State private var showingDetail = false
    @State private var viewingBodyID: UUID? = nil
    @State private var showLimitAlert = false

    var body: some View {
        ZStack {
            mainList

            if showingDetail, let id = viewingBodyID {
                WaterBodyDetailView(
                    waterBodyID: id,
                    onBack: {
                        withAnimation(.easeInOut(duration: 0.3)) { showingDetail = false }
                        viewingBodyID = nil
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }

            if showingAddForm {
                AddWaterBodyView(
                    existing: nil,
                    onDone: {
                        withAnimation(.easeInOut(duration: 0.3)) { showingAddForm = false }
                    }
                )
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }

            if showLimitAlert {
                LimitReachedPopup(isPresented: $showLimitAlert)
                    .zIndex(2)
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingDetail)
        .animation(.easeInOut(duration: 0.3), value: showingAddForm)
        .animation(.easeOut(duration: 0.2), value: showLimitAlert)
    }

    private var mainList: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Pools & Spas")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                Text("Manage your water bodies")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 72)
            .padding(.bottom, 32)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 37/255, green: 99/255, blue: 235/255),
                        Color(red: 6/255, green: 182/255, blue: 212/255)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

            ScrollView {
                VStack(spacing: 12) {
                    if store.bodies.isEmpty {
                        addButton
                    } else {
                        ForEach(store.bodies) { entry in
                            WaterBodyCard(waterBody: entry) {
                                viewingBodyID = entry.id
                                withAnimation(.easeInOut(duration: 0.3)) { showingDetail = true }
                            }
                        }
                        addButton
                    }
                }
                .padding(24)
                .padding(.bottom, 100)
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))
        }
        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
    }

    private var addButton: some View {
        Button {
            if store.bodies.count >= 5 {
                withAnimation(.easeOut(duration: 0.2)) { showLimitAlert = true }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) { showingAddForm = true }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                Text("Add Pool or Spa")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                    .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255).opacity(0.4))
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Water body card

struct WaterBodyCard: View {
    let waterBody: UserWaterBody
    var onTap: () -> Void

    private var displayVolume: String {
        let val = waterBody.volumeUnit == "liters"
            ? waterBody.volumeLiters
            : waterBody.volumeLiters / 3.78541
        let unit = waterBody.volumeUnit == "liters" ? "L" : "gal"
        return "\(String(format: "%.0f", val)) \(unit)"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: waterBody.type == "spa" ? "drop.fill" : "water.waves")
                    .font(.system(size: 22))
                    .foregroundStyle(
                        waterBody.type == "spa"
                        ? Color(red: 8/255, green: 145/255, blue: 178/255)
                        : Color(red: 37/255, green: 99/255, blue: 235/255)
                    )
                    .frame(width: 52, height: 52)
                    .background(
                        waterBody.type == "spa"
                        ? Color(red: 207/255, green: 250/255, blue: 254/255)
                        : Color(red: 219/255, green: 234/255, blue: 254/255)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 3) {
                    Text(waterBody.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    Text(waterBody.type == "spa" ? "Hot Tub / Spa" : "Swimming Pool")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                    Text(displayVolume)
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 209/255, green: 213/255, blue: 219/255))
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add / Edit form

struct AddWaterBodyView: View {
    @Environment(WaterBodyStore.self) private var store

    private let existing: UserWaterBody?
    var onDone: () -> Void
    var onDelete: (() -> Void)?

    @State private var bodyType: String
    @State private var name: String
    @State private var volumeUnit: String
    @State private var volume: String
    @State private var hasHeater: String
    @State private var waterSource: String
    @State private var sanitizer: String
    @State private var showVolumeCalc = false
    @State private var keyboardHeight: CGFloat = 0

    init(existing: UserWaterBody? = nil, onDone: @escaping () -> Void, onDelete: (() -> Void)? = nil) {
        self.existing = existing
        self.onDone = onDone
        self.onDelete = onDelete

        _bodyType    = State(initialValue: existing?.type ?? "pool")
        _name        = State(initialValue: existing?.name ?? "")
        _volumeUnit  = State(initialValue: existing?.volumeUnit ?? "gallons")

        let dispVol: Double
        if let e = existing {
            dispVol = e.volumeUnit == "liters" ? e.volumeLiters : e.volumeLiters / 3.78541
        } else {
            dispVol = 0
        }
        _volume      = State(initialValue: existing == nil ? "" : String(format: "%.0f", dispVol))
        _hasHeater   = State(initialValue: existing.map { $0.hasHeater ? "yes" : "no" } ?? "")
        _waterSource = State(initialValue: existing?.waterSource ?? "")
        _sanitizer   = State(initialValue: existing?.sanitizer ?? "")
    }

    private var isEditing: Bool { existing != nil }

    private var canSave: Bool {
        let base = !name.trimmingCharacters(in: .whitespaces).isEmpty
                && !volume.isEmpty && !waterSource.isEmpty && !sanitizer.isEmpty
        return bodyType == "spa" ? base : base && !hasHeater.isEmpty
    }

    private var computedVolumeLiters: Double {
        let val = Double(volume) ?? 0
        return volumeUnit == "liters" ? val : val * 3.78541
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button(action: onDone) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 15))
                            }
                            .foregroundStyle(.white.opacity(0.9))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        if isEditing, let deleteAction = onDelete {
                            Button(action: deleteAction) {
                                Image(systemName: "trash")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white.opacity(0.22))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 14)

                    Text(isEditing ? "Edit \(bodyType == "spa" ? "Spa" : "Pool")" : "Add Pool or Spa")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                    Text(isEditing ? "Update your water body details" : "Enter your water body details")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 219/255, green: 234/255, blue: 254/255))
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 72)
                .padding(.bottom, 28)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 37/255, green: 99/255, blue: 235/255),
                            Color(red: 6/255, green: 182/255, blue: 212/255)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {

                        // Type selector (disabled when editing)
                        VStack(alignment: .leading, spacing: 8) {
                            FormSectionLabel(text: "Type")
                            HStack(spacing: 12) {
                                ForEach([("pool", "Swimming Pool"), ("spa", "Hot Tub / Spa")], id: \.0) { value, label in
                                    let isSelected = bodyType == value
                                    Button { if !isEditing { bodyType = value } } label: {
                                        Text(label)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(
                                                isSelected
                                                ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                                : Color(red: 55/255, green: 65/255, blue: 81/255)
                                            )
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .background(
                                                isSelected
                                                ? Color(red: 239/255, green: 246/255, blue: 255/255)
                                                : Color.white
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        isSelected
                                                        ? Color(red: 37/255, green: 99/255, blue: 235/255)
                                                        : Color(red: 229/255, green: 231/255, blue: 235/255),
                                                        lineWidth: isSelected ? 2 : 1
                                                    )
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .opacity(isEditing && !isSelected ? 0.4 : 1)
                                    }
                                    .buttonStyle(.plain)
                                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                                }
                            }
                        }

                        // Name
                        VStack(alignment: .leading, spacing: 6) {
                            FormSectionLabel(text: "Name")
                            TextField(
                                bodyType == "spa" ? "e.g. Backyard Spa" : "e.g. Backyard Pool",
                                text: $name
                            )
                            .font(.system(size: 16))
                            .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 209/255, green: 213/255, blue: 219/255), lineWidth: 1.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Volume
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .firstTextBaseline) {
                                FormSectionLabel(text: bodyType == "spa" ? "Spa Volume" : "Pool Volume")
                                Spacer()
                                Button("Volume Calculator") {
                                    var t = Transaction()
                                    t.disablesAnimations = true
                                    withTransaction(t) { showVolumeCalc = true }
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color(red: 37/255, green: 99/255, blue: 235/255))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(red: 219/255, green: 234/255, blue: 254/255))
                                .clipShape(Capsule())
                            }

                            FormMenuPicker(
                                label: "Volume Unit",
                                placeholder: "Select unit",
                                selection: $volumeUnit,
                                options: [("gallons", "Gallons"), ("liters", "Liters")]
                            )

                            FormNumberInput(
                                label: bodyType == "spa" ? "Spa Volume" : "Pool Volume",
                                placeholder: bodyType == "spa" ? "Enter spa volume" : "Enter pool volume",
                                unit: volumeUnit == "liters" ? "L" : "gal",
                                value: $volume
                            )
                        }

                        // Pool Heater (pool only)
                        if bodyType == "pool" {
                            FormMenuPicker(
                                label: "Pool Heater",
                                placeholder: "Select option",
                                selection: $hasHeater,
                                options: [("yes", "Yes"), ("no", "No")]
                            )
                        }

                        // Water Source
                        FormMenuPicker(
                            label: "Water Source",
                            placeholder: "Select water source",
                            selection: $waterSource,
                            options: [("freshwater", "Freshwater"), ("well", "Well Water")]
                        )

                        // Sanitizer
                        VStack(alignment: .leading, spacing: 10) {
                            FormSectionLabel(text: "Water Sanitizer")
                            VStack(spacing: 10) {
                                ForEach([
                                    ("chlorine", "Chlorine", "drop.fill",
                                     Color(red: 37/255,  green: 99/255,  blue: 235/255),
                                     Color(red: 219/255, green: 234/255, blue: 254/255)),
                                    ("salt",     "Salt",     "waveform",
                                     Color(red: 8/255,   green: 145/255, blue: 178/255),
                                     Color(red: 207/255, green: 250/255, blue: 254/255)),
                                    ("bromine",  "Bromine",  "flame.fill",
                                     Color(red: 217/255, green: 119/255, blue: 6/255),
                                     Color(red: 254/255, green: 243/255, blue: 199/255))
                                ], id: \.0) { value, label, icon, accent, bg in
                                    let isSelected = sanitizer == value
                                    Button { sanitizer = value } label: {
                                        HStack(spacing: 16) {
                                            Image(systemName: icon)
                                                .font(.system(size: 22))
                                                .foregroundStyle(accent)
                                                .frame(width: 48, height: 48)
                                                .background(bg)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            Text(label)
                                                .font(.system(size: 17, weight: .medium))
                                                .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                                            Spacer()
                                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 22))
                                                .foregroundStyle(isSelected ? accent : Color(red: 209/255, green: 213/255, blue: 219/255))
                                        }
                                        .padding(16)
                                        .background(Color.white)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(isSelected ? accent : Color(red: 229/255, green: 231/255, blue: 235/255),
                                                        lineWidth: isSelected ? 2 : 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                    }
                                    .buttonStyle(.plain)
                                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 180 : 180)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                    withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = frame.height }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    withAnimation(.easeOut(duration: 0.15)) { keyboardHeight = 0 }
                }
            }
            .background(Color(red: 249/255, green: 250/255, blue: 251/255))

            // Save button
            VStack(spacing: 0) {
                Button {
                    guard canSave else { return }
                    let body = UserWaterBody(
                        id: existing?.id ?? UUID(),
                        name: name.trimmingCharacters(in: .whitespaces),
                        type: bodyType,
                        volumeLiters: computedVolumeLiters,
                        volumeUnit: volumeUnit,
                        hasHeater: hasHeater == "yes",
                        waterSource: waterSource,
                        sanitizer: sanitizer
                    )
                    if isEditing { store.update(body) } else { store.add(body) }
                    onDone()
                } label: {
                    Text(isEditing ? "Save Changes" : "Add \(bodyType == "spa" ? "Spa" : "Pool")")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(canSave ? .white : Color(red: 156/255, green: 163/255, blue: 175/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Group {
                                if canSave {
                                    LinearGradient(
                                        colors: [Color(red: 37/255, green: 99/255, blue: 235/255),
                                                 Color(red: 6/255, green: 182/255, blue: 212/255)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                } else {
                                    LinearGradient(
                                        colors: [Color(red: 229/255, green: 231/255, blue: 235/255),
                                                 Color(red: 229/255, green: 231/255, blue: 235/255)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .animation(.easeInOut(duration: 0.15), value: canSave)
                }
                .disabled(!canSave)
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .padding(.bottom, 100)
            }
            .background(Color.white)
        }
        .fullScreenCover(isPresented: $showVolumeCalc) {
            PoolVolumeCalculatorCover(
                isPresented: $showVolumeCalc,
                onApply: { vol, unit in
                    volume = vol
                    volumeUnit = unit
                }
            )
            .presentationBackground(.clear)
        }
    }
}
