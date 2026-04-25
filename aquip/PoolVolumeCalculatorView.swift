import SwiftUI

// MARK: - Full-screen cover wrapper (dim + slide-up panel)

struct PoolVolumeCalculatorCover: View {
    @Binding var isPresented: Bool
    var onApply: (String, String) -> Void  // (volume, unit)

    @State private var showDim   = false
    @State private var showPanel = false

    var body: some View {
        GeometryReader { geo in
            let totalHeight = geo.size.height + geo.safeAreaInsets.top + geo.safeAreaInsets.bottom

            ZStack(alignment: .bottom) {
                if showDim {
                    Color.black.opacity(0.45)
                        .ignoresSafeArea()
                        .onTapGesture { dismissSheet() }
                }

                if showPanel {
                    PoolVolumeCalculatorPanel(
                        screenHeight: totalHeight,
                        onClose: dismissSheet,
                        onApply: { volume, unit in
                            dismissSheet()
                            onApply(volume, unit)
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeOut(duration: 0.15)) { showDim = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    showPanel = true
                }
            }
        }
    }

    private func dismissSheet() {
        withAnimation(.easeIn(duration: 0.2)) { showPanel = false }
        withAnimation(.easeIn(duration: 0.15).delay(0.1)) { showDim = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) { isPresented = false }
        }
    }
}

// MARK: - Calculator panel content

struct PoolVolumeCalculatorPanel: View {
    let screenHeight: CGFloat
    var onClose: () -> Void
    var onApply: (String, String) -> Void

    @State private var selectedShape = ""
    @State private var unit          = "gallons"

    // Rectangle/Square
    @State private var rectLength = ""
    @State private var rectWidth  = ""
    @State private var rectDepth  = ""

    // Circular/Oval
    @State private var circRA    = ""
    @State private var circRB    = ""
    @State private var circDepth = ""

    // Kidney
    @State private var kidneyA      = ""
    @State private var kidneyB      = ""
    @State private var kidneyLength = ""
    @State private var kidneyDepth  = ""

    // Irregular
    @State private var irregAvgWidth = ""
    @State private var irregLength   = ""
    @State private var irregDepth    = ""

    // Always compute in gallons first, then convert for display
    private var calculatedGallons: Double? {
        switch selectedShape {
        case "rectangle":
            guard let l = Double(rectLength), let w = Double(rectWidth),
                  let d = Double(rectDepth), l > 0, w > 0, d > 0 else { return nil }
            return l * w * d * 7.5
        case "circular":
            guard let ra = Double(circRA), let rb = Double(circRB),
                  let d = Double(circDepth), ra > 0, rb > 0, d > 0 else { return nil }
            return 3.14 * ra * rb * d * 7.5
        case "kidney":
            guard let a = Double(kidneyA), let b = Double(kidneyB),
                  let l = Double(kidneyLength), let d = Double(kidneyDepth),
                  a > 0, b > 0, l > 0, d > 0 else { return nil }
            return 0.45 * (a + b) * l * d * 7.5
        case "irregular":
            guard let aw = Double(irregAvgWidth), let l = Double(irregLength),
                  let d = Double(irregDepth), aw > 0, l > 0, d > 0 else { return nil }
            return aw * l * d * 7.5
        default:
            return nil
        }
    }

