import Foundation
import PrepUnits

public extension String {
    func parsedServing(type: ServingType) -> ParseResult {
        ParseResult(self, type: type)
    }
    
    var parsedWeight: ParseResult { ParseResult(self, type: .weight) }
    var parsedVolume: ParseResult { ParseResult(self, type: .volume) }
    var parsedServing: ParseResult { ParseResult(self, type: .serving) }
    var parsedWeightWithServing: ParseResult { ParseResult(self, type: .weightWithServing) }
    var parsedServingWithWeight: ParseResult { ParseResult(self, type: .servingWithWeight) }
    var parsedServingWithVolume: ParseResult { ParseResult(self, type: .servingWithVolume) }
    var parsedVolumeWithWeight: ParseResult { ParseResult(self, type: .volumeWithWeight) }
    var parsedWeightWithVolume: ParseResult { ParseResult(self, type: .weightWithVolume) }
    var parsedVolumeWithServing: ParseResult { ParseResult(self, type: .volumeWithServing) }
    var parsedServingWithServing: ParseResult { ParseResult(self, type: .servingWithServing) }
}

//typealias weight = (WeightUnit)?
//typealias weightWithServing = (unit: WeightUnit, servingValue: Double, servingName: String)?
//typealias servingWithWeight = (name: String, value: Double, unit: WeightUnit)?
//typealias servingWithVolume = (name: String, value: Double, unit: VolumeUnit)?
//typealias volumeWithWeight = (volumeUnit: VolumeUnit?, volumeString: String, weight: Double, weightUnit: WeightUnit)?
//typealias weightWithVolume = (weightUnit: WeightUnit?, weightString: String, volume: Double, volumeUnit: VolumeUnit)?
//typealias volume = (VolumeUnit)?
//typealias parseVolumeWithServing = (unit: VolumeUnit, servingValue: Double, servingName: String)?
//typealias servingWithServing = (serving: String, constituentAmount: Double, constituentName: String)?

typealias ParsedWeight = (unit: WeightUnit?, amount: Double?, string: String?)
typealias ParsedVolume = (unit: VolumeUnit?, amount: Double?, string: String?)
typealias ParsedServing = (name: String, amount: Double?)

//typealias ParseResult = (weight: ParsedWeight?, volume: ParsedVolume?, serving: ParsedServing?, servingSize: ParsedServing?)

public struct ParseResult {
    public struct ParsedWeight {
        public let unit: WeightUnit?
        public let amount: Double?
        public let string: String?
        init(unit: WeightUnit? = nil, amount: Double? = nil, string: String? = nil) {
            self.unit = unit
            self.amount = amount
            self.string = string
        }
    }
    
    public struct ParsedVolume {
        public let unit: VolumeUnit?
        public let amount: Double?
        public let string: String?
        init(unit: VolumeUnit? = nil, amount: Double? = nil, string: String? = nil) {
            self.unit = unit
            self.amount = amount
            self.string = string
        }
    }
    
    public struct ParsedServing {
        public let name: String
        public let amount: Double?
        init(name: String, amount: Double? = nil) {
            self.name = name
            self.amount = amount
        }
    }
    
    public let weight: ParsedWeight?
    public let volume: ParsedVolume?
    public let serving: ParsedServing?
    public let servingSize: ParsedServing?

    init(weight: ParsedWeight? = nil, volume: ParsedVolume? = nil, serving: ParsedServing? = nil, servingSize: ParsedServing? = nil) {
        self.weight = weight
        self.volume = volume
        self.serving = serving
        self.servingSize = servingSize
    }
    
