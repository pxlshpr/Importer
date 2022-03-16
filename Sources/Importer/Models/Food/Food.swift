import Foundation
import PrepUnits

public class Food {
    public var name: String = ""
    public var brand: String? = ""
    public var description: String? = ""
    
    public var amount: Double = 0.0
    public var amountUnit: UnitType = .weight
    public var amountWeightUnit: WeightUnit? = nil
    public var amountVolumeUnit: VolumeUserUnit? = nil
    public var amountSizeUnit: Size? = nil
    
    public var servingValue: Double = 0.0
    public var servingUnit: UnitType = .weight
    public var servingWeightUnit: WeightUnit? = nil
    public var servingVolumeUnit: VolumeUserUnit? = nil
    public var servingSizeUnit: Size? = nil
    
    public var energy: Double = 0
    public var carbohydrate: Double = 0
    public var fat: Double = 0
    public var protein: Double = 0
    public var sizes: [Size] = []
    
    func scaleNutrientsBy(scale: Double) {
        energy = energy * scale
        carbohydrate = carbohydrate * scale
        fat = fat * scale
        protein = protein * scale
    }
    
}

extension Food: Hashable {
    public static func == (lhs: Food, rhs: Food) -> Bool {
        return (
            lhs.name == rhs.name &&
            lhs.brand == rhs.brand &&
            lhs.amount == rhs.amount &&
            lhs.amountUnit == rhs.amountUnit &&
            lhs.servingValue == rhs.servingValue &&
            lhs.servingUnit == rhs.servingUnit &&
            lhs.servingSizeUnit == rhs.servingSizeUnit &&
            lhs.energy == rhs.energy &&
            lhs.carbohydrate == rhs.carbohydrate &&
            lhs.fat == rhs.fat &&
            lhs.protein == rhs.protein &&
//            lhs.densityVolume == rhs.densityVolume &&
//            lhs.densityWeight == rhs.densityWeight &&
            lhs.sizes == rhs.sizes
        )
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(brand)
        hasher.combine(amount)
        hasher.combine(amountUnit)
        hasher.combine(servingValue)
        hasher.combine(servingUnit)
        hasher.combine(servingSizeUnit)
        hasher.combine(energy)
        hasher.combine(carbohydrate)
        hasher.combine(fat)
        hasher.combine(protein)
//        hasher.combine(densityVolume)
//        hasher.combine(densityWeight)
        hasher.combine(sizes)
    }
}

extension Food {
    //TODO: Density
    public var density: Density? {
        get {
            guard let densitySize = sizes.first(where: { $0.isDensity }),
                  let volumeUnit = densitySize.nameVolumeUnit,
                  let weightUnit = densitySize.amountWeightUnit
            else {
                return nil
            }
            return Density(volumeAmount: densitySize.quantity, volumeUnit: volumeUnit,
                           weightAmount: densitySize.amount, weightUnit: weightUnit)
        }
        set {
            guard let newValue = newValue, newValue.volumeAmount != 0, newValue.weightAmount != 0 else {
                sizes.removeAll(where: { $0.isDensity })
                return
            }
            
            let densitySize = Food.Size()
            densitySize.name = ""
            densitySize.nameVolumeUnit = newValue.volumeUnit
            densitySize.quantity = newValue.volumeAmount
            densitySize.amount = newValue.weightAmount
            densitySize.amountUnit = .weight
            densitySize.amountWeightUnit = newValue.weightUnit
            
            sizes.removeAll(where: { $0.isDensity })
            sizes.append(densitySize)
        }
    }
}

import SwiftSugar

public extension Food {
    var amountDescription: String {
        return "\(amount.clean) \(amountUnitString)"
    }
    
    var servingDescription: String {
        guard amountUnit == .serving else {
            return "(not set)"
        }
        return "\(servingValue.clean) \(servingUnitString)"
    }

    var amountUnitString: String {
        if amountUnit == .size {
            return amountSizeUnit?.name ?? "(missing amount size)"
        }
        else if amountUnit == .volume, let volumeUnit = amountVolumeUnit {
            return volumeUnit.volumeUnit.shortDescription(for: amount)
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

    var servingUnitString: String {
        if servingUnit == .size {
            return servingSizeUnit?.name ?? "(missing serving size)"
        }
        else if servingUnit == .volume, let volumeUnit = servingVolumeUnit {
            return volumeUnit.volumeUnit.shortDescription(for: servingValue)
        }
        else if servingUnit == .weight, let weightUnit = servingWeightUnit {
            return weightUnit.shortDescription(for: servingValue)
        }
        else {
            return "Invalid servingUnit: \(servingUnit.description)"
        }
    }
}
