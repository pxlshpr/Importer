import SwiftUI
import SwiftSugar

public typealias MfpSearchCompletionHandler = (_ results: [Food]) -> Void

public class Engine: NSObject, ObservableObject {
//    public static let shared = Engine()
}

public extension Engine {
    static func getProductName(forUpc upc: String) -> String? {
        let urlString = "https://www.upcitemdb.com/upc/\(upc)"
        guard let html = urlString.htmlContents, let name = html.secondCapturedGroup(using: RxUpcLookup) else {
            print("Couldn't parse UPC HTML: \(urlString)")
            return nil
        }
        return name
    }
        
    static func getMfpSearchResults(for searchString: String, completion: MfpSearchCompletionHandler? = nil) {
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
        
        /// get all the lines with the url's to the food pages (in the html itself) by separating the string up by each link's prefix, and running a regex on each line
        var urlStrings: [String] = []
        for line in html.components(separatedBy: #"<a target="_self""#) {
            guard let urlSlug = line.secondCapturedGroup(using: RxMfpUrlStrings) else {
                continue
            }
            urlStrings.append(urlSlug)
        }

        ///convert JSON back to Data
        var mfpFoods: [MFPFood] = []
        for i in items.indices {
            let itemJson = items[i]
            guard let foodJson = itemJson as? [String: Any] else {
                print("Couldn't extract foodJSON")
                continue
            }
            let urlString = i < urlStrings.count ? urlStrings[i] : ""
            guard let food = MFPFood(json: foodJson, urlString: urlString) else {
                print("Couldn't create MFPFood")
                continue
            }
            mfpFoods.append(food)
        }
        
//        let mfpFoods = items.compactMap { json -> MFPFood? in
//            guard let foodJson = json as? [String: Any],
//                  let food = MFPFood(json: foodJson, urlString: "")
//            else {
//                  print("Couldn't get food from: \(jsonString)")
//                  NotificationCenter.default.post(name: .didGetFoodResults, object: nil)
//                  return nil
//            }
//            return food
//        }

        let foods = mfpFoods.compactMap { $0.food }
        
        completion?(foods)
//        let userInfo = ["foods": foods]
//        NotificationCenter.default.post(name: .didGetFoodResults, object: nil, userInfo: userInfo)
    }
    
    static func findScannedUPC(_ upc: String) {
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

public extension String {
    var lines: [String] {
        return self.components(separatedBy: "\n")
    }
}

let RxUpcLookup = #"\".* [0-9]+ is associated with product (.*), find [0-9]+"#
let RxMfpResults = #"(\{\"items\"\:.*\])\,\"totalResultsCount\"\:"#
let RxMfpUrlStrings = #"\"(\/food\/calories\/[^>]*)\""#