    init(_ name: String, type: ServingType) {
        var weight: ParsedWeight? = nil
        var volume: ParsedVolume? = nil
        var serving: ParsedServing? = nil
        var servingSize: ParsedServing? = nil
        
        switch type {
        case .weight:
            weight = Self.parseWeight(from: name)
            
        case .volume:
            volume = Self.parseVolume(from: name)
            
        case .serving:
            serving = Self.parseServing(from: name)
            
        case .servingWithWeight:
            let parsed = Self.parseServingWithWeight(from: name)
            serving = parsed?.serving
            weight = parsed?.weight
            
        case .servingWithVolume:
            let parsed = Self.parseServingWithVolume(from: name)
            serving = parsed?.serving
            volume = parsed?.volume
            
        case .weightWithServing:
            let parsed = Self.parseWeightWithServing(from: name)
            weight = parsed?.weight
            serving = parsed?.serving
            
        case .volumeWithServing:
            let parsed = Self.parseVolumeWithServing(from: name)
            volume = parsed?.volume
            serving = parsed?.serving
            
        case .servingWithServing:
            /// treat servings with a plain "serving" as the serving as a `serving` type
            if name.isServingOfPlainServing {
                serving = Self.parseServing(from: name)
            } else {
                let parsed = Self.parseServingWithServing(from: name)
                serving = parsed?.serving
                servingSize = parsed?.servingSize
            }
            
        case .volumeWithWeight:
            let parsed = Self.parseVolumeWithWeight(from: name)
            volume = parsed?.volume
            weight = parsed?.weight
            serving = parsed?.serving
            
        case .weightWithVolume:
            let parsed = Self.parseWeightWithVolume(from: name)
            weight = parsed?.weight
            volume = parsed?.volume
        
        case .unsupported:
            break
        }
        self.init(weight: weight, volume: volume, serving: serving, servingSize: servingSize)
    }
    
    static func parseWeight(from string: String) -> ParsedWeight? {
        for unit in WeightUnit.allCases {
            if string.matchesRegex(unit.regex) {
                return ParsedWeight(unit: unit)
            }
        }
        return nil
    }

    static func parseVolume(from string: String) -> ParsedVolume? {
        for unit in VolumeUnit.allCases {
            if string.matchesRegex(unit.regex) {
                return ParsedVolume(unit: unit)
            }
        }
        return nil
    }
    
    static func parseServing(from string: String) -> ParsedServing {
        /// edge case where we may have a serving of a serving where the servingSize is a plain serving
        /// e.g. `container (1 serving(s))`
        ///     in this case, we're only interested in the serving name—and not the serving size
        if string.servingType == .servingWithServing,
           string.isServingOfPlainServing,
           let servingName = string.parsedServingWithServing.serving?.name
        {
            return ParsedServing(name: servingName)
        } else {
            return ParsedServing(name: string)
        }
    }
    
    static func parseWeightWithServing(from string: String) -> (weight: ParsedWeight, serving: ParsedServing)? {
        var groups = string.capturedGroups(using: ServingType.Rx.weightWithServingExtractor)
        var unit: String, servingAmount: String, servingName: String
        if groups.count < 4 {
            groups = string.capturedGroups(using: ServingType.Rx.weightWithServingHavingSizeNumberExtractor)
            guard groups.count > 2 else {
                return nil
            }
            unit = groups[0]
            servingAmount = "1"
            servingName = groups[2]
            
        } else {
            unit = groups[0]
            if groups.count == 5 {
                servingAmount = groups[3]
                servingName = groups[4]
            } else {
                servingAmount = groups[2]
                servingName = groups[3]
            }
        }
        if servingName.hasPrefix("(") {
            servingName.removeFirst(1)
        }
        if servingName.hasSuffix(")") {
            servingName.removeLast(1)
        }
        
        servingAmount = servingAmount.trimmingCharacters(in: .whitespaces)
        servingName = servingName.trimmingCharacters(in: .whitespaces)
        
        guard let servingAmountValue = servingAmount.doubleFromExtractedNumber, let weightUnit = parseWeight(from: unit)?.unit else {
            return nil
        }
        
        let weight = ParsedWeight(unit: weightUnit)
        let serving = ParsedServing(name: servingName, amount: servingAmountValue)
        return (weight, serving)
    }

    static func parseServingWithWeight(from string: String) -> (serving: ParsedServing, weight: ParsedWeight)? {
        let groups = string.capturedGroups(using: ServingType.Rx.servingWithWeightExtractor)
        guard groups.count > 1 else {
            return nil
        }
        var name, amount, unit: String
        name = groups[0]
        amount = groups[1]
        unit = groups[2]

        if name.hasSuffix("(") {
            name.removeLast(1)
        }
        if name.hasSuffix("-") {
            name.removeLast(1)
        }
        name = name.trimmingCharacters(in: .whitespaces)
        amount = amount.trimmingCharacters(in: .whitespaces)
        unit = unit.trimmingCharacters(in: .whitespaces)
        
        guard let amountValue = amount.doubleFromExtractedNumber,
              let weightUnit = parseWeight(from: unit)?.unit else {
            return nil
        }
        
        let serving = ParsedServing(name: name)
        let weight = ParsedWeight(unit: weightUnit, amount: amountValue)
        return (serving, weight)
    }
    