    private var displayedValue: String {
        guard let gal = calculatedGallons else { return "" }
        let val = unit == "liters" ? gal * 3.78541 : gal
        return String(format: "%.0f", val)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Drag handle
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 209/255, green: 213/255, blue: 219/255))
                        .frame(width: 40, height: 5)
                    Spacer()
                }
                .padding(.top, 8)

                // Title + close
                HStack {
                    Text("Volume Calculator")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(red: 17/255, green: 24/255, blue: 39/255))
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                            .frame(width: 32, height: 32)
                            .background(Color(red: 243/255, green: 244/255, blue: 246/255))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                // Shape selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("Shape")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        shapeButton(value: "rectangle", label: "Rectangle /\nSquare")
                        shapeButton(value: "circular",  label: "Circular /\nOval")
                        shapeButton(value: "kidney",    label: "Kidney")
                        shapeButton(value: "irregular", label: "Irregular")
                    }
                }

                // Dynamic dimension fields — appear once a shape is chosen
                if !selectedShape.isEmpty {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Dimensions")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

                        if selectedShape == "rectangle" {
                            CalcNumberField(label: "Length (ft)", value: $rectLength)
                            CalcNumberField(label: "Width (ft)", value: $rectWidth)
                            CalcNumberField(label: "Average Depth (ft)", value: $rectDepth)
                        } else if selectedShape == "circular" {
                            CalcNumberField(label: "Radius A (ft)", value: $circRA)
                            CalcNumberField(label: "Radius B (ft)", value: $circRB)
                            CalcNumberField(label: "Average Depth (ft)", value: $circDepth)
                        } else if selectedShape == "kidney" {
                            CalcNumberField(label: "Width A — first bulb (ft)", value: $kidneyA)
                            CalcNumberField(label: "Width B — second bulb (ft)", value: $kidneyB)
                            CalcNumberField(label: "Length (ft)", value: $kidneyLength)
                            CalcNumberField(label: "Average Depth (ft)", value: $kidneyDepth)
                        } else if selectedShape == "irregular" {
                            CalcNumberField(label: "Average Width (ft)", value: $irregAvgWidth)
                            CalcNumberField(label: "Length (ft)", value: $irregLength)
                            CalcNumberField(label: "Average Depth (ft)", value: $irregDepth)
                        }
                    }

                    // Result section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Estimated Volume")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))

                        // Gallons / Liters toggle
                        HStack(spacing: 0) {
                            ForEach([("gallons", "Gallons"), ("liters", "Liters")], id: \.0) { value, label in
                                Button { unit = value } label: {
                                    Text(label)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(
                                            unit == value
                                            ? .white
                                            : Color(red: 107/255, green: 114/255, blue: 128/255)
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 9)
                                        .background(
                                            Group {
                                                if unit == value {
                                                    LinearGradient(
                                                        colors: [
                                                            Color(red: 37/255, green: 99/255, blue: 235/255),
                                                            Color(red: 6/255, green: 182/255, blue: 212/255)
                                                        ],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                } else {
                                                    LinearGradient(
                                                        colors: [.clear, .clear],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                }
                                            }
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 9))
                                }
                                .buttonStyle(.plain)
                                .animation(.easeInOut(duration: 0.15), value: unit)
                            }
                        }
                        .padding(4)
                        .background(Color(red: 243/255, green: 244/255, blue: 246/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Read-only result box
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(displayedValue.isEmpty ? "—" : displayedValue)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(
                                    displayedValue.isEmpty
                                    ? Color(red: 209/255, green: 213/255, blue: 219/255)
                                    : Color(red: 17/255, green: 24/255, blue: 39/255)
                                )
                            Spacer()
                            Text(unit == "liters" ? "litres" : "gallons")
                                .font(.system(size: 15))
                                .foregroundStyle(Color(red: 107/255, green: 114/255, blue: 128/255))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(red: 249/255, green: 250/255, blue: 251/255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 209/255, green: 213/255, blue: 219/255), lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Use This Volume button
                    Button {
                        guard !displayedValue.isEmpty else { return }
                        onApply(displayedValue, unit)
                    } label: {
                        Text("Use This Volume")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(
                                displayedValue.isEmpty
                                ? Color(red: 156/255, green: 163/255, blue: 175/255)
                                : .white
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                Group {
                                    if displayedValue.isEmpty {
                                        LinearGradient(
                                            colors: [
                                                Color(red: 229/255, green: 231/255, blue: 235/255),
                                                Color(red: 229/255, green: 231/255, blue: 235/255)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [
                                                Color(red: 37/255, green: 99/255, blue: 235/255),
                                                Color(red: 6/255, green: 182/255, blue: 212/255)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .animation(.easeInOut(duration: 0.15), value: displayedValue.isEmpty)
                    }
                    .disabled(displayedValue.isEmpty)
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .padding(.bottom, 28)
        }
        .frame(maxHeight: screenHeight * 0.85)
        .background(Color.white)
        .clipShape(.rect(topLeadingRadius: 28, topTrailingRadius: 28))
    }

    private func shapeButton(value: String, label: String) -> some View {
        let isSelected = selectedShape == value
        return Button { selectedShape = value } label: {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    isSelected
                    ? Color(red: 37/255, green: 99/255, blue: 235/255)
                    : Color(red: 55/255, green: 65/255, blue: 81/255)
                )
                .frame(maxWidth: .infinity, minHeight: 56)
                .padding(.horizontal, 8)
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
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Reusable decimal input field for the calculator

struct CalcNumberField: View {
    let label: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))
            TextField("0", text: $value)
                .keyboardType(.decimalPad)
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
    }
}
