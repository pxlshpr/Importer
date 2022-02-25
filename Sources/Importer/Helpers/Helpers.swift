import UIKit

public func scrapeHtml(from urlString: String) -> String {
    guard let url = URL(string: urlString) else {
        fatalError("Error creating a URL from: \(urlString)")
    }
    do {
        let contents = try String(contentsOf: url)
        return contents
    } catch {
        print("Error loading contents of: \(urlString)")
        return ""
    }
}

//public func writeHtmlFiles(_ htmls: [String: String]) {
//    for urlString in htmls.keys {
//        guard let html = htmls[urlString] else {
//            fatalError("Couldn't get html in dict for: \(urlString)")
//        }
//        guard let string = getFoodJsonString(from: html) else {
//            fatalError("Couldn't get food json for: \(urlString)")
//        }
//        writeFoodJsonString(string, toFileNamed: urlString.filenameForMfpFile)
//    }
//}
//

//func urlHasBeenDownloaded(_ urlString: String) -> Bool {
//    fileUrlForExistingMfpFood(withUrlString: urlString) != nil
//}

//public func downloadAndWriteHtmlFiles() {
//    print("📂 Writing to: \(documentsUrl.absoluteString)")
//    
//    var htmls: [String: String] = [:]
//    for i in 0..<Data.urlStrings.count {
//        let urlString = Data.urlStrings[i]
//        
//        if urlHasBeenDownloaded(urlString) {
//            print("↩️ \(i+1)/\(Data.urlStrings.count) Skipping \(urlString.filenameForMfpFileWithoutTimestamp)")
//        } else {
//            print("⬇️ \(i+1)/\(Data.urlStrings.count) Downloading \(urlString.filenameForMfpFileWithoutTimestamp)")
//            let html = scrapeHtml(from: urlString)
//            htmls[urlString] = html
//            sleep(2)
//        }
//    }
//
//    print("📝 Writing files to: \(documentsUrl)")
//    writeHtmlFiles(htmls)
//    Store.shared.processFiles() {
//        Store.shared.updateTestUnits()
//    }
//}

//public var documentsUrl: URL {
//    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//}

//public func writeFoodJsonString(_ string: String, toFileNamed filename: String) {
//    let fileUrl = jsonsFolderUrl.appendingPathComponent(filename)
//    do {
//        try string.write(to: fileUrl, atomically: true, encoding: .utf8)
//    } catch {
//        fatalError("Error writing to file: \(error)")
//    }
//}
//
//func contentsOfDirectory(_ url: URL) -> [URL] {
//    do {
//        let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
//        return files
//    } catch {
//        fatalError("Error getting directory contents: \(error)")
//    }
//}
//
//public var documentsContents: [URL] {
//    contentsOfDirectory(documentsUrl)
//}
//
//func documentsContents(withExtension fileExtension: String) -> [URL] {
//    documentsContents.filter{ $0.pathExtension == fileExtension }
//}

//public func fileContents(at url: URL) -> String {
//    do {
//        return try String(contentsOf: url, encoding: .utf8)
//    } catch {
//        fatalError("Error reading files: \(error)")
//    }
//}

//public var jsonsFromFiles: [(jsonString: String, filename: String)] {
//    var jsons: [(String, String)] = []
//    guard FileManager.default.fileExists(atPath: jsonsFolderUrl.path) else {
//        return jsons
//    }
//
//    for url in contentsOfDirectory(jsonsFolderUrl).filter({ $0.pathExtension == "txt" }) {
//        let filename = String((url.absoluteString as NSString).lastPathComponent)
//        jsons.append((fileContents(at: url), filename))
//    }
//    return jsons
//}
//
//func getFoodJsonString(from html: String) -> String? {
//    html.extractSecondCapturedGroup(using: RegEx.Food)
//}
//
public func getJson(from jsonString: String) -> [String: Any] {
    guard let data = jsonString.data(using: .utf8)
    else {
        fatalError("Couldn't scrape JSON object for food")
    }
    do {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            fatalError("Couldn't parse JSON")
        }
        return json
    } catch let error as NSError {
        fatalError("Failed to parse JSON: \(error.localizedDescription)")
    }
}

//func copyFilesFromBundleToDocumentsFolderWith(fileExtension: String) {
//    guard let resourcesPath = Bundle.main.resourcePath else {
//        fatalError("Couldn't get path for Resources")
//    }
//
//    do {
//        let dirContents = try FileManager.default.contentsOfDirectory(atPath: resourcesPath)
//        let filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
//        for fileName in filteredFiles {
//            let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
//            let destURL = documentsUrl.appendingPathComponent(fileName)
//            do {
//                if !FileManager.default.fileExists(atPath: destURL.path) {
//                    try FileManager.default.copyItem(at: sourceURL, to: destURL) }
//                }
//            catch {
//                print("Error copying item: \(error)")
//            }
//        }
//        print("Resource files copied")
//    } catch {
//        print("Error getting directory contents: \(error)")
//    }
//}
//
//func copyResourceFiles() {
//    copyFilesFromBundleToDocumentsFolderWith(fileExtension: ".txt")
//}
