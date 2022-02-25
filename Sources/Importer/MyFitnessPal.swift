public struct MyFitnessPalImporter {
    public static func search(for searchText: String, completion: @escaping MfpSearchCompletionHandler) {
        Engine.shared.getMfpSearchResults(for: searchText, completion: completion)
    }
}
