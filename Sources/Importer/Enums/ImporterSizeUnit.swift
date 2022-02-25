import Foundation

public enum ImporterSizeUnit: Int16, CaseIterable {
    case g = 1
    case mL
    case serving
    case size
    
    public var description: String {
        switch self {
        case .g:
            return "g"
        case .mL:
            return "mL"
        case .serving:
            return "serving"
        case .size:
            return "size"
        }
    }
}
