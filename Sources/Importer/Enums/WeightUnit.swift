import Foundation

enum WeightUnit: CaseIterable, MeasurementUnit {

    case g, kg, mg, oz, lb
    
    var regex: String {
        switch self {
        case .g:
            return #"^(g raw weight|gramm|gram|gr|gm|g)"#
        case .kg:
            return #"^kg"#
        case .mg:
            return #"^mg"#
        case .oz:
            return #"^(wt. oz|ounce|oz)"#
        case .lb:
            return #"(pound|lb)"#
        }
    }
}