    static func parseServingWithVolume(from string: String) -> (serving: ParsedServing, volume: ParsedVolume)? {
        let groups = string.capturedGroups(using: ServingType.Rx.servingWithVolumeExtractor)
        guard groups.count > 1 else {
            return nil
        }
        var name, amount, unit: String
        name = groups[0]
        if groups.count == 4 {
            /// check if mixedNumber first (in which case take the first match)
            if string.containsMixedNumber {
                amount = groups[1]
            } else {
                amount = groups[2]
            }
            unit = groups[3]
        } else {
            amount = groups[1]
            unit = groups[2]
        }

        if name.hasSuffix("(") {
            name.removeLast(1)
        }
        if name.hasSuffix("-") {
            name.removeLast(1)
        }
        name = name.trimmingCharacters(in: .whitespaces)
        amount = amount.trimmingCharacters(in: .whitespaces)
        unit = unit.trimmingCharacters(in: .whitespaces)

        guard let amountValue = amount.doubleFromExtractedNumber,
              let volumeUnit = parseVolume(from: unit)?.unit else {
            return nil
        }
        
        let serving = ParsedServing(name: name)
        let volume = ParsedVolume(unit: volumeUnit, amount: amountValue)
        return (serving, volume)
    }

    static func parseVolumeWithWeight(from string: String) -> (volume: ParsedVolume?, weight: ParsedWeight?, serving: ParsedServing?)? {
        let groups = string.capturedGroups(using: ServingType.Rx.volumeWithWeightExtractor)
        guard groups.count > 2 else {
            return nil
        }
        var volume, amount, weight, name: String
        volume = groups[0].cleaned
        amount = groups[2]
        weight = groups[3]
        name = ""
        if groups.count == 5 {
            if groups[4].isEmpty {
                if !groups[1].trimmingCharacters(in: .whitespaces).isEmpty {
                    name = groups[1]
                }
            } else {
                name = groups[4]
            }
        }
        
        volume = volume.trimmingCharacters(in: .whitespaces)
        amount = amount.trimmingCharacters(in: .whitespaces)
        weight = weight.trimmingCharacters(in: .whitespaces)
        name = name.trimmingCharacters(in: .whitespaces)
        
        guard let amountValue = amount.doubleFromExtractedNumber,
              let weightUnit = parseWeight(from: weight)?.unit,
              let volumeUnit = parseVolume(from: volume)?.unit
        else {
            return nil
        }
        
        let parsedVolume = ParsedVolume(unit: volumeUnit, string: volume)
        let parsedWeight = ParsedWeight(unit: weightUnit, amount: amountValue)
        let parsedServing = !name.isEmpty ? ParsedServing(name: name) : nil
        return (parsedVolume, parsedWeight, parsedServing)
    }
    
    static func parseWeightWithVolume(from string: String) -> (weight: ParsedWeight?, volume: ParsedVolume?)? {
        let groups = string.capturedGroups(using: ServingType.Rx.weightWithVolumeExtractor)
        guard groups.count > 2 else {
            return nil
        }
        var volume, amount, weight: String
        weight = groups[0]
        amount = groups[1]
        volume = groups[2]
        if groups.count == 4, groups[3].count > 0 {
            weight += " " + groups[3]
        }

        weight = weight.trimmingCharacters(in: .whitespaces)
        amount = amount.trimmingCharacters(in: .whitespaces)
        volume = volume.trimmingCharacters(in: .whitespaces)
        
        guard let amountValue = amount.doubleFromExtractedNumber,
              let volumeUnit = parseVolume(from: volume)?.unit,
              let weightUnit = parseWeight(from: weight)?.unit
        else {
            return nil
        }
        let parsedWeight = ParsedWeight(unit: weightUnit, string: weight)
        let parsedVolume = ParsedVolume(unit: volumeUnit, amount: amountValue)
        return (parsedWeight, parsedVolume)
    }
    
