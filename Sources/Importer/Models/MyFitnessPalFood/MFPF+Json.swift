import Foundation

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
                
                sizes.append(
                    Size(name: cleanedUnit, value: value, multiplier: multiplier, index: index)
                )
            }
        }
        self.sizes = sizes
        
        if let timestamp = urlString.firstCapturedGroup(using: RxFileWithTimestamp),
           let urlSlug = urlString.secondCapturedGroup(using: RxFileWithTimestamp),
           let date = timestamp.dateFromTimestamp
        {
            self.urlSlug = urlSlug
            self.createdAt = date
        } else {
            self.urlSlug = urlString
            self.createdAt = Date(timeIntervalSince1970: 0)
        }
    }
}
