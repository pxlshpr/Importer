import Foundation

public extension ServingType {
    static var allExceptMeasurements: [ServingType] {
        all(excluding: [.volume, .weight])
    }
}
extension MFPFood {
    
//    var foodStartingWithServing: Food? {
//        guard let firstSize = sizes.first,
//              let firstFoodSize = Food.Size(serving: firstSize, mfpSizes: sizes)
//        else {
//            return nil
//        }
//
//        let food = baseFood
//        food.amount = 1
//        food.amountUnit = .serving
//        food.servingUnit = .size
//        food.servingValue = firstSize.value
//        food.servingSizeUnit = firstFoodSize
//        food.density = sizes.density
//        food.sizes.append(firstFoodSize)
//        food.importMFPSizes(from: sizes, ofTypes: ServingType.allExceptMeasurements)
//
//        return food
//    }
//
//    var foodStartingWithServingWithWeight: Food? {
//        guard let firstSize = sizes.first,
//              let firstFoodSize = Food.Size(servingWithWeight: firstSize, firstMFPSize: firstSize)
//        else {
//            return nil
//        }
//
//        let food = baseFood
//        food.amount = 1
//        food.amountUnit = .serving
//        food.servingUnit = .size
//        food.servingValue = firstSize.value
//        food.servingSizeUnit = firstFoodSize
//        food.density = sizes.density
//        food.sizes.append(firstFoodSize)
//        food.importMFPSizes(from: sizes, ofTypes: ServingType.allExceptMeasurements)
//
//        return food
//    }
    
    var firstFoodSize: Food.Size? {
        guard let firstSize = sizes.first else { return nil }
        switch firstSize.type {
        case .serving:
            return Food.Size(serving: firstSize, mfpSizes: sizes)
        case .servingWithWeight:
            return Food.Size(servingWithWeight: firstSize, firstMFPSize: firstSize)
        case .servingWithVolume:
            return Food.Size(servingWithVolume: firstSize, firstMFPSize: firstSize)
        case .weightWithServing:
            return Food.Size(weightWithServing: firstSize, firstMFPSize: firstSize)
//        case .volumeWithWeight:
//            return Food.Size(volumeWithWeight: firstSize)
        default:
            return nil
        }
    }
    
    var servingBasedFood: Food? {
        guard let firstSize = sizes.first, let firstFoodSize = firstFoodSize else {
            return nil
        }
        
        let food = baseFood
        food.amount = 1
        food.amountUnit = .serving
        food.servingUnit = .size
        if firstSize.type == .weightWithServing {
            food.servingValue = firstSize.parsed?.serving?.amount ?? 1
        } else {
            food.servingValue = firstSize.value
        }
        food.servingSizeUnit = firstFoodSize
        food.density = sizes.density
        food.sizes.append(firstFoodSize)
        food.importMFPSizes(from: sizes, ofTypes: ServingType.allExceptMeasurements)
        return food
    }
}
