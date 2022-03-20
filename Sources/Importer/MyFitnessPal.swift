public struct MyFitnessPalImporter {
    
    public static func search(for searchText: String, completion: @escaping MfpSearchCompletionHandler) {
        Engine.getMfpSearchResults(for: searchText, completion: completion)
    }
    
    public static func food(for url: String, completion: @escaping MfpFoodUrlCompletionHandler) {
        Engine.getMfpFood(for: url, completion: completion)
    }
}
