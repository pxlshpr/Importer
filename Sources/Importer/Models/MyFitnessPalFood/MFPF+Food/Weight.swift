import Foundation
import PrepUnits

extension MFPFood {
    var foodStartingWithWeight: Food? {
        guard let firstSize = sizes.first else {
            return nil
        }
        
        let food = baseFood
        food.amount = firstSize.trueValue
        food.amountUnit = .weight
        food.amountWeightUnit = firstSize.weightUnit
                
        let types = Array(Set(ServingType.allCases).subtracting([ServingType.volume, ServingType.weight]))
        food.importMFPSizes(from: sizes, ofTypes: types)
        
//        //TODO: Change this
//        let sizesToAdd = sizes.dropFirst().filter {
//            $0.type != .weight && $0.type != .volume
//        }
//        food.sizes.append(
//            contentsOf: MFPFood.createSizes(
//                from: sizesToAdd, unit: .weight, amount: firstSize.trueValue
//            )
//        )
        
        return food
    }
}
