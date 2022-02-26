import Foundation
import PrepUnits

//extension String {
//    var parseServing(type: ServingType) ->
//}

//typealias weight = (ImporterWeightUnit)?
//typealias weightWithServing = (unit: ImporterWeightUnit, servingValue: Double, servingName: String)?
//typealias servingWithWeight = (name: String, value: Double, unit: ImporterWeightUnit)?
//typealias servingWithVolume = (name: String, value: Double, unit: VolumeUnit)?
//typealias volumeWithWeight = (volumeUnit: VolumeUnit?, volumeString: String, weight: Double, weightUnit: ImporterWeightUnit)?
//typealias weightWithVolume = (weightUnit: ImporterWeightUnit?, weightString: String, volume: Double, volumeUnit: VolumeUnit)?
//typealias volume = (VolumeUnit)?
//typealias parseVolumeWithServing = (unit: VolumeUnit, servingValue: Double, servingName: String)?
//typealias servingWithServing = (serving: String, constituentAmount: Double, constituentName: String)?

typealias ParsedWeight = (unit: ImporterWeightUnit?, amount: Double?, string: String?)
typealias ParsedVolume = (unit: VolumeUnit?, amount: Double?, string: String?)
typealias ParsedServing = (name: String, amount: Double?)

typealias ParseResult = (weight: ParsedWeight?, volume: ParsedVolume?, serving: ParsedServing?, servingSize: ParsedServing?)

extension ServingType {

    //MARK: - Weight
    static func weightUnit(of string: String) -> (weight: ParsedWeight?, placeholder: String?) {
        for unit in ImporterWeightUnit.allCases {
            if string.matchesRegex(unit.regex) {
                let weight: ParsedWeight = (unit, nil, nil)
                return (weight, nil)
            }
        }
        return (nil, nil)
    }
    
    static func parseWeightWithServing(_ string: String) -> (weight: ParsedWeight?, serving: ParsedServing?)? {
        var groups = string.capturedGroups(using: Rx.weightWithServingExtractor)
        var unit: String, servingAmount: String, servingName: String
        if groups.count < 4 {
            groups = string.capturedGroups(using: Rx.weightWithServingHavingSizeNumberExtractor)
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
        
        guard let servingAmountValue = servingAmount.doubleFromExtractedNumber, let weightUnit = weightUnit(of: unit).weight?.unit else {
            return nil
        }
        
        let weight: ParsedWeight = (weightUnit, nil, nil)
        let serving: ParsedServing = (servingName, servingAmountValue)
        return (weight, serving)
    }
    
    static func parseServingWithWeight(_ string: String) -> (serving: ParsedServing?, weight: ParsedWeight?)? {
        let groups = string.capturedGroups(using: Rx.servingWithWeightExtractor)
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
              let weightUnit = weightUnit(of: unit).weight?.unit else {
            return nil
        }
        
        let serving: ParsedServing = (name, amountValue)
        let weight: ParsedWeight = (weightUnit, nil, nil)
        return (serving, weight)
    }
    
    static func parseServingWithVolume(_ string: String) -> (serving: ParsedServing?, volume: ParsedVolume?)? {
        let groups = string.capturedGroups(using: Rx.servingWithVolumeExtractor)
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
              let volumeUnit = volumeUnit(of: unit).volume?.unit else {
            return nil
        }
        
        let serving: ParsedServing = (name, amountValue)
        let volume: ParsedVolume = (volumeUnit, nil, nil)
        return (serving, volume)
    }
    
    static func parseVolumeWithWeight(_ string: String) -> (volume: ParsedVolume?, weight: ParsedWeight?)? {
        let groups = string.capturedGroups(using: Rx.volumeWithWeightExtractor)
        guard groups.count > 2 else {
            return nil
        }
        var volume, amount, weight: String
        volume = groups[0].cleaned
        amount = groups[1]
        weight = groups[2]
        if groups.count == 4, groups[3].count > 0 {
            volume += " " + groups[3]
        }
        
        volume = volume.trimmingCharacters(in: .whitespaces)
        amount = amount.trimmingCharacters(in: .whitespaces)
        weight = weight.trimmingCharacters(in: .whitespaces)
        
        guard let amountValue = amount.doubleFromExtractedNumber,
              let weightUnit = weightUnit(of: weight).weight?.unit,
              let volumeUnit = volumeUnit(of: volume).volume?.unit
        else {
            return nil
        }
        
        let parsedVolume: ParsedVolume = (volumeUnit, nil, volume)
        let parsedWeight: ParsedWeight = (weightUnit, amountValue, nil)
        return (parsedVolume, parsedWeight)
    }
    
    static func parseWeightWithVolume(_ string: String) -> (weight: ParsedWeight?, volume: ParsedVolume?)? {
        let groups = string.capturedGroups(using: Rx.weightWithVolumeExtractor)
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
              let volumeUnit = volumeUnit(of: volume).volume?.unit,
              let weightUnit = weightUnit(of: weight).weight?.unit
        else {
            return nil
        }
        let parsedWeight: ParsedWeight = (weightUnit, nil, weight)
        let parsedVolume: ParsedVolume = (volumeUnit, amountValue, nil)
        return (parsedWeight, parsedVolume)
    }
    
    //MARK: - Volume
    
    static func volumeUnit(of string: String) -> (volume: ParsedVolume?, placeholder: String?) {
        for unit in VolumeUnit.allCases {
            if string.matchesRegex(unit.regex) {
                return ((unit, nil, nil), nil)
            }
        }
        return (nil, nil)
    }

    static func parseVolumeWithServing(_ string: String) -> (volume: ParsedVolume?, serving: ParsedServing?)? {
        var groups = string.capturedGroups(using: Rx.volumeWithServingExtractor)
        var unit: String, servingAmount: String, servingName: String
        if groups.count < 4 {
            groups = string.capturedGroups(using: Rx.volumeWithServingHavingSizeNumberExtractor)
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
        
        guard let servingAmountValue = servingAmount.doubleFromExtractedNumber, let volumeUnit = volumeUnit(of: unit).volume?.unit else {
            return nil
        }
        
        let volume: ParsedVolume = (volumeUnit, nil, nil)
        let serving: ParsedServing = (servingName, servingAmountValue)
        return (volume, serving)
    }
    
    static func parseServingWithServing(_ string: String) -> (serving: ParsedServing?, servingSize: ParsedServing?)? {
        let groups = string.capturedGroups(using: Rx.servingWithServingExtractor)
        guard groups.count > 2 else {
            return nil
        }
        var serving: String, constituentValue: String, constituentName: String
        serving = groups[0]
        constituentValue = groups[1]
        constituentName = groups[2]
        
        if constituentName.hasSuffix(" )") {
            constituentName.removeLast(2)
        }
        /// trims `taco wraps)` but leaves `leaf (large)` alone
        if constituentName.hasSuffix(")"), !constituentName.contains("(") {
            constituentName.removeLast(1)
        }
        /// `of pan` → `pan`
        if constituentName.hasPrefix("of ") {
            constituentName.removeFirst(3)
        }
        
        constituentName = constituentName.trimmingCharacters(in: .whitespaces)
        constituentValue = constituentValue.trimmingCharacters(in: .whitespaces)

        guard let constituentValue = constituentValue.doubleFromExtractedNumber else {
            return nil
        }
        
        let parsedServing: ParsedServing = (serving, nil)
        let parsedServingSize: ParsedServing = (constituentName, constituentValue)
        return (parsedServing, parsedServingSize)
    }
}
