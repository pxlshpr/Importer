#if !os(macOS)
import Foundation

public struct RegEx {
    public static let Food = #""foods"[ ]*:[^{]*((.|\n)*),(.|\n)*"nutrition""#
}
#endif
