import Foundation

public extension Food.Size {
    
    var amountUnitDescription: String {
        if amountUnit == .size {
            return amountSizeUnit?.name ?? "(missing size)"
        }
        else if amountUnit == .volume, let volumeUnit = amountVolumeUnit {
            return volumeUnit.shortDescription(for: amount)
        }
        else if amountUnit == .weight, let weightUnit = amountWeightUnit {
            return weightUnit.shortDescription(for: amount)
        }
        else if amountUnit == .serving {
            return "serving".pluralizedFor(amount)
        }
        else {
            return "Invalid amountUnit: \(amountUnit.description)"
        }
    }
    
    var amountDescription: String {
        return "\(amount.clean) \(amountUnitDescription)"
    }
    
    var nameDescription: String {
        
        if let nameVolumeUnit = nameVolumeUnit {
            return "[\(quantity.clean) \(nameVolumeUnit.shortDescription(for: quantity))] \(name.singular)"
        } else {
            return name.singular
        }
    }
}
