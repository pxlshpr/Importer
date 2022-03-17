import Foundation
import PrepUnits

extension MFPFood {
    public struct Size: Equatable {
        public let name: String
        public let value: Double
        public let multiplier: Double
        public let index: Int
        
        public static func ==(lhs: Size, rhs: Size) -> Bool {
            lhs.name == rhs.name
            && lhs.value == rhs.value
            && lhs.multiplier == rhs.multiplier
            && lhs.index == rhs.index
        }
    }
}

extension MFPFood.Size {
    
    var parsed: ParseResult? {
        switch type {
        case .weight:
            return name.parsedWeight
        case .weightWithServing:
            return name.parsedWeightWithServing
        case .weightWithVolume:
            return name.parsedWeightWithVolume
        case .volume:
            return name.parsedVolume
        case .volumeWithServing:
            return name.parsedVolumeWithServing
        case .volumeWithWeight:
            return name.parsedVolumeWithWeight
        case .serving:
            return name.parsedServing
        case .servingWithServing:
            return name.parsedServingWithServing
        case .servingWithVolume:
            return name.parsedServingWithVolume
        case .servingWithWeight:
            return name.parsedServingWithWeight
        default:
            return nil
        }
    }
    
//    var weightAmount: Double? {
//        parsed?.weight?.amount
//    }
    
    var weightUnit: WeightUnit? {
        parsed?.weight?.unit
    }
    
    var weightConvertedForUnits: (amount: Double, unit: WeightUnit)? {
        let amount = trueValue
        guard let unit = weightUnit else {
            return nil
        }
        switch unit {
        case .g:
            if amount > 1000 {
                return (amount/1000.0, .kg)
            } else if amount < 1 {
                return (amount*1000.0, .mg)
            } else {
                return (amount, .g)
            }
        case .kg:
            if amount < 0.001 {
                return (amount*1_000_000.0, .mg)
            } else if amount < 1 {
                return (amount*1000.0, .g)
            } else {
                return (amount, .kg)
            }
        case .oz:
            if amount > 16 {
                return (amount/16.0, .lb)
            } else {
                return (amount, .oz)
            }
        case .lb:
            if amount < 1 {
                return (amount/0.0625, .oz)
            } else {
                return (amount, .lb)
            }
        case .mg:
            if amount > 1000000 {
                return (amount/1000000, .kg)
            } else if amount > 1000 {
                return (amount/1000, .g)
            } else {
                return (amount, .mg)
            }
        }
    }
    
    var volumeUnit: VolumeUnit? {
        parsed?.volume?.unit
//        name.parsedServing(type: type).volume?.unit
    }
    
    
}

extension MFPFood.Size {
    /// Returns the `value` multiplied by the `multiplier`
    var trueValue: Double {
        guard multiplier > 0 else { return 0 }
        return value / multiplier
    }
}

public extension MFPFood.Size {
    var processedSize: ProcessedSize {
        ProcessedSize(servingSize: self)
    }
    
    func matchesUnit(of serving: MFPFood.Size) -> Bool {
        let unit1 = name.lowercased()
        let unit2 = serving.name.lowercased()
        return unit1 == unit2
            || unit1 == "of \(unit2)"
            || unit2 == "of \(unit1)"
    }
    
    var formattedName: String {
        if name.lowercased().hasPrefix("of ") {
            return name.replacingOccurrences(of: "of ", with: "").capitalized
        } else {
            return name.capitalized
        }
    }
}

extension String {
    var isPlainServing: Bool {
        let strings = ["serving", "servings", "serving(s)"]
        for string in strings {
            if self.lowercased() == string
                || self.lowercased() == "\(string))" /// special case for when we may have a serving of serving with the plain serving size (e.g. container(x serving(s))—in which case it's extracted with the last bracket
            {
                return true
            }
        }
        return false
    }
    
    var servingType: ServingType {
        guard !isPlainServing else {
            return .unsupported
        }
        
        for type in ServingType.allCases {
            guard !(type == .servingWithServing && isServingOfPlainServing) else {
                return .serving
            }
            if matchesRegex(type.regex) {
                return type
            }
        }
        
        /// default to `serving` type so we can actually use it
        return .serving
    }
    
    /// returns true if its a type of `servingWithServing` where the `servingSize` is a plain serving (ie. "serving", "servings", or "serving(s)")
    var isServingOfPlainServing: Bool {
        guard let servingSizeName = self.parsedServingWithServing.servingSize?.name else {
            return false
        }
        return servingSizeName.isPlainServing
    }
}

public extension MFPFood.Size {
    
//    /// returns true if its a type of `servingWithServing` where the `servingSize` is a plain serving (ie. "serving", "servings", or "serving(s)")
//    var isServingOfPlainServing: Bool {
//        guard let servingSizeName = self.name.parsedServingWithServing.servingSize?.name else {
//            return false
//        }
//        return servingSizeName.isPlainServing
//    }
    
    var type: ServingType {
        name.servingType
//        guard !name.isPlainServing else {
//            return .unsupported
//        }
//
//        for type in ServingType.allCases {
//            guard !(type == .servingWithServing && isServingOfPlainServing) else {
//                return .serving
//            }
//            if name.matchesRegex(type.regex) {
//                return type
//            }
//        }
//
//        /// default to `serving` type so we can actually use it
//        return .serving
    }
    
    var isWeightBased: Bool {
        type.isWeightBased
    }
    
    var isVolumeBased: Bool {
        type.isVolumeBased
    }

