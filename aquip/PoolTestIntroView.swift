import SwiftUI
import Combine

// MARK: - Carousel data

struct CarouselSlide {
    let imageName: String
    let step: String
}

private let carouselSlides: [CarouselSlide] = [
    CarouselSlide(
        imageName: "aquip_test_tutorial_1",
        step: "Step 1: Collect a water sample from elbow-deep in your pool, away from returns and skimmers"
    ),
    CarouselSlide(
        imageName: "aquip_test_tutorial_2",
        step: "Step 2: Dip your test strip into the water sample for 2–3 seconds"
    ),
    CarouselSlide(
        imageName: "aquip_test_tutorial_3",
        step: "Step 3: Remove the strip and wait 15 seconds, then compare colors to the chart on the bottle"
    )
]

// MARK: - Carousel view

struct InstructionsCarouselView: View {
    @Binding var currentIndex: Int

    // Auto-play timer ticks every second
    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var lastManualSwipe: Date = .distantPast
    @State private var autoSeconds: Int = 0

    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $currentIndex) {
                ForEach(carouselSlides.indices, id: \.self) { index in
                    Image(carouselSlides[index].imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal, 4)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 320)
            // Detect manual swipe — resets the auto-play inactivity clock
            .simultaneousGesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { _ in
                        lastManualSwipe = Date()
                        autoSeconds = 0
                    }
            )
            .onReceive(ticker) { _ in
                let sinceSwipe = Date().timeIntervalSince(lastManualSwipe)
                // Resume auto-play only after 10s of inactivity
                guard sinceSwipe >= 10 || lastManualSwipe == .distantPast else { return }
                autoSeconds += 1
                if autoSeconds >= 4 {
                    autoSeconds = 0
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentIndex = (currentIndex + 1) % carouselSlides.count
                    }
                }
            }

            // Step description below carousel
            Text(carouselSlides[currentIndex].step)
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 55/255, green: 65/255, blue: 81/255))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .animation(.easeInOut(duration: 0.2), value: currentIndex)
        }
    }
}

// MARK: - Intro screen

struct PoolTestIntroView: View {
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var carouselIndex = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Blue gradient header
                VStack(alignment: .leading, spacing: 0) {
                    // Back button
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
                    .padding(.bottom, 14)

                    Text("Pool Water Testing")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Follow these steps to test your pool water")
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

                // Scrollable content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Use your water testing strips to get accurate readings")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color(red: 31/255, green: 41/255, blue: 55/255))

                        InstructionsCarouselView(currentIndex: $carouselIndex)
                    }
                    .padding(24)
                    .padding(.bottom, 110) // clears continue button + tab bar
                }
                .background(Color.white)
            }
            .background(Color.white)

            // Fixed continue button above tab bar
            VStack(spacing: 0) {
                Button(action: onContinue) {
                    Text("I Have My Test Results")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
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
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .padding(.bottom, 100) // above tab bar
            }
            .background(Color.white)
        }
    }
}
