import Foundation

enum VolumeUnit: CaseIterable, MeasurementUnit {

    case ml, l, cup, tsp, tbsp, floz, gallon, quart, pint
    
    var description: String {
        switch self {
        case .ml:
            return "mL"
        case .l:
            return "liters"
        case .cup:
            return "cup"
        case .tsp:
            return "tsp"
        case .tbsp:
            return "tbsp"
        case .floz:
            return "fl. oz."
        case .gallon:
            return "gallon"
        case .quart:
            return "quart"
        case .pint:
            return "pint"
        }
    }
    
    var regex: String {
        switch self {
        case .ml:
            return #"^(ml|mil)"#
        case .l:
            return #"^l"#
        case .cup:
            return #"^c"#
        case .tsp:
            return #"^(ts|tea)"#
        case .tbsp:
            return #"^(tb|tab)"#
        case .floz:
            return #"^(fl|oz)"#
        case .gallon:
            return #"^g"#
        case .quart:
            return #"^q"#
        case .pint:
            return #"^p"#
        }
    }
}