    static func parseVolumeWithServing_leacy(from string: String) -> (volume: ParsedVolume?, serving: ParsedServing?)? {
        var groups = string.capturedGroups(using: ServingType.Rx.volumeWithServingExtractor_legacy)
        var unit: String, servingAmount: String, servingName: String
        if groups.count < 4 {
            groups = string.capturedGroups(using: ServingType.Rx.volumeWithServingHavingSizeNumberExtractor)
            guard groups.count > 2 else {
                return nil
            }
            unit = groups[0]
            servingAmount = "1"
            servingName = groups[2]
            
        } else {
            unit = groups[0]
            if groups.count == 5 {
                servingAmount = groups[3]
                servingName = groups[4]
            } else {
                servingAmount = groups[2]
                servingName = groups[3]
            }
        }
        if servingName.hasPrefix("(") {
            servingName.removeFirst(1)
        }
        if servingName.hasSuffix(")") {
            servingName.removeLast(1)
        }
        
        servingAmount = servingAmount.trimmingCharacters(in: .whitespaces)
        servingName = servingName.trimmingCharacters(in: .whitespaces)
        
        guard let servingAmountValue = servingAmount.doubleFromExtractedNumber,
              let volumeUnit = parseVolume(from: unit)?.unit
        else {
            return nil
        }
        
        let volume = ParsedVolume(unit: volumeUnit)
        let serving = ParsedServing(name: servingName, amount: servingAmountValue)
        return (volume, serving)
    }
    
    static func parseVolumeWithServing(from string: String) -> (volume: ParsedVolume?, serving: ParsedServing?)? {
        let groups = string.capturedGroups(using: ServingType.Rx.volumeWithServingExtractor)
        
        guard groups.count == 3 else {
            return nil
        }
        
        let unit = groups[0]
        var servingName = groups[2]
        
        if servingName.hasPrefix("(") {
            servingName.removeFirst(1)
        }
        if servingName.hasSuffix(")") {
            servingName.removeLast(1)
        }
        
        servingName = servingName.trimmingCharacters(in: .whitespaces)
        
        guard let volumeUnit = parseVolume(from: unit)?.unit,
              !servingName.isEmpty
        else {
            return nil
        }
        
        let volume = ParsedVolume(unit: volumeUnit)
        let serving = ParsedServing(name: servingName)
        return (volume, serving)
    }
    
    static func parseServingWithServing(from string: String) -> (serving: ParsedServing?, servingSize: ParsedServing?)? {
        let groups = string.capturedGroups(using: ServingType.Rx.servingWithServingExtractor)
        guard groups.count > 2 else {
            return nil
        }
        var serving: String, servingSizeValue: String, servingSizeName: String
        serving = groups[0]
        servingSizeValue = groups[1]
        servingSizeName = groups[2]
        
        if servingSizeName.hasSuffix(" )") {
            servingSizeName.removeLast(2)
        }
        /// trims `taco wraps)` but leaves `leaf (large)` alone
        if servingSizeName.hasSuffix(")"), !servingSizeName.contains("(") {
            servingSizeName.removeLast(1)
        }
        /// `of pan` → `pan`
        if servingSizeName.hasPrefix("of ") {
            servingSizeName.removeFirst(3)
        }
        
        servingSizeName = servingSizeName.trimmingCharacters(in: .whitespaces)
        servingSizeValue = servingSizeValue.trimmingCharacters(in: .whitespaces)

        guard let constituentValue = servingSizeValue.doubleFromExtractedNumber else {
            return nil
        }
        
        let parsedServing = ParsedServing(name: serving)
        let parsedServingSize = ParsedServing(name: servingSizeName, amount: constituentValue)
        return (parsedServing, parsedServingSize)
    }
}

