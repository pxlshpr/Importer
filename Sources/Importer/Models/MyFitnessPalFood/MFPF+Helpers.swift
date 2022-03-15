import Foundation

public extension MFPFood {
    var firstType: ServingType? {
        sizes.sorted { $0.index < $1.index }.first?.type
    }
    
//    var firstSize: Size? {
//        sizes.first
//    }
    
    var secondSize: Size? {
        guard sizes.count > 1 else {
            return nil
        }
        return sizes[1]
    }
    
    var firstWeightSize: Size? {
        sizes.first(where: { $0.type == .weight })
    }
    
    var cleanedName: String {
        guard let name = name else {
            return ""
        }
        return name.cleaned
    }
    
    var cleanedBrand: String? {
        brand?.cleaned
    }
    
    /// returns the first match that contains a weight in the serving description so that we may determine the serving weight
    var servingsWithWeight: [Size]? {
        let servings = sizes.filter {
            $0.type == .servingWithWeight
//            $0.unit.matchesRegex(RegExServingWithWeight)
        }
        return servings.isEmpty ? nil : servings
    }
    func servingsWithoutSameUnit(of serving: Size) -> [Size]? {
        let servings = sizes.filter {
            guard $0 != serving else { return false }
            return !$0.matchesUnit(of: serving)
        }
        return servings.count > 0 ? servings : nil
    }

    func servingsWithSameUnit(of serving: Size) -> [Size]? {
        let servings = sizes.filter {
            guard $0 != serving else { return false }
            return $0.matchesUnit(of: serving)
        }
        return servings.count > 0 ? servings : nil
    }
    
    var hasWeightServing: Bool {
//        servingSizes.contains { $0.isWeightBased }
        sizes.contains { $0.isWeightBased }
    }
    
    var defaultMeasuredServing: Size? {
        sizes.first { $0.isWeightBased || $0.isVolumeBased }
    }
    
    var defaultServing: Size? {
        sizes.first(where: { $0.index == 0 })
    }
//
//    var containsWeightBasedSize: Bool {
//        sizes.contains(where: { $0.isWeightBased })
//    }
    
//    /// Returns the weight of 1x of this food OR 0 if it is not weight based
//    var baseWeight: Double {
//        //TODO: Write this
//        guard let size = sizes.first(where: { $0.isWeightBased }) else {
//            return 0
//        }
//        let parsed: ParseResult
//        switch size.type {
//        case .weight:
//            parsed = size.name.parsedWeight
//        case .weightWithVolume:
//            parsed = size.name.parsedWeightWithVolume
//        case .weightWithServing:
//            parsed = size.name.parsedWeightWithServing
//        case .servingWithWeight:
//            parsed = size.name.parsedServingWithWeight
//        default:
//            return 0
//        }
//        guard let weight = parsed.weight?.amount else {
//            return 0
//        }
//        return weight
//    }
}
