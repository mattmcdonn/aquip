import SwiftUI

/// Colour theming for the test flow. The pool flow uses a blue → cyan gradient,
/// while the spa flow uses a warm orange → amber gradient. Threading a `FlowTheme`
/// through the shared flow views keeps the styling consistent per water-body type.
struct FlowTheme {
    /// Primary header / button gradient (leading → trailing).
    let gradient: [Color]
    /// Gradient used for the numbered step badges (top → bottom).
    let badgeGradient: [Color]
    /// Solid accent colour used for text / icons.
    let accent: Color
    /// Soft accent background (e.g. product pills, selected states).
    let accentSoft: Color

    static let pool = FlowTheme(
        gradient: [
            Color(red: 37/255, green: 99/255, blue: 235/255),
            Color(red: 6/255, green: 182/255, blue: 212/255)
        ],
        badgeGradient: [
            Color(red: 59/255, green: 130/255, blue: 246/255),
            Color(red: 37/255, green: 99/255, blue: 235/255)
        ],
        accent: Color(red: 37/255, green: 99/255, blue: 235/255),
        accentSoft: Color(red: 219/255, green: 234/255, blue: 254/255)
    )

    static let spa = FlowTheme(
        gradient: [
            Color(red: 234/255, green: 88/255, blue: 12/255),
            Color(red: 245/255, green: 158/255, blue: 11/255)
        ],
        badgeGradient: [
            Color(red: 251/255, green: 146/255, blue: 60/255),
            Color(red: 234/255, green: 88/255, blue: 12/255)
        ],
        accent: Color(red: 234/255, green: 88/255, blue: 12/255),
        accentSoft: Color(red: 255/255, green: 237/255, blue: 213/255)
    )

    static func of(_ type: WaterTestType) -> FlowTheme {
        type == .spa ? .spa : .pool
    }

    var linearGradient: LinearGradient {
        LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing)
    }
}
