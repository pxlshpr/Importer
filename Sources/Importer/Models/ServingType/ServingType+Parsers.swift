import Foundation

extension ServingType {

    //MARK: - Weight
    static func weightUnit(of string: String) -> WeightUnit? {
        for unit in WeightUnit.allCases {
            if string.matchesRegex(unit.regex, caseInsensitive: true) {
                return unit
            }
        }
        return nil
    }
    
    static func parseWeightWithServing(_ string: String) -> (unit: WeightUnit, servingValue: Double, servingName: String)? {
        var groups = string.extractCapturedGroups(using: Rx.weightWithServingExtractor)
        var unit: String, servingAmount: String, servingName: String
        if groups.count < 4 {
            groups = string.extractCapturedGroups(using: Rx.weightWithServingHavingSizeNumberExtractor)
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
        
        guard let servingAmountValue = servingAmount.doubleFromExtractedNumber, let weightUnit = weightUnit(of: unit) else {
            return nil
        }
        
        return (weightUnit, servingAmountValue, servingName)
    }
    
    static func parseServingWithWeight(_ string: String) -> (name: String, value: Double, unit: WeightUnit)? {
        let groups = string.extractCapturedGroups(using: Rx.servingWithWeightExtractor)
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
                let weightUnit = weightUnit(of: unit) else {
            return nil
        }
        return (name, amountValue, weightUnit)
    }
    
    static func parseServingWithVolume(_ string: String) -> (name: String, value: Double, unit: VolumeUnit)? {
        let groups = string.extractCapturedGroups(using: Rx.servingWithVolumeExtractor)
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
                let volumeUnit = volumeUnit(of: unit) else {
            return nil
        }
        return (name, amountValue, volumeUnit)
    }
    
    static func parseVolumeWithWeight(_ string: String) -> (volumeUnit: VolumeUnit?, volumeString: String, weight: Double, weightUnit: WeightUnit)? {
        let groups = string.extractCapturedGroups(using: Rx.volumeWithWeightExtractor)
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
              let weightUnit = weightUnit(of: weight)
        else {
            return nil
        }
        return (volumeUnit(of: volume), volume, amountValue, weightUnit)
    }
    
    static func parseWeightWithVolume(_ string: String) -> (weightUnit: WeightUnit?, weightString: String, volume: Double, volumeUnit: VolumeUnit)? {
        let groups = string.extractCapturedGroups(using: Rx.weightWithVolumeExtractor)
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
              let volumeUnit = volumeUnit(of: volume)
        else {
            return nil
        }
        return (weightUnit(of: weight), weight, amountValue, volumeUnit)
    }
    
    //MARK: - Volume
    
    static func volumeUnit(of string: String) -> VolumeUnit? {
        for unit in VolumeUnit.allCases {
            if string.matchesRegex(unit.regex, caseInsensitive: true) {
                return unit
            }
        }
        return nil
    }

    static func parseVolumeWithServing(_ string: String) -> (unit: VolumeUnit, servingValue: Double, servingName: String)? {
        var groups = string.extractCapturedGroups(using: Rx.volumeWithServingExtractor)
        var unit: String, servingAmount: String, servingName: String
        if groups.count < 4 {
            groups = string.extractCapturedGroups(using: Rx.volumeWithServingHavingSizeNumberExtractor)
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
        
        guard let servingAmountValue = servingAmount.doubleFromExtractedNumber, let volumeUnit = volumeUnit(of: unit) else {
            return nil
        }
        
        return (volumeUnit, servingAmountValue, servingName)
    }
    
    static func parseServingWithServing(_ string: String) -> (serving: String, constituentAmount: Double, constituentName: String)? {
        let groups = string.extractCapturedGroups(using: Rx.servingWithServingExtractor)
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
        
        return (serving, constituentValue, constituentName)
    }
}
