import Foundation

extension MFPFood {
    
    var foodStartingWithVolumeWithServing: Food? {
        
        guard let firstSize = sizes.first,
              let firstFoodSize = Food.Size(volumeWithServing: firstSize, mfpSizes: sizes)
        else {
            return nil
        }
        
        //MARK: Configure Food
        let food = baseFood
        food.amount = 1
        food.servingUnit = .size
        if sizes.containsWeightBasedSize {
            //TODO: Should this be 1 or firstSize.value?
            food.servingAmount = 1
            food.servingSize = firstFoodSize
        } else {
            food.servingAmount = 0
        }
        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
        food.sizes.append(firstFoodSize)
        
        //MARK: Add Sizes
        let typesToAdd: [ServingType] = [.serving,
                                         .volumeWithServing,
                                         .servingWithVolume,
                                         .servingWithServing]
        food.importMFPSizes(from: sizes, ofTypes: typesToAdd, withFirstFoodSize: firstFoodSize)
        
        return food
    }
}
