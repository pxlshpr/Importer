import Foundation

extension MFPFood {

    var foodStartingWithVolumeWithServing: Food? {
        guard let firstSize = sizes.first,
              let servingName = firstSize.parsed?.serving?.name
        else {
            return nil
        }
        
        let food = baseFood
        food.amount = 1
        food.servingUnit = .serving
        
        /// we're determining the following by checking if the `firstSize` is the `densitySize` in the array:
        /// *if we also don't have any other `volumeWithWeight`'s or `volumeWithServing`s (indicating that this is the sole density for the food)—other meaning with a different `servingName` — since it could simply be expressed with different units in a different mfp.size.*
        if firstSize == sizes.densitySize {
            let name = servingName.formattedForSize
            if !name.isEmpty {
                food.detail = name
            }
            food.servingUnit = .volume
            food.servingVolumeUnit = firstSize.volumeUnit
            food.servingValue = firstSize.trueValue
        } else {
            guard let firstFoodSize = firstFoodSize else {
                return nil
            }
            food.servingUnit = .size
            food.servingSizeUnit = firstFoodSize
            food.servingValue = firstSize.trueValue
            food.sizes.append(firstFoodSize)
        }

        food.density = sizes.density
        food.importMFPSizes(from: sizes, ofTypes: ServingType.allExceptMeasurements)
        
        return food
    }
    
    //TODO: Remove
//    var foodStartingWithVolumeWithServing_legacy: Food? {
//        
//        guard let firstSize = sizes.first,
//              let firstFoodSize = Food.Size(volumeWithServing: firstSize, mfpSizes: sizes)
//        else {
//            return nil
//        }
//
//        //TODO: Strip out serving name and set Detail for ones that have only one VolumeWithServing or VolumeWithWeight named unit
//        
//        let food = baseFood
//        food.amount = 1
//        food.servingUnit = .size
//        if sizes.containsWeightBasedSize {
//            //TODO: Should this be 1 or firstSize.value?
//            food.servingValue = 1
//            food.servingSizeUnit = firstFoodSize
//        } else {
//            food.servingValue = 0
//        }
//        
//        
//        //TODO: Do we need this?
//        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
//        
//        //TODO: Add density for ones where we have a density size (see Kale, generic)
//        
//        food.sizes.append(firstFoodSize)
//        
//        let typesToAdd: [ServingType] = [.serving,
//                                         .volumeWithServing,
//                                         .servingWithVolume,
//                                         .servingWithServing]
//        food.importMFPSizes(from: sizes, ofTypes: typesToAdd)
//        
//        return food
//    }
}
