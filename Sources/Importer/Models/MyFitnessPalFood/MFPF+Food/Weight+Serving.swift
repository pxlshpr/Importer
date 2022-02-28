import Foundation

extension MyFitnessPalFood {
    var foodStartingWithWeightWithServing: Food? {
        
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0 else {
            return nil
        }
        
        let parsed = baseSize.name.parsedWeightWithServing
        guard let serving = parsed.serving,
              let servingAmount = serving.amount,
              let weightUnit = parsed.weight?.unit
        else {
            return nil
        }
        
        let food = baseFood
        food.servingAmount = servingAmount
        food.servingUnit = .size
        
        let baseWeight = baseSize.processedSize.g(for: baseSize.value, unit: weightUnit)
        
        let size = Food.Size()
        size.name = serving.name.capitalized
        size.unit = .weight
        size.amount = baseWeight / servingAmount
        
        food.setAmount(basedOn: baseWeight)
//        food.amount = baseWeight < 100 ? 100 / baseWeight : 1
        
        food.servingSize = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(
            contentsOf: createSizes(from: sizesToAdd, unit: .weight, amount: size.amount * servingAmount, baseFoodSize: size)
        )

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithWeight
        }.compactMap { scrapedSize -> Food.Size? in
            let s = Food.Size()
            let parsed = scrapedSize.name.parsedServingWithWeight
            guard let serving = parsed.serving else {
                print("Couldn't parse servingWithWeight: \(scrapedSize)")
                return nil
            }
            s.name = serving.name
            s.unit = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseWeight / size.amount
            s.size = size
            return s
        })

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let s = Food.Size()
            let parsed = scrapedSize.name.parsedServingWithServing
            if let servingName = parsed.serving?.name {
                s.name = servingName
            } else {
                s.name = scrapedSize.cleanedName
            }
            s.unit = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseWeight
            s.size = size
            return s
        })
        
        food.scaleNutrientsBy(scale: (food.amount * baseSize.multiplier))
        return food
    }
    
}