    /// e.g. `cups, shredded`
    var isDescriptiveCups: Bool {
        let regex = #"^(?=^(?=^c)(?!^c(up)?s?$).*$)(?!^cup\(s\)$).*$"#
//        let regex = #"^(?=^(?=^c)(?!^c(up)?s?$).*$)(?!^cup\(s\)$)(?!^cup[ ]?\(?\#(ServingType.Rx.number)+\#(ServingType.Rx.weightUnits).*$).*$"#
        return self.name.matchesRegex(regex)
    }

//
//    var isVolumeBased: Bool {
//        isRawVolume || isServingWithVolume
//    }
//
//    var isRawWeight: Bool {
//        return unit.matchesRegex(rxWeight, caseInsensitive: true)
//    }
//
//    var isServingWithWeight: Bool {
//        return !isRawWeight
//        && !isRawVolume
//        && !isServingWithVolume
//        && unit.matchesRegex(RegExServingWithWeight, caseInsensitive: true)
//    }
//
//    //TODO: write for volume as well
//
//    var isRawVolume: Bool {
//        let regex = RegExRawVolume
//        /// make sure it's not a raw weight to ensure we don't accidentally capture the l's in 'lbs'
//        return !isRawWeight && unit.matchesRegex(regex, caseInsensitive: true)
//    }
//
//    var isServingWithVolume: Bool {
//        let regex = RegExServingWithVolume
//        return !isRawWeight && !isRawVolume && unit.matchesRegex(regex, caseInsensitive: true)
//    }
//
//    var isServingWithoutWeightOrVolume: Bool {
//        !isRawWeight && !isRawVolume && !isServingWithWeight && !isServingWithVolume
//    }
}

/**
 Start with a recognized volume unit, followed by either
 - a space
 - an 's' (pluralized), as long as its followed by:
    - a space
    - end of the string ($)
    - an open bracket
 - end of the string ($)
 - an open bracket
*/
//TODO: Open brackets possibly indicate Volume with Serving so we may want to remove those

//let RegExServingWithWeight_ = #"\(*[ ]*([0-9,.]*[ ]*(g|G|grams|Grams|GRAMS|gs|Gs|GS|oz|Oz|OZ)[^0-9]*\)*)$"#
//let RegExServingWithWeightValues = #"\(*[ ]*([0-9,.]*)[ ]*(g|G|grams|Grams|GRAMS|gs|Gs|GS|oz|Oz|OZ)[^0-9]*\)*$"#


//let rxWeight = #"^(wt. oz|ounce|pound|gram|kg|mg|gr|g|oz|lb)\(?s?\)?$"#
//let RegExRawVolume = #"^(fluid ounce|tablespoon|milliliter|millilitre|mililiter|mililitre|teaspoon|gallon|fl. oz.|oz. fl.|oz fl|fl oz|litre|quart|pint|tbsp|cup, [A-Za-z]*|tbs.|tbs|cup|tsp|ml|l)( |s( |$|\()|$|\()"#
//let RegExServingWithVolume = #"(^|[ ^A-Za-z])(fluid ounce|tablespoon|milliliter|millilitre|mililiter|mililitre|teaspoon|gallon|fl. oz.|oz. fl.|oz fl|fl oz|litre|quart|pint|tbsp|tbs|cup|tsp|ml|l)( |s( |$|\()|$|\()([ ]*|$)"#
//let RegExServingWithWeight = #"^[^0-9]*[0-9.,]*[ ]*(ounce|pound|gram|kg|mg|oz|lb|g)\(?s?\)?([ ]*|$)"#
//


extension MFPFood.Size: CustomStringConvertible {
    
    public var typeDescription: String {
        type.description
    }
    
    public var description: String {
        return "" +
        stringDescription(label: "Unit", string: name, tabs: 2) +
        valueDescription(label: "Value", value: value, unit: "", tabs: 2) +
        valueDescription(label: "Multiplier", value: multiplier, unit: "x", tabs: 2) +
        integerDescription(label: "Index", integer: index, unit: "", tabs: 2) +
        stringDescription(label: "Type", string: typeDescription, tabs: 2) +
        "\n"
    }
    
    var cleanedName: String {
        var cleanedName = name
        /// deals with names that may be like → 'of pan'
        if cleanedName.hasPrefix("of ") {
            cleanedName.removeFirst(3)
        }
        return cleanedName.cleaned
    }
}

extension MFPFood.Size {
    
    var density: Density? {
        if type == .volumeWithWeight {
            let parsed = name.parsedVolumeWithWeight
            guard let volumeUnit = parsed.volume?.unit,
                  let weightAmount = parsed.weight?.amount,
                  let weightUnit = parsed.weight?.unit
            else {
                return nil
            }
            let volume = processedSize.ml(for: value, unit: volumeUnit)
            let weight = processedSize.g(for: weightAmount, unit: weightUnit)
            return Density(volumeAmount: volume, volumeUnit: .mL, weightAmount: weight, weightUnit: .g)
        }
        
        if type == .weightWithVolume {
            let parsed = name.parsedWeightWithVolume
            guard let weightUnit = parsed.weight?.unit,
                  let volumeAmount = parsed.volume?.amount,
                  let volumeUnit = parsed.volume?.unit
            else {
                return nil
            }
            let weight = processedSize.g(for: value, unit: weightUnit)
            let volume = processedSize.ml(for: volumeAmount, unit: volumeUnit)
            return Density(volumeAmount: volume, volumeUnit: .mL, weightAmount: weight, weightUnit: .g)
        }

        return nil
    }
}

