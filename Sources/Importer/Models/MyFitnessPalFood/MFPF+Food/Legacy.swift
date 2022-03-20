//TODO: Remove
//import Foundation
//
//extension MFPFood {
//    
//    var foodStartingWithServingWithWeight_legacy: Food? {
//        /// protect against division by 0 with firstSize.value check
//        guard let firstSize = sizes.first, firstSize.value > 0 else {
//            return nil
//        }
//        let parsed = firstSize.name.parsedServingWithWeight
//        guard let serving = parsed.serving,
//              let servingAmount = serving.amount,
//              let weightUnit = parsed.weight?.unit
//        else {
//            return nil
//        }
//        
//        let food = baseFood
//        food.servingValue = firstSize.value
//        food.servingUnit = .size
//        
//        let size = Food.Size()
//        size.name = serving.name.cleaned.capitalized
//        size.amountUnit = .weight
//        size.amount = firstSize.processedSize.g(for: servingAmount, unit: weightUnit) / firstSize.value
//        
//        food.amount = 1
//        
//        food.servingSizeUnit = size
//        food.sizes.append(size)
//        
//        /// add remaining servings or descriptive volumes
//        let sizesToAdd = sizes.dropFirst().filter {
//            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups) || $0.type == .servingWithVolume || $0.type == .servingWithWeight
//        }
//        food.sizes.append(contentsOf:
//                            MFPFood.createSizes(from: sizesToAdd, unit: .weight, amount: size.amount, baseFoodSize: size)
//        )
//        
//        food.sizes.append(contentsOf: sizes.filter { mfpSize in
//            mfpSize.type == .servingWithServing
//        }.map { mfpSize -> Food.Size in
//            let remainingSize = Food.Size()
//            if let servingName = mfpSize.name.parsedServingWithServing.serving?.name {
//                remainingSize.name = servingName.capitalized
//            } else {
//                remainingSize.name = mfpSize.cleanedName.capitalized
//            }
//            remainingSize.amountUnit = .size
//            remainingSize.amount = firstSize.multiplier * mfpSize.multiplier * firstSize.value
//            remainingSize.amountSizeUnit = size
//            return remainingSize
//        })
//        
//        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
//        return food
//    }
//    
//    var foodStartingWithServing_legacy: Food? {
//        /// protect against division by 0 with firstSize.value check
//        guard let firstSize = sizes.first, firstSize.value > 0 else {
//            return nil
//        }
//        let food = baseFood
//        food.servingUnit = .size
//        food.servingValue = firstSize.value
//        food.amount = 1
//
//        let size = Food.Size()
//        size.name = firstSize.cleanedName.capitalized
//        
//        let total: Double
//        /// check if we have any weight size
//        if let weightSize = sizes.weightSize, let weight = weightSize.processedSize.g {
//            /// translates an entry of `1 g - x0.01` to `100g`
//            total = weight / weightSize.multiplier
//            let baseWeight = total * firstSize.multiplier
//            
////            food.amount = baseWeight < 100 ? 100 / baseWeight : 1
//            size.amountUnit = .weight
//            size.amount = baseWeight / firstSize.value
//            
//            food.sizes.append(size)
//            food.servingSizeUnit = size
//            
//        } else {
//            size.amountUnit = .serving
//            size.amount = 1.0/firstSize.value
//            
//            total = firstSize.multiplier
//            
//            food.sizes.append(size)
//            food.servingSizeUnit = size
//        }
//        
//        /// add remaining servings or descriptive volumes
//        let sizesToAdd = sizes.dropFirst().filter {
//            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
//        }
//        food.sizes.append(contentsOf:
//                            MFPFood.createSizes(from: sizesToAdd, unit: size.amountUnit, amount: total, baseFoodSize: size)
//        )
//        
//        food.sizes.append(contentsOf: sizes.filter { mfpSize in
//            mfpSize.type == .servingWithServing
//        }.map { mfpSize -> Food.Size in
//            let remainingSize = Food.Size()
//            if let servingName = mfpSize.name.parsedServingWithServing.serving?.name {
//                remainingSize.name = servingName.capitalized
//            } else {
//                remainingSize.name = mfpSize.cleanedName.capitalized
//            }
//            remainingSize.amountUnit = .size
//            remainingSize.amount = total * mfpSize.multiplier * firstSize.value
//            remainingSize.amountSizeUnit = size
//            return remainingSize
//        })
//        
//        food.scaleNutrientsBy(scale: (food.amount * firstSize.multiplier))
//        return food
//    }
//}
