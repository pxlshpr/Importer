import Foundation
import PrepUnits

extension MyFitnessPalFood {
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
    
    func createSizes(from scrapedSizes: [ScrapedSize], unit: SizeUnit, amount: Double, baseFoodSize: Food.Size? = nil) -> [Food.Size] {
        scrapedSizes
            .filter { !$0.name.isEmpty }
            .map { Food.Size(scrapedSize: $0, unit: unit, amount: amount) }
            .removingDuplicates()
            .filter { $0 != baseFoodSize }
    }
}

extension Food.Size {
    convenience init(scrapedSize: MyFitnessPalFood.ScrapedSize, unit: SizeUnit, amount: Double) {
        self.init()
        
        self.unit = unit
        self.amount = amount * scrapedSize.multiplier

        do {
            switch scrapedSize.type {
            case .servingWithWeight:
                try processServingWithWeight(name: scrapedSize.name)
            case .servingWithServing:
                try processServingWithServing(name: scrapedSize.name)
            case .servingWithVolume:
                try processServingWithVolume(scrapedSize: scrapedSize, unit: unit, amount: amount)
            default:
                name = scrapedSize.cleanedName
            }
        } catch {
            name = scrapedSize.cleanedName
        }
        
        name = name.capitalized
    }
    
    func processServingWithWeight(name: String) throws {
        guard let parsed = ServingType.parseServingWithWeight(name),
              let serving = parsed.serving
        else {
            throw ParseError.unableToParse
        }
        self.name = serving.name
    }

    func processServingWithServing(name: String) throws {
        guard let parsed = ServingType.parseServingWithServing(name),
              let servingName = parsed.serving?.name
        else {
            throw ParseError.unableToParse
        }
        self.name = servingName
    }
    
    func processServingWithVolume(scrapedSize: MyFitnessPalFood.ScrapedSize, unit: SizeUnit, amount: Double) throws {
        guard let parsed = ServingType.parseServingWithVolume(scrapedSize.name),
              let serving = parsed.serving,
              let servingAmount = serving.amount,
              let volumeUnit = parsed.volume?.unit
        else {
            throw ParseError.unableToParse
        }
        
        self.name = serving.name
        self.unit = .mL
        self.volumeUnit = volumeUnit
        self.amount = servingAmount
    }

    enum ParseError: Error {
        case unableToParse
    }
}

extension MyFitnessPalFood.ScrapedSize {
    var volumeUnit: VolumeUnit? {
//        switch type {
//        case .servingWithVolume:
//        case .volumeWithServing:
//        case .volumeWithWeight:
//        case .weightWithVolume:
//        case .volume:
//        }
        return nil
    }
}
