import SwiftUI

/// Design tokens. Screens use these instead of magic numbers so the look can evolve in one place.
public enum Spacing {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 16
    public static let l: CGFloat = 24
    public static let xl: CGFloat = 32
}

public enum Radius {
    public static let chip: CGFloat = 12
    public static let card: CGFloat = 24
}

public extension Color {
    static let like = Color.green
    static let pass = Color.red
    static let warning = Color.orange
}
