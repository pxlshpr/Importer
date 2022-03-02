import Foundation

struct RawUnit: ImporterUnit {
    let unit: String
    let singular: String
    let plural: String
    
    init?(_ nutrientsString: String) {
        switch nutrientsString {
        case "g":
            unit = "g"
            singular = "g"
            plural = "g"
        case "mL":
            unit = "mL"
            singular = "mL"
            plural = "mL"
        case "serving":
            unit = "serving"
            singular = "serving"
            plural = "servings"
        default:
            return nil
        }
    }
    init(unit: String) {
        self.unit = unit
        self.singular = unit
        self.plural = unit
    }
    
    init(unit: String, plural: String) {
        self.unit = unit
        self.singular = unit
        self.plural = plural
    }

    init(unit: String, singular: String, plural: String) {
        self.unit = unit
        self.singular = singular
        self.plural = plural
    }
    
    var unitId: String {
        unit
    }
    var nameSingular: String {
        singular
    }
    var namePlural: String {
        plural
    }
    func unitDescription(forValue value: Double = 1) -> String {
        value > 1 ? plural : singular
    }
}

extension RawUnit: Equatable {
    static func ==(lhs: RawUnit, rhs: RawUnit) -> Bool {
        lhs.unitId == rhs.unitId
    }
}
