import Foundation
import PrepUnits

extension MyFitnessPalFood {
    var foodStartingWithVolume: Food? {
        guard let baseSize = baseSize, let ml = baseSize.processedSize.ml else {
            return nil
        }
        let food = baseFood
        
        /// If the base size has format of `cup, shredded` **and** the next size is a weight size
        if baseSize.isDescriptiveCups, let secondSize = secondSize, secondSize.type == .weight, let secondWeight = secondSize.processedSize.g {
            
            /// translates an entry of `1 g - x0.01` to `100g`
            let secondTotal = secondWeight / secondSize.multiplier
            
            let baseWeight = secondTotal * baseSize.multiplier
            
            let size = Food.Size()
            size.name = baseSize.cleanedName.capitalized
            size.unit = .g
            size.amount = baseWeight / baseSize.value
            food.sizes.append(size)
            
            food.setAmount(basedOn: baseWeight)
//            food.amount = baseWeight < 100 ? 100 / baseWeight : 1
            food.servingAmount = baseSize.value
            food.servingUnit = .size
            food.servingSize = size
            
            /// add remaining non-measurement servings
            let sizesToAdd = scrapedSizes.dropFirst().filter {
                $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
            }
            food.sizes.append(contentsOf:
                                createSizes(from: sizesToAdd, unit: .g, amount: secondTotal, baseFoodSize: size)
            )
            
            food.scaleNutrientsBy(scale: food.amount * baseSize.multiplier)
            
        } else {
            let volume = ml * baseSize.value / baseSize.multiplier

            //TODO: Do this for weight too
            /// if any sizes indicate a density
            if let volumeWithWeightSize = scrapedSizes.first(where: { $0.type == .volumeWithWeight }),
               let parsed = ServingType.parseVolumeWithWeight(volumeWithWeightSize.name), let volumeUnit = parsed.volumeUnit {

                /// determine the density of that particular size
                food.densityVolume = volumeWithWeightSize.processedSize.ml(for: volumeWithWeightSize.value, unit: volumeUnit)
                food.densityWeight = baseSize.processedSize.g(for: parsed.weight, unit: parsed.weightUnit)

                let weight = volume * food.densityWeight / food.densityVolume
                                
                /// create the food based on weight
                food.unit = .g
                food.amount = weight
                food.servingAmount = 0
                let sizesToAdd = scrapedSizes.dropFirst().filter {
                    $0.type != .weight && $0.type != .volume
                }.filter { sizeToAdd in
                    /// filter out other sizes with a different density
                    if let sizeDensity = sizeToAdd.density, let foodDensity = food.density, sizeDensity != foodDensity {
                        return false
                    }
                    /// keep any that don't have densities
                    return true
                }
                
                food.sizes.append(
                    contentsOf: createSizes(
                        from: sizesToAdd, unit: .g, amount: weight
                    )
                )
            } else {
                food.unit = .serving
                food.amount = 1
                
                food.servingUnit = .mL
                food.servingAmount = baseSize.value / baseSize.multiplier
                let volumeUnit = ServingType.volumeUnit(of: baseSize.cleanedName)
                food.servingVolumeUnit = volumeUnit?.volumeUserUnit
                
                let sizesToAdd = scrapedSizes.dropFirst().filter {
                    $0.type != .weight && $0.type != .volume
                }
                food.sizes.append(
                    contentsOf: createSizes(
                        from: sizesToAdd, unit: .mL, amount: volume
                    )
                )
            }
            food.scaleNutrientsBy(scale: food.amount / volume)
        }
        
        return food
    }
}

extension VolumeUnit {
    
    var volumeUserUnit: VolumeUserUnit? {
        switch self {
        case .mL:
            return VolumeMilliliterUserUnit.ml
        case .teaspoon:
            return VolumeTeaspoonUserUnit.teaspoonMetric
        case .tablespoon:
            return VolumeTablespoonUserUnit.tablespoonMetric
        case .fluidOunce:
            return VolumeFluidOunceUserUnit.fluidOunceUSNutritionLabeling
        case .cup:
            return VolumeCupUserUnit.cupUSLegal
        case .pint:
            return VolumePintUserUnit.pintImperial
        case .quart:
            return VolumeQuartUserUnit.quartImperial
        case .gallon:
            return VolumeGallonUserUnit.gallonUSLiquid
        }
    }
}
