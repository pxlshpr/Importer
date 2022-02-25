import Foundation

public enum ImporterFoodUnit: Int16, CaseIterable {
    case g = 1
    case mL
    case serving
    
    public var description: String {
        switch self {
        case .g:
            return "g"
        case .mL:
            return "mL"
        case .serving:
            return "serving"
        }
    }
    
    init?(rawUnit: RawUnit) {
        switch rawUnit.unitId {
        case "g":
            self = .g
        case "mL":
            self = .mL
        case "serving":
            self = .serving
        default:
            return nil
        }
    }
}
