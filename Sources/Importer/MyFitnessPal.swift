public struct MyFitnessPalImporter {
    
    public static func search(for searchText: String, page: Int? = nil, completion: @escaping MfpSearchCompletionHandler) {
        Engine.getMfpSearchResults(for: searchText, page: page, completion: completion)
    }
    
    public static func food(for url: String, completion: @escaping MfpFoodUrlCompletionHandler) {
        Engine.getMfpFood(for: url, completion: completion)
    }
    
    public static func search(for screenshotFood: ScreenshotFood, completion: @escaping MfpFoodUrlCompletionHandler) {
        search(for: screenshotFood, page: 1, completion: completion)
    }
    
    public static func search(for screenshotFood: ScreenshotFood, page: Int, completion: @escaping MfpFoodUrlCompletionHandler) {
        Engine.getMfpSearchResults(for: screenshotFood.name, page: page) { foods in
            if let match = foods.match(for: screenshotFood) {
                completion(match)
            } else if page < 5 {
                search(for: screenshotFood, page: page + 1, completion: completion)
            } else {
                completion(nil)
            }
        }
    }
}

public extension Array where Element == Importer.Food {
    func match(for screenshotFood: ScreenshotFood) -> Importer.Food? {
        let matchers = [nutrientMatches(for:), looseNutrientMatches(for:)]
        for matcher in matchers {
            if let match = match(for: screenshotFood, using: matcher) {
                return match
            }
        }
        return nil
    }
    
    func match(for screenshotFood: ScreenshotFood, using matchesFunc: (ScreenshotFood) -> [Importer.Food]) -> Importer.Food? {
        let matches = matchesFunc(screenshotFood)
//        let matches = nutrientMatches(for: screenshotFood)
        switch matches.count {
        case let x where x == 1:
            return matches.first
        case let x where x > 1:
            return first(where: { $0.screenshotFoodName == screenshotFood.name })
        default:
            return nil
        }
    }
    
    func nutrientMatches(for screenshotFood: ScreenshotFood) -> [Importer.Food] {
        self.filter({ screenshotFood.matchesNutrients(of: $0) })
    }
    
    func looseNutrientMatches(for screenshotFood: ScreenshotFood) -> [Importer.Food] {
        self.filter({ screenshotFood.looselyMatchesNutrients(of: $0) })
    }
}


public struct ScreenshotFood {
    public let name: String
    public let energy: Double
    public let carbs: Double
    public let fat: Double
    public let protein: Double
    
    func matchesNutrients(of food: Importer.Food) -> Bool {
        energy == food.energy
        && carbs == food.carbohydrate
        && protein == food.protein
        && fat == food.fat
    }

    func looselyMatchesNutrients(of food: Importer.Food) -> Bool {
        energy.looselyMatches(food.energy)
        && carbs.looselyMatches(food.carbohydrate)
        && protein.looselyMatches(food.protein)
        && fat.looselyMatches(food.fat)
    }
}

extension Double {
    func looselyMatches(_ double: Double) -> Bool {
        self >= double - 1.0
        && self <= double + 1.0
    }
}

public extension Importer.Food {
    var screenshotFoodName: String {
        if let brand = brand {
            return [name, brand].joined(separator: " ").formattedFoodName
        } else {
            return name.formattedFoodName
        }
    }
}

public extension String {
    var formattedFoodName: String {
        self
        .replacingOccurrences(of: "(", with: "")
        .replacingOccurrences(of: ")", with: "")
        .replacingOccurrences(of: "[", with: "")
        .replacingOccurrences(of: "]", with: "")
    }
}
