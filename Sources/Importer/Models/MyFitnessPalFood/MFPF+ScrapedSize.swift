import Foundation
import PrepUnits

extension MyFitnessPalFood {
    public struct ScrapedSize: Equatable {
        public let name: String
        public let value: Double
        public let multiplier: Double
        public let index: Int
        
        public static func ==(lhs: ScrapedSize, rhs: ScrapedSize) -> Bool {
            lhs.name == rhs.name
            && lhs.value == rhs.value
            && lhs.multiplier == rhs.multiplier
            && lhs.index == rhs.index
        }
    }
}

public extension MyFitnessPalFood.ScrapedSize {
    var processedSize: ProcessedSize {
        ProcessedSize(servingSize: self)
    }
    
    func matchesUnit(of serving: MyFitnessPalFood.ScrapedSize) -> Bool {
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

extension MyFitnessPalFood.ScrapedSize {
    
    var type: ServingType {
        for type in ServingType.allCases {
            if name.matchesRegex(type.regex) {
                return type
            }
        }
        /// default to `serving` type so we can actually use it
        return .serving
//        return .unsupported
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


extension MyFitnessPalFood.ScrapedSize: CustomStringConvertible {
    
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

extension MyFitnessPalFood.ScrapedSize {
    
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
            return Density(volume: volume, weight: weight)
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
            return Density(volume: volume, weight: weight)
        }

        return nil
    }
}

extension MyFitnessPalFood.ScrapedSize {
    var volumeUnit: VolumeUnit? {
        name.parsedServing(type: type).volume?.unit
    }
}
