import Foundation
import PrepUnits

extension MFPFood {
    public var food: Food? {
        guard let firstType = firstType else {
            print("No firstType from: \(scrapedSizes.count) sizes")
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
    
    func createSizes(from scrapedSizes: [ScrapedSize], unit: UnitType, amount: Double, baseFoodSize: Food.Size? = nil) -> [Food.Size] {
        scrapedSizes
            .filter { !$0.name.isEmpty }
            .map { Food.Size(scrapedSize: $0, unit: unit, amount: amount) }
            .removingDuplicates()
            .filter { $0 != baseFoodSize }
    }
}

extension Food.Size {
    convenience init(scrapedSize: MFPFood.ScrapedSize, unit: UnitType, amount: Double) {
        self.init()
        
        self.amountUnitType = unit
        self.amount = amount * scrapedSize.multiplier

        do {
            switch scrapedSize.type {
            case .servingWithWeight:
                try fillInServingWithWeight(named: scrapedSize.name)
            case .servingWithServing:
                try fillInServingWithServing(named: scrapedSize.name)
            case .servingWithVolume:
                try fillInServingWithVolume(scrapedSize, unit: unit, amount: amount)
            case .volumeWithWeight:
                try fillInVolumeWithWeight(scrapedSize, unit: unit, amount: amount)
            default:
                name = scrapedSize.cleanedName
            }
        } catch {
            name = scrapedSize.cleanedName
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
    
    func fillInVolumeWithWeight(_ scrapedSize: MFPFood.ScrapedSize, unit: UnitType, amount: Double) throws {
        let parsed = scrapedSize.name.parsedVolumeWithWeight
        guard let volumeUnit = parsed.volume?.unit else {
            throw ParseError.unableToParse
        }
        
        self.name = scrapedSize.cleanedName
        self.amountUnitType = .volume
        self.amountVolumeUnit = volumeUnit
        self.amount = scrapedSize.scaledValue
    }
    
    func fillInServingWithVolume(_ scrapedSize: MFPFood.ScrapedSize, unit: UnitType, amount: Double) throws {
        let parsed = scrapedSize.name.parsedServingWithVolume
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

extension MFPFood.ScrapedSize {
    var scaledValue: Double {
        multiplier * value
    }
}
