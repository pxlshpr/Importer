import Foundation
import PrepUnits

extension MFPFood {
    var foodStartingWithVolume: Food? {
        guard let firstSize = sizes.first else {
            return nil
        }
        
        let food = baseFood
        
        food.amount = 1
        food.amountUnit = .serving
        
        food.servingUnit = .volume
        food.servingValue = firstSize.trueValue
        food.servingVolumeUnit = firstSize.volumeUnit
        food.density = sizes.density
                
        let types = ServingType.all(excluding: [ServingType.volume, ServingType.weight])
        food.importMFPSizes(from: sizes, ofTypes: types)

//        //TODO: Descriptive cups is now invalid
//        /// If the first size has format of `cup, shredded` **and** the next size is a weight size
//        if firstSize.isDescriptiveCups, let secondSize = secondSize, secondSize.type == .weight, let secondWeight = secondSize.processedSize.g {
//
//            /// translates an entry of `1 g - x0.01` to `100g`
//            let secondTotal = secondWeight / secondSize.multiplier
//
//            let baseWeight = secondTotal * firstSize.multiplier
//
//            let size = Food.Size()
//            size.name = firstSize.cleanedName.capitalized
//            size.amountUnit = .weight
//            size.amount = baseWeight / firstSize.value
//            food.sizes.append(size)
//
//            food.amount = 1
//            food.servingValue = firstSize.value
//            food.servingUnit = .size
//            food.servingSizeUnit = size
//
//            /// add remaining non-measurement servings
//            let sizesToAdd = sizes.dropFirst().filter {
//                $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
//            }
//            food.sizes.append(contentsOf:
//                                MFPFood.createSizes(from: sizesToAdd, unit: .weight, amount: secondTotal, baseFoodSize: size)
//            )
//
//            food.scaleNutrientsBy(scale: food.amount * firstSize.multiplier)
//
//        } else {
//            let volume = ml * firstSize.value / firstSize.multiplier
//
//            food.amountUnit = .serving
//            food.amount = 1
//
//            food.servingUnit = .volume
//            food.servingValue = firstSize.value / firstSize.multiplier
//            food.servingVolumeUnit = firstSize.cleanedName.parsedVolume.volume?.unit?.volumeUserUnit
//
//            //TODO: Do this for weight too
//            /// if any sizes indicate a density
//
//            if let density = sizes.density {
//                food.density = density
//
//                //TODO: Density
//                let densityVolume = density.volumeAmount
//                let densityWeight = density.weightAmount
//
//                //TODO: Density
//                let weight = volume * densityWeight / densityVolume
//
//                let sizesToAdd = sizes.dropFirst().filter {
//                    $0.type != .weight && $0.type != .volume
//                }
//
//                food.sizes.append(
//                    contentsOf: MFPFood.createSizes(
//                        from: sizesToAdd, unit: .volume, amount: volume
//                    )
//                )
//            } else {
//                let sizesToAdd = sizes.dropFirst().filter {
//                    $0.type != .weight && $0.type != .volume
//                }
//                food.sizes.append(
//                    contentsOf: MFPFood.createSizes(
//                        from: sizesToAdd, unit: .volume, amount: volume
//                    )
//                )
//            }
//            food.scaleNutrientsBy(scale: food.amount / volume)
//        }
//
        return food
    }
}
