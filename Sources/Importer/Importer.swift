public struct Importer {
    public static func searchMfp(for searchText: String, completion: @escaping MfpSearchCompletionHandler) {
        Store.shared.getMfpSearchResults(for: searchText, completion: completion)
    }
}
