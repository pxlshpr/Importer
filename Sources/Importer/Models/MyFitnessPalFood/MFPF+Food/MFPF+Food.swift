import Foundation
import PrepUnits

extension MFPFood {
    public var food: Food? {
        guard let firstType = firstType else {
            print("No firstType from: \(sizes.count) sizes")
            return nil
        }
        switch firstType {
        case .weight:
            return foodStartingWithWeight
        case .volume:
            return foodStartingWithVolume
        case .serving:
            return foodStartingWithServing
        case .servingWithWeight:
            return foodStartingWithServingWithWeight
        case .servingWithVolume:
            return foodStartingWithServingWithVolume
        case .weightWithServing:
            return foodStartingWithWeightWithServing
        case .volumeWithServing:
            return foodStartingWithVolumeWithServing
        case .volumeWithWeight:
            return foodStartingWithVolumeWithWeight
        case .weightWithVolume:
            return foodStartingWithWeightWithVolume
        default:
            return Food()
        }
    }
    
    var baseFood: Food {
        let food = Food()
        food.name = cleanedName
        food.brand = cleanedBrand
        food.unit = .serving
        food.energy = energy ?? 0
        food.carbohydrate = carb ?? 0
        food.fat = fat ?? 0
        food.protein = protein ?? 0
        return food
    }
    
    //MARK: - Helpers
    
    func createSizes(from sizes: [Size], unit: UnitType, amount: Double, baseFoodSize: Food.Size? = nil) -> [Food.Size] {
        sizes
            .filter { !$0.name.isEmpty }
            .map { Food.Size(mfpSize: $0, unit: unit, amount: amount) }
            .removingDuplicates()
            .filter { $0 != baseFoodSize }
    }
}

extension Food.Size {
    convenience init(mfpSize: MFPFood.Size, unit: UnitType, amount: Double) {
        self.init()
        
        self.amountUnitType = unit
        self.amount = amount * mfpSize.multiplier

        do {
            switch mfpSize.type {
            case .servingWithWeight:
                try fillInServingWithWeight(named: mfpSize.name)
            case .servingWithServing:
                try fillInServingWithServing(named: mfpSize.name)
            case .servingWithVolume:
                try fillInServingWithVolume(mfpSize, unit: unit, amount: amount)
            case .volumeWithWeight:
                try fillInVolumeWithWeight(mfpSize, unit: unit, amount: amount)
            default:
                name = mfpSize.cleanedName
            }
        } catch {
            name = mfpSize.cleanedName
        }
        
        name = name.capitalized
    }
    
    func fillInServingWithWeight(named name: String) throws {
        guard let servingName = name.parsedServingWithWeight.serving?.name else {
            throw ParseError.unableToParse
        }
        self.name = servingName
    }

    func fillInServingWithServing(named name: String) throws {
        guard let servingName = name.parsedServingWithServing.serving?.name else {
            throw ParseError.unableToParse
        }
        self.name = servingName
    }
    
    func fillInVolumeWithWeight(_ mfpSize: MFPFood.Size, unit: UnitType, amount: Double) throws {
        let parsed = mfpSize.name.parsedVolumeWithWeight
        guard let volumeUnit = parsed.volume?.unit else {
            throw ParseError.unableToParse
        }
        
        self.name = mfpSize.cleanedName
        self.amountUnitType = .volume
        self.amountVolumeUnit = volumeUnit
        self.amount = mfpSize.scaledValue
    }
    
    func fillInServingWithVolume(_ mfpSize: MFPFood.Size, unit: UnitType, amount: Double) throws {
        let parsed = mfpSize.name.parsedServingWithVolume
        guard let serving = parsed.serving,
              let servingAmount = serving.amount,
              let volumeUnit = parsed.volume?.unit
        else {
            throw ParseError.unableToParse
        }
        
        self.name = serving.name
        self.amountUnitType = .volume
        self.amountVolumeUnit = volumeUnit
        self.amount = servingAmount
    }

    enum ParseError: Error {
        case unableToParse
    }
}

extension MFPFood.Size {
    var scaledValue: Double {
        multiplier * value
    }
}
