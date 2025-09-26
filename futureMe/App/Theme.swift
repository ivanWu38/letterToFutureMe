import SwiftUI


struct NordicTheme {
    static let bg = Color(red: 0.92, green: 0.90, blue: 0.94)
    static let deep = Color(red: 0.13, green: 0.16, blue: 0.24)
    static let slate = Color(red: 0.43, green: 0.54, blue: 0.71)
    static let mauve = Color(red: 0.65, green: 0.60, blue: 0.75)
    static let brick = Color(red: 0.72, green: 0.30, blue: 0.28)
    static let cream = Color(red: 0.92, green: 0.83, blue: 0.80)
}


extension Font {
    static func nordicTitle() -> Font { .system(.largeTitle, design: .serif).weight(.bold) }
    static func nordicHeading() -> Font { .system(.title2, design: .serif).weight(.semibold) }
}
