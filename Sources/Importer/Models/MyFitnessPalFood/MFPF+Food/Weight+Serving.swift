import Foundation

extension MyFitnessPalFood {
    var foodStartingWithWeightWithServing: Food? {
        /// protect against division by 0 with baseSize.value check
        guard let baseSize = baseSize, baseSize.value > 0,
                let parsed = ServingType.parseWeightWithServing(baseSize.name)
        else {
            return nil
        }
        let food = baseFood
        food.servingAmount = parsed.servingAmount
        food.servingUnit = .size
        
        let baseWeight = baseSize.processedSize.g(for: baseSize.value, unit: parsed.weightUnit)
        
        let size = Food.Size()
        size.name = parsed.servingName.capitalized
        size.unit = .g
        size.amount = baseWeight / parsed.servingAmount
        
        food.setAmount(basedOn: baseWeight)
//        food.amount = baseWeight < 100 ? 100 / baseWeight : 1
        
        food.servingSize = size
        food.sizes.append(size)
        
        /// add remaining servings or descriptive volumes
        let sizesToAdd = scrapedSizes.dropFirst().filter {
            $0.type == .serving || ($0.type == .volume && $0.isDescriptiveCups)
        }
        food.sizes.append(
            contentsOf: createSizes(from: sizesToAdd, unit: .g, amount: size.amount * parsed.servingAmount, baseFoodSize: size)
        )

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithWeight
        }.compactMap { scrapedSize -> Food.Size? in
            let s = Food.Size()
            guard let parsed = ServingType.parseServingWithWeight(scrapedSize.name) else {
                print("Couldn't parse servingWithWeight: \(scrapedSize)")
                return nil
            }
            s.name = parsed.name
            s.unit = .size
            s.amount = baseSize.multiplier * scrapedSize.multiplier * baseWeight / size.amount
            s.size = size
            return s
        })

        food.sizes.append(contentsOf: scrapedSizes.filter { scrapedSize in
            scrapedSize.type == .servingWithServing
        }.map { scrapedSize -> Food.Size in
            let s = Food.Size()
            if let parsed = ServingType.parseServingWithServing(scrapedSize.name) {
                s.name = parsed.serving
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
