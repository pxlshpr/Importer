import UIKit

//public func scrapeHtml(from urlString: String) -> String {
//    guard let url = URL(string: urlString) else {
//        fatalError("Error creating a URL from: \(urlString)")
//    }
//    do {
//        let contents = try String(contentsOf: url)
//        return contents
//    } catch {
//        print("Error loading contents of: \(urlString)")
//        return ""
//    }
//}
//
//public func getJson(from jsonString: String) -> [String: Any] {
//    guard let data = jsonString.data(using: .utf8)
//    else {
//        fatalError("Couldn't scrape JSON object for food")
//    }
//    do {
//        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
//            fatalError("Couldn't parse JSON")
//        }
//        return json
//    } catch let error as NSError {
//        fatalError("Failed to parse JSON: \(error.localizedDescription)")
//    }
//}
