import Foundation
import PrepUnits

public class Food {
    public var name: String = ""
    public var brand: String? = ""
    
    public var amount: Double = 0.0
    public var unit: UnitType = .weight
    public var volumeUnit: VolumeUserUnit? = nil
    
    public var servingAmount: Double = 0.0
    public var servingUnit: UnitType = .weight
    public var servingVolumeUnit: VolumeUserUnit? = nil
    public var servingSize: Size? = nil
    
    public var energy: Double = 0
    public var carbohydrate: Double = 0
    public var fat: Double = 0
    public var protein: Double = 0
//    public var densityVolume: Double = 0
//    public var densityWeight: Double = 0
    public var sizes: [Size] = []
    
    func scaleNutrientsBy(scale: Double) {
        energy = energy * scale
        carbohydrate = carbohydrate * scale
        fat = fat * scale
        protein = protein * scale
    }
    
    func setAmount(basedOn value: Double) {
        //TODO: Replace this redundant function with this value
        amount = 1
//        amount = value < 100 ? 100 / value : 1
    }
}

extension Food: Hashable {
    public static func == (lhs: Food, rhs: Food) -> Bool {
        return (
            lhs.name == rhs.name &&
            lhs.brand == rhs.brand &&
            lhs.amount == rhs.amount &&
            lhs.unit == rhs.unit &&
            lhs.servingAmount == rhs.servingAmount &&
            lhs.servingUnit == rhs.servingUnit &&
            lhs.servingSize == rhs.servingSize &&
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
        hasher.combine(unit)
        hasher.combine(servingAmount)
        hasher.combine(servingUnit)
        hasher.combine(servingSize)
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
            guard let density = sizes.first(where: { $0.isDensity }) else {
                return nil
            }
            return Density(volume: 1, weight: density.amount)
        }
        set {
            guard let newValue = newValue, newValue.volume != 0, newValue.weight != 0 else {
                sizes.removeAll(where: { $0.isDensity })
                return
            }
            
            let densitySize = Food.Size()
            densitySize.name = ""
            densitySize.nameVolumeUnit = .mL
            densitySize.amount = newValue.weight / newValue.volume
            densitySize.amountUnitType = .weight
            densitySize.amountWeightUnit = .g
            
            sizes.removeAll(where: { $0.isDensity })
            sizes.append(densitySize)
        }
    }
}
