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
        
//        let name: String
//        if scrapedSize.type == .servingWithWeight, let parsed = ServingType.parseServingWithWeight(scrapedSize.name)
//        {
//            name = parsed.name
//        }
//        else if scrapedSize.type == .servingWithVolume, let parsed = ServingType.parseServingWithVolume(scrapedSize.name)
//        {
//            name = parsed.name
//        }
//        else if scrapedSize.type == .servingWithServing, let parsed = ServingType.parseServingWithServing(scrapedSize.name)
//        {
//            name = parsed.serving
//        } else {
//            name = scrapedSize.cleanedName
//        }
//
//        self.name = name.capitalized
//        self.unit = unit
//        self.amount = amount * scrapedSize.multiplier
    }
    
    func processServingWithWeight(name: String) throws {
        guard let parsed = ServingType.parseServingWithWeight(name) else {
            throw ParseError.unableToParse
        }
        self.name = parsed.name
    }

    func processServingWithServing(name: String) throws {
        guard let parsed = ServingType.parseServingWithServing(name) else {
            throw ParseError.unableToParse
        }
        self.name = parsed.serving
    }
    
    func processServingWithVolume(scrapedSize: MyFitnessPalFood.ScrapedSize, unit: SizeUnit, amount: Double) throws {
        guard let parsed = ServingType.parseServingWithVolume(scrapedSize.name) else {
            throw ParseError.unableToParse
        }
        self.name = parsed.name
    }

    enum ParseError: Error {
        case unableToParse
    }
}

