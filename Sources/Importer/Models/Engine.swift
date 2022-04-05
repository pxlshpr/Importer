import SwiftUI
import SwiftSugar

public typealias MfpSearchCompletionHandler = (_ results: [Food]) -> Void
public typealias MfpFoodUrlCompletionHandler = (_ food: Food?) -> Void

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
    
    
    static func getMfpFood(for urlString: String, completion: MfpFoodUrlCompletionHandler? = nil) {
        guard let html = urlString.htmlContents,
              let foodContainerJson = html.secondCapturedGroup(using: RxMfpFoodContainer)
//              let foodJson = foodContainerJson.secondCapturedGroup(using: RxMfpFood)
        else {
            print("Couldn't parse MFP HTML: \(urlString)")
            return
        }
        
        guard let json = foodContainerJson.asJson else {
//        guard let json = foodJson.asJson else {
            print("Couldn't create json object from parsed food json")
            return
        }
        
        guard let urlSlug = urlString.secondCapturedGroup(using: RxMfpSlug) else {
            print("Couldn't extract url slug from mfp food url")
            return
        }
        
        guard let mfpFood = MFPFood(json: json, urlString: urlSlug) else {
            print("Couldn't create MFPFood from json")
            return
        }
        
        guard let food = mfpFood.food else {
            print("Couldn't extract food from MFPFood")
            return
        }
        
        completion?(food)
    }
    
    static func getMfpSearchResults(for searchString: String, page: Int? = nil, completion: MfpSearchCompletionHandler? = nil) {
        let urlString = searchString.mfpSearchUrlString(page: page)
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
            let urlSlug = i < urlStrings.count ? urlStrings[i] : ""
            guard let food = MFPFood(json: foodJson, urlString: urlSlug) else {
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
let RxMfpFoodContainer = #"\"foods\"\:(.*)\,\"nutrition\"\:"#
let RxMfpFood = #"\"item\"\:(.*)\,\"errors\""#
let RxMfpSlug = #"(\/food\/calories.*)$"#
