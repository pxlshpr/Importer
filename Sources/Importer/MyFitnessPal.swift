public struct MyFitnessPalImporter {
    public static func search(for searchText: String, completion: @escaping MfpSearchCompletionHandler) {
        Store.shared.getMfpSearchResults(for: searchText, completion: completion)
    }
}