//extension ServingType {
//
//    //MARK: - Weight
//    static func weightUnit(of string: String) -> (weight: ParsedWeight?, placeholder: String?) {
//        for unit in WeightUnit.allCases {
//            if string.matchesRegex(unit.regex) {
//                let weight: ParsedWeight = (unit, nil, nil)
//                return (weight, nil)
//            }
//        }
//        return (nil, nil)
//    }
//
//    static func parseWeightWithServing(_ string: String) -> (weight: ParsedWeight?, serving: ParsedServing?)? {
//        var groups = string.capturedGroups(using: Rx.weightWithServingExtractor)
//        var unit: String, servingAmount: String, servingName: String
//        if groups.count < 4 {
//            groups = string.capturedGroups(using: Rx.weightWithServingHavingSizeNumberExtractor)
//            guard groups.count > 2 else {
//                return nil
//            }
//            unit = groups[0]
//            servingAmount = "1"
//            servingName = groups[2]
//
//        } else {
//            unit = groups[0]
//            if groups.count == 5 {
//                servingAmount = groups[3]
//                servingName = groups[4]
//            } else {
//                servingAmount = groups[2]
//                servingName = groups[3]
//            }
//        }
//        if servingName.hasPrefix("(") {
//            servingName.removeFirst(1)
//        }
//        if servingName.hasSuffix(")") {
//            servingName.removeLast(1)
//        }
//
//        servingAmount = servingAmount.trimmingCharacters(in: .whitespaces)
//        servingName = servingName.trimmingCharacters(in: .whitespaces)
//
//        guard let servingAmountValue = servingAmount.doubleFromExtractedNumber, let weightUnit = weightUnit(of: unit).weight?.unit else {
//            return nil
//        }
//
//        let weight: ParsedWeight = (weightUnit, nil, nil)
//        let serving: ParsedServing = (servingName, servingAmountValue)
//        return (weight, serving)
//    }
//
//    static func parseServingWithWeight(_ string: String) -> (serving: ParsedServing?, weight: ParsedWeight?)? {
//        let groups = string.capturedGroups(using: Rx.servingWithWeightExtractor)
//        guard groups.count > 1 else {
//            return nil
//        }
//        var name, amount, unit: String
//        name = groups[0]
//        amount = groups[1]
//        unit = groups[2]
//
//        if name.hasSuffix("(") {
//            name.removeLast(1)
//        }
//        if name.hasSuffix("-") {
//            name.removeLast(1)
//        }
//        name = name.trimmingCharacters(in: .whitespaces)
//        amount = amount.trimmingCharacters(in: .whitespaces)
//        unit = unit.trimmingCharacters(in: .whitespaces)
//
//        guard let amountValue = amount.doubleFromExtractedNumber,
//              let weightUnit = weightUnit(of: unit).weight?.unit else {
//            return nil
//        }
//
//        let serving: ParsedServing = (name, amountValue)
//        let weight: ParsedWeight = (weightUnit, nil, nil)
//        return (serving, weight)
//    }
//
//    static func parseServingWithVolume(_ string: String) -> (serving: ParsedServing?, volume: ParsedVolume?)? {
//        let groups = string.capturedGroups(using: Rx.servingWithVolumeExtractor)
//        guard groups.count > 1 else {
//            return nil
//        }
//        var name, amount, unit: String
//        name = groups[0]
//        if groups.count == 4 {
//            /// check if mixedNumber first (in which case take the first match)
//            if string.containsMixedNumber {
//                amount = groups[1]
//            } else {
//                amount = groups[2]
//            }
//            unit = groups[3]
//        } else {
//            amount = groups[1]
//            unit = groups[2]
//        }
//
//        if name.hasSuffix("(") {
//            name.removeLast(1)
//        }
//        if name.hasSuffix("-") {
//            name.removeLast(1)
//        }
//        name = name.trimmingCharacters(in: .whitespaces)
//        amount = amount.trimmingCharacters(in: .whitespaces)
//        unit = unit.trimmingCharacters(in: .whitespaces)
//
//        guard let amountValue = amount.doubleFromExtractedNumber,
//              let volumeUnit = volumeUnit(of: unit).volume?.unit else {
//            return nil
//        }
//
//        let serving: ParsedServing = (name, amountValue)
//        let volume: ParsedVolume = (volumeUnit, nil, nil)
//        return (serving, volume)
//    }
//
//    static func parseVolumeWithWeight(_ string: String) -> (volume: ParsedVolume?, weight: ParsedWeight?)? {
//        let groups = string.capturedGroups(using: Rx.volumeWithWeightExtractor)
//        guard groups.count > 2 else {
//            return nil
//        }
//        var volume, amount, weight: String
//        volume = groups[0].cleaned
//        amount = groups[1]
//        weight = groups[2]
//        if groups.count == 4, groups[3].count > 0 {
//            volume += " " + groups[3]
//        }
//
//        volume = volume.trimmingCharacters(in: .whitespaces)
//        amount = amount.trimmingCharacters(in: .whitespaces)
//        weight = weight.trimmingCharacters(in: .whitespaces)
//
//        guard let amountValue = amount.doubleFromExtractedNumber,
//              let weightUnit = weightUnit(of: weight).weight?.unit,
//              let volumeUnit = volumeUnit(of: volume).volume?.unit
//        else {
//            return nil
//        }
//
//        let parsedVolume: ParsedVolume = (volumeUnit, nil, volume)
//        let parsedWeight: ParsedWeight = (weightUnit, amountValue, nil)
//        return (parsedVolume, parsedWeight)
//    }
//
//    static func parseWeightWithVolume(_ string: String) -> (weight: ParsedWeight?, volume: ParsedVolume?)? {
//        let groups = string.capturedGroups(using: Rx.weightWithVolumeExtractor)
//        guard groups.count > 2 else {
//            return nil
//        }
//        var volume, amount, weight: String
//        weight = groups[0]
//        amount = groups[1]
//        volume = groups[2]
//        if groups.count == 4, groups[3].count > 0 {
//            weight += " " + groups[3]
//        }
//
//        weight = weight.trimmingCharacters(in: .whitespaces)
//        amount = amount.trimmingCharacters(in: .whitespaces)
//        volume = volume.trimmingCharacters(in: .whitespaces)
//
//        guard let amountValue = amount.doubleFromExtractedNumber,
//              let volumeUnit = volumeUnit(of: volume).volume?.unit,
//              let weightUnit = weightUnit(of: weight).weight?.unit
//        else {
//            return nil
//        }
//        let parsedWeight: ParsedWeight = (weightUnit, nil, weight)
//        let parsedVolume: ParsedVolume = (volumeUnit, amountValue, nil)
//        return (parsedWeight, parsedVolume)
//    }
//
//    //MARK: - Volume
//
//    static func volumeUnit(of string: String) -> (volume: ParsedVolume?, placeholder: String?) {
//        for unit in VolumeUnit.allCases {
//            if string.matchesRegex(unit.regex) {
//                return ((unit, nil, nil), nil)
//            }
//        }
//        return (nil, nil)
//    }
//
//    static func parseVolumeWithServing(_ string: String) -> (volume: ParsedVolume?, serving: ParsedServing?)? {
//        var groups = string.capturedGroups(using: Rx.volumeWithServingExtractor)
//        var unit: String, servingAmount: String, servingName: String
//        if groups.count < 4 {
//            groups = string.capturedGroups(using: Rx.volumeWithServingHavingSizeNumberExtractor)
//            guard groups.count > 2 else {
//                return nil
//            }
//            unit = groups[0]
//            servingAmount = "1"
//            servingName = groups[2]
//
//        } else {
//            unit = groups[0]
//            if groups.count == 5 {
//                servingAmount = groups[3]
//                servingName = groups[4]
//            } else {
//                servingAmount = groups[2]
//                servingName = groups[3]
//            }
//        }
//        if servingName.hasPrefix("(") {
//            servingName.removeFirst(1)
//        }
//        if servingName.hasSuffix(")") {
//            servingName.removeLast(1)
//        }
//
//        servingAmount = servingAmount.trimmingCharacters(in: .whitespaces)
//        servingName = servingName.trimmingCharacters(in: .whitespaces)
//
//        guard let servingAmountValue = servingAmount.doubleFromExtractedNumber, let volumeUnit = volumeUnit(of: unit).volume?.unit else {
//            return nil
//        }
//
//        let volume: ParsedVolume = (volumeUnit, nil, nil)
//        let serving: ParsedServing = (servingName, servingAmountValue)
//        return (volume, serving)
//    }
//
//    static func parseServingWithServing(_ string: String) -> (serving: ParsedServing?, servingSize: ParsedServing?)? {
//        let groups = string.capturedGroups(using: Rx.servingWithServingExtractor)
//        guard groups.count > 2 else {
//            return nil
//        }
//        var serving: String, constituentValue: String, constituentName: String
//        serving = groups[0]
//        constituentValue = groups[1]
//        constituentName = groups[2]
//
//        if constituentName.hasSuffix(" )") {
//            constituentName.removeLast(2)
//        }
//        /// trims `taco wraps)` but leaves `leaf (large)` alone
//        if constituentName.hasSuffix(")"), !constituentName.contains("(") {
//            constituentName.removeLast(1)
//        }
//        /// `of pan` → `pan`
//        if constituentName.hasPrefix("of ") {
//            constituentName.removeFirst(3)
//        }
//
//        constituentName = constituentName.trimmingCharacters(in: .whitespaces)
//        constituentValue = constituentValue.trimmingCharacters(in: .whitespaces)
//
//        guard let constituentValue = constituentValue.doubleFromExtractedNumber else {
//            return nil
//        }
//
//        let parsedServing: ParsedServing = (serving, nil)
//        let parsedServingSize: ParsedServing = (constituentName, constituentValue)
//        return (parsedServing, parsedServingSize)
//    }
//}
