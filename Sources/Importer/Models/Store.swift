import SwiftUI
import SwiftSugar

public typealias MfpSearchCompletionHandler = (_ foods: [Food]) -> Void

public class Engine: NSObject, ObservableObject {
    public static let shared = Engine()
    
    func getProductName(forUpc upc: String) -> String? {
        let urlString = "https://www.upcitemdb.com/upc/\(upc)"
        guard let html = urlString.htmlContents, let name = html.secondCapturedGroup(using: RxUpcLookup) else {
            print("Couldn't parse UPC HTML: \(urlString)")
            return nil
        }
        return name
    }
    
    func getMfpSearchResults(for searchString: String, completion: MfpSearchCompletionHandler? = nil) {
        let urlString = searchString.mfpSearchUrlString
        guard let html = urlString.htmlContents, let jsonString = html.secondCapturedGroup(using: RxMfpResults) else {
            print("Couldn't parse MFP HTML: \(urlString)")
            NotificationCenter.default.post(name: .didGetFoodResults, object: nil)
            return
        }
        
        let fixedJsonString = "\(jsonString)}"
        guard let json = fixedJsonString.asJson, let items = json["items"] as? [Any] else {
            NotificationCenter.default.post(name: .didGetFoodResults, object: nil)
            return
        }
        
        ///convert JSON back to Data
        let mfpFoods = items.compactMap { json -> MyFitnessPalFood? in
            guard let foodJson = json as? [String: Any],
                  let food = MyFitnessPalFood(json: foodJson, urlString: "")
            else {
                  print("Couldn't get food from: \(jsonString)")
                  NotificationCenter.default.post(name: .didGetFoodResults, object: nil)
                  return nil
            }
            return food
        }
        
        let foods = mfpFoods.compactMap { $0.food }
        
        completion?(foods)
//        let userInfo = ["foods": foods]
//        NotificationCenter.default.post(name: .didGetFoodResults, object: nil, userInfo: userInfo)
    }
    
    func findScannedUPC(_ upc: String) {
        guard let name = getProductName(forUpc: upc) else {
            print("Couldn't find any results for that UPC")
            NotificationCenter.default.post(name: .didGetFoodResults, object: nil)
            return
        }
        
        print("Searching MFP for: \(name)")
        getMfpSearchResults(for: name)
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didDownload, object: nil)
        }
    }
}

let RxUpcLookup = #"\".* [0-9]+ is associated with product (.*), find [0-9]+"#
let RxMfpResults = #"(\{\"items\"\:.*\])\,\"totalResultsCount\"\:"#
