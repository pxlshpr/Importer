import Foundation
import PrepUnits

extension MFPFood {
    public init?(json: [String: Any], urlString: String) {
        guard
            let item = json["item"] as? [String: Any],
            let nutrients = item["nutritional_contents"] as? [String: Any],
            let id = item["id"] as? Int,
            let name = item["description"] as? String
        else {
            return nil
        }
        
        self.id = "\(id)"
        self.brand = item["brand_name"] as? String
        
        if let brand = self.brand, name.hasPrefix("\(brand) - ") {
            self.name = name.replacingOccurrences(of: "\(brand) - ", with: "")
        } else {
            self.name = name
        }
        
        //MARK: - Macro Nutrients

        if let energy = nutrients["energy"] as? [String: Any],
           let unit = energy["unit"] as? String,
           unit == "calories"
        {
            self.energy = energy["value"] as? Double
        } else {
            print("Unable to parse energy")
            self.energy = nil
        }
        self.carb = nutrients["carbohydrates"] as? Double
        self.fat = nutrients["fat"] as? Double
        self.protein = nutrients["protein"] as? Double
        
        //MARK: - Micro Nutrients
        
        var nutrientsArray = [Nutrient]()
        if let amount = nutrients["fiber"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .dietaryFiber, amount: amount, unit: .g)
            )
        }
        if let amount = nutrients["sugar"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .sugars, amount: amount, unit: .g)
            )
        }
        if let amount = nutrients["saturated_fat"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .saturatedFat, amount: amount, unit: .g)
            )
        }
        if let amount = nutrients["polyunsaturated_fat"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .polyunsaturatedFat, amount: amount, unit: .g)
            )
        }
        if let amount = nutrients["monounsaturated_fat"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .monounsaturatedFat, amount: amount, unit: .g)
            )
        }
        if let amount = nutrients["trans_fat"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .transFat, amount: amount, unit: .g)
            )
        }
        if let amount = nutrients["cholesterol"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .cholesterol, amount: amount, unit: .mg)
            )
        }
        if let amount = nutrients["sodium"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .sodium, amount: amount, unit: .mg)
            )
        }
        if let amount = nutrients["potassium"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .potassium, amount: amount, unit: .mg)
            )
        }
        if let amount = nutrients["vitamin_a"] as? Double, amount > 0,
           let converted = NutrientType.vitaminA.convertRDApercentage(amount)
        {
            nutrientsArray.append(
                Nutrient(type: .vitaminA, amount: converted.0, unit: converted.1)
            )
        }
        if let amount = nutrients["vitamin_c"] as? Double, amount > 0,
           let converted = NutrientType.vitaminC.convertRDApercentage(amount)
        {
            nutrientsArray.append(
                Nutrient(type: .vitaminC, amount: converted.0, unit: converted.1)
            )
        }
        if let amount = nutrients["calcium"] as? Double, amount > 0,
           let converted = NutrientType.calcium.convertRDApercentage(amount)
        {
            nutrientsArray.append(
                Nutrient(type: .calcium, amount: converted.0, unit: converted.1)
            )
        }
        if let amount = nutrients["iron"] as? Double, amount > 0,
           let converted = NutrientType.iron.convertRDApercentage(amount)
        {
            nutrientsArray.append(
                Nutrient(type: .iron, amount: converted.0, unit: converted.1)
            )
        }

        self.nutrients = nutrientsArray
        
        //MARK: - Sizes
        var sizes = [Size]()
        if let servingSizes = item["serving_sizes"] as? [[String: Any]] {
            for i in 0..<servingSizes.count {
                let servingSize = servingSizes[i]
                guard
                    let unit = servingSize["unit"] as? String,
                    let value = servingSize["value"] as? Double,
                    let multiplier = servingSize["nutrition_multiplier"] as? Double,
                    let index = servingSize["index"] as? Int
                else {
                    continue
                }
                var cleanedUnit = unit
                
                if let doubleBrackets = unit.firstCapturedGroup(using: ServingType.Rx.doubleBracketedServing) {
                    cleanedUnit = unit.replacingOccurrences(of: doubleBrackets, with: "")
                    print("🧹 Clean Unit: \(unit) → \(cleanedUnit)")
//                    print("Consider: \(servingSizes.first!["unit"]!)")
                }
                
                let size = Size(name: cleanedUnit, value: value, multiplier: multiplier, index: index)
                /// disregard all unsupported sizes (which is currently only those that explicitly describe "serving" (see `String.isServing`)
                if size.type != .unsupported {
                    sizes.append(size)
                }
            }
        }
        self.sizes = sizes
        
        //MARK: - Metadata
        if let timestamp = urlString.firstCapturedGroup(using: RxFileWithTimestamp),
           let urlSlug = urlString.secondCapturedGroup(using: RxFileWithTimestamp),
           let date = timestamp.dateFromTimestamp
        {
            self.urlSlug = urlSlug
            self.createdAt = date
        } else if urlString.hasPrefix(MfpFoodPrefix) {
            self.urlSlug = urlString.replacingOccurrences(of: MfpFoodPrefix, with: "")
            self.createdAt = Date(timeIntervalSince1970: 0)
        } else {
            self.urlSlug = urlString
            self.createdAt = Date(timeIntervalSince1970: 0)
        }
    }
}

let MfpFoodPrefix = "https://www.myfitnesspal.com/food/calories/"
