import Foundation
import PrepUnits

extension MFPFood {
    
    public static func getFoodAt(urlString: String) async -> MFPFood? {
        
        guard let html = urlString.htmlContents else {
            print("Couldn't download HTML for: \(urlString)")
            return nil
        }
        
        /// extract the JSON
        guard let json = html.secondCapturedGroup(using: #"\"application\/json\"[^>]*>(.*)<\/script>"#)?.asJson else {
            print("Couldn't get food json from extracted html at: \(urlString)")
            return nil
        }

        /// convert the JSON to an MFPFood
        guard let mfpFood = MFPFood(json: json, urlString: urlString) else {
            print("Couldn't convert JSON to MFPFood")
            return nil
        }

        return mfpFood
    }
    
    public init?(json: [String: Any], urlString: String) {
        
        guard
            let props = json["props"] as? [String: Any],
            let pageProps = props["pageProps"] as? [String: Any],
            let dehydratedState = pageProps["dehydratedState"] as? [String: Any],
            let queries = dehydratedState["queries"] as? [[String: Any]],
            let state = queries.first?["state"] as? [String: Any],
            let data = state["data"] as? [String: Any],
            let data2 = data["data"] as? [String: Any],
            let node = data2["node"] as? [String: Any],
            let id = node["id"] as? String,
            let name = node["description"] as? String,
            let servingSizes = node["servingSizes"] as? [[String: Any]],
            let firstServingSize = servingSizes.first
        else {
            return nil
        }
        
        self.id = id
        self.brand = node["brand"] as? String
        
        if let brand = self.brand, name.hasPrefix("\(brand) - ") {
            self.name = name.replacingOccurrences(of: "\(brand) - ", with: "")
        } else {
            self.name = name
        }
        
        //MARK: - Energy
        
        guard
            let unit = firstServingSize["unit"] as? String,
            let nutrition = firstServingSize["nutrition"] as? [String: Any],
            let energy = nutrition["energy"] as? [String: Any],
            let energyUnit = energy["unit"] as? String,
            let energyValue = energy["value"] as? Double
        else {
            return nil
        }

        let baseEnergy: Double
        if energyUnit == "calories" {
            baseEnergy = energyValue
        } else {
            //TODO: Replace with a constant that's stored in one place
            baseEnergy = energyValue / 4.184
        }
        self.energy = baseEnergy
        
        //MARK: - Macros
        if let amount = nutrition["carbs"] as? Double, amount > 0 {
            self.carb = amount
        } else {
            self.carb = 0
        }

        if let amount = nutrition["fat"] as? Double, amount > 0 {
            self.fat = amount
        } else {
            self.fat = 0
        }

        if let amount = nutrition["protein"] as? Double, amount > 0 {
            self.protein = amount
        } else {
            self.protein = 0
        }

        //MARK: - Micros
        
        var nutrientsArray = [Nutrient]()
        if let amount = nutrition["fiber"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .dietaryFiber, amount: amount, unit: .g)
            )
        }
        if let amount = nutrition["sugar"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .sugars, amount: amount, unit: .g)
            )
        }
        if let amount = nutrition["saturatedFat"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .saturatedFat, amount: amount, unit: .g)
            )
        }
        if let amount = nutrition["polyunsaturatedFat"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .polyunsaturatedFat, amount: amount, unit: .g)
            )
        }
        if let amount = nutrition["monounsaturatedFat"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .monounsaturatedFat, amount: amount, unit: .g)
            )
        }
        if let amount = nutrition["transFat"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .transFat, amount: amount, unit: .g)
            )
        }
        if let amount = nutrition["cholesterol"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .cholesterol, amount: amount, unit: .mg)
            )
        }
        if let amount = nutrition["sodium"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .sodium, amount: amount, unit: .mg)
            )
        }
        if let amount = nutrition["potassium"] as? Double, amount > 0 {
            nutrientsArray.append(
                Nutrient(type: .potassium, amount: amount, unit: .mg)
            )
        }
        if let amount = nutrition["vitaminA"] as? Double, amount > 0,
           let converted = NutrientType.vitaminA.convertRDApercentage(amount)
        {
            nutrientsArray.append(
                Nutrient(type: .vitaminA, amount: converted.0, unit: converted.1)
            )
        }
        if let amount = nutrition["vitaminC"] as? Double, amount > 0,
           let converted = NutrientType.vitaminC.convertRDApercentage(amount)
        {
            nutrientsArray.append(
                Nutrient(type: .vitaminC, amount: converted.0, unit: converted.1)
            )
        }
        if let amount = nutrition["calcium"] as? Double, amount > 0,
           let converted = NutrientType.calcium.convertRDApercentage(amount)
        {
            nutrientsArray.append(
                Nutrient(type: .calcium, amount: converted.0, unit: converted.1)
            )
        }
        if let amount = nutrition["iron"] as? Double, amount > 0,
           let converted = NutrientType.iron.convertRDApercentage(amount)
        {
            nutrientsArray.append(
                Nutrient(type: .iron, amount: converted.0, unit: converted.1)
            )
        }

        self.nutrients = nutrientsArray
        
        var sizes = [Size]()
        
        var cleanedUnit = unit
        if let doubleBrackets = unit.firstCapturedGroup(using: ServingType.Rx.doubleBracketedServing) {
            cleanedUnit = unit.replacingOccurrences(of: doubleBrackets, with: "")
            print("🧹 Clean Unit: \(unit) → \(cleanedUnit)")
        }
        
        let size = Size(name: cleanedUnit, value: 1, multiplier: 1, index: 0)
        /// disregard all unsupported sizes (which is currently only those that explicitly describe "serving" (see `String.isServing`)
        if size.type != .unsupported {
            sizes.append(size)
        }
        
        //MARK: - Serving Sizes
        
        /// We can currently only determine the multiplier's if the `baseEnergy` isn't `0` (otherwise leading to a division by 0 error), so we may have to add methods to use other nutrients later if needed.
        var index = 0
        
        if baseEnergy > 0 {
            for servingSize in servingSizes.dropFirst() {
                guard
                    let unit = servingSize["unit"] as? String,
                    let nutrition = servingSize["nutrition"] as? [String: Any],
                    let energy = nutrition["energy"] as? [String: Any],
                    let energyValue = energy["value"] as? Double
                else {
                    return nil
                }
                
                /// Skip sizes that have the same name as ones we have already added (to handle erraneous duplicates on MFP's side)
                guard !sizes.contains(where: { $0.name == unit }) else {
                    continue
                }
                
                /// Determine the multiplier by comparing the energy values
                let multiplier = energyValue / baseEnergy

                var cleanedUnit = unit
                if let doubleBrackets = unit.firstCapturedGroup(using: ServingType.Rx.doubleBracketedServing) {
                    cleanedUnit = unit.replacingOccurrences(of: doubleBrackets, with: "")
                }
                
                index += 1
                let size = Size(name: cleanedUnit, value: 1, multiplier: multiplier, index: index)
                /// disregard all unsupported sizes (which is currently only those that explicitly describe "serving" (see `String.isServing`)
                if size.type != .unsupported {
                    sizes.append(size)
                }
            }
        }
        
//        for servingSize in servingSizes.dropFirst() {
//            guard
//                let unit = servingSize["unit"] as? String,
//                let nutrition = servingSize["nutrition"] as? [String: Any]
//            else {
//                return nil
//            }
//            print("Processing: \(unit)")
//        }
        
        /// Now normalize multipliers for grams so that the size with `g` gets assigned  a multiplier of 1, while the rest gets scaled accordingly
        sizes.normalizeMultipliersIfNeeded()
        
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
    
    /// Old JSON version of MFP
    public init?(json_legacy json: [String: Any], urlString: String) {
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

extension Array where Element == MFPFood.Size {
    
    mutating func normalizeMultipliersIfNeeded() {
        
        guard let gramSize = first(where: { $0.name == "g" }), gramSize.multiplier != 1 else {
            return
        }
        
        /// Determine the multiplier needed for `g` to be set to 1x
        let normalizingMultiplier = 1 / gramSize.multiplier
        
        /// Now apply this normalizing multiplier to all `Size`'s
        for i in indices {
            self[i].multiplier = self[i].multiplier * normalizingMultiplier
        }
    }
}

let MfpFoodPrefix = "https://www.myfitnesspal.com/food/calories/"
