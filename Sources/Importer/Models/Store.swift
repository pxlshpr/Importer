#if !os(macOS)
import SwiftUI
import TabularData

enum TypeStatus: Int, CaseIterable {
    case allValid
    case haveUnknowns
    case haveInvalids
    
    var description: String {
        switch self {
        case .allValid:
            return "All"
        case .haveUnknowns:
            return "Unknown"
        case .haveInvalids:
            return "Invalid"
        }
    }
}

public class Store: NSObject, ObservableObject {
    static let shared = Store()

    @Published var processedSizes: [ProcessedSize] = []
    @Published var processingIndex: Int? = nil
    @Published var foodsCount: Int = 0

    @Published var foods: [MyFitnessPalFood] = []

    @Published var status: TypeStatus = .allValid    

    var typesForServings: [String: ServingType] = [:]

    func start() {
        /// load the correct data file if it exists
        loadBackupFile()
//        downloadAndWriteHtmlFiles()
        processFiles() {
            self.updateTestUnits()
        }
    }
    
    func updateStatus() {
        var status = TypeStatus.allValid
        for unit in processedSizes {
            if let isCorrect = unit.isCorrect {
                if !isCorrect {
                    self.status = .haveInvalids
                    return
                }
            } else {
                status = .haveUnknowns
            }
        }
        self.status = status
    }
    
//    func download(url: URL) {
//        DispatchQueue.global(qos: .userInteractive).async {
//            print("Time to download: \(url.absoluteString.filenameForMfpFileWithoutTimestamp)")
//
//            var htmls: [String: String] = [:]
//
//            let urlString = url.absoluteString
//            if urlHasBeenDownloaded(urlString) {
//                print("↩️ Skipping \(urlString.filenameForMfpFileWithoutTimestamp)")
//            } else {
//                print("⬇️ Downloading \(urlString.filenameForMfpFileWithoutTimestamp)")
//                let html = scrapeHtml(from: urlString)
//                htmls[urlString] = html
//                lastDownloadedUrlString = url.absoluteString
//                sleep(2)
//            }
//
//            print("📝 Writing files to: \(documentsUrl)")
//            writeHtmlFiles(htmls)
//            Store.shared.processFiles() {
//                DispatchQueue.main.async {
//                    Store.shared.updateTestUnits(postNotification: true)
//                }
//            }
//        }
//    }
    
    func updateTestUnits(postNotification: Bool = false) {
        for i in 0..<processedSizes.count {
            if let correctType = self.typesForServings[processedSizes[i].name] {
                processedSizes[i].isCorrect = correctType == processedSizes[i].type
                
                if correctType != processedSizes[i].type {
                    processedSizes[i].correctType = correctType
                }
            }
        }
        updateStatus()
        if postNotification {
            NotificationCenter.default.post(name: .didDownload, object: nil)
        }
    }
    
    func processFiles(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            let jsons = jsonsFromFiles
            DispatchQueue.main.async {
                self.foodsCount = jsons.count
            }
            for (jsonString, urlString) in jsons {
                let json = getJson(from: jsonString)
                
                guard let food = MyFitnessPalFood(json: json, urlString: urlString) else {
                    fatalError("Couldn't get food from: \(jsons)")
                }
                
                DispatchQueue.main.async {
                    self.process(food, urlString: urlString)
                }
            }
            DispatchQueue.main.async {
                self.processingIndex = nil
                completion()
                self.foods = self.foods.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })
                
                /// now append processedSizes to foods
                self.appendProcessedSizesToFoods()
            }
        }
    }
    
    func appendProcessedSizesToFoods() {
        for size in processedSizes {
            for food in size.foods {
                guard let foodIndex = foods.firstIndex(of: food) else {
                    continue
                }
                foods[foodIndex].appendSize(processedSize: size)
            }
        }
    }
    
    func process(_ food: MyFitnessPalFood, urlString: String) {
        if !foods.contains(food) {
            foods.append(food)
        }
        
        processingIndex = (processingIndex ?? 0) + 1
        food.scrapedSizes.forEach {
            var processedSize = ProcessedSize(servingSize: $0)
            /// if we have an entry for it in the servingsTable, mark it as correct or wrong depending on whether it matches the provided type
            if let correctType = typesForServings[$0.name] {
                processedSize.isCorrect = correctType == processedSize.type
                if correctType != processedSize.type {
                    processedSize.correctType = correctType
                }
            }
            
            if let index = processedSizes.firstIndex(where: { $0 == processedSize }) {
                /// exists, simply append the urlString
                if !processedSizes[index].foods.contains(food) {
                    processedSizes[index].foods.append(food)
                    processedSizes[index].foods.sort {
                        ($0.name ?? "") < ($1.name ?? "")
                    }
                }
            } else {
                /// doesn't exist, append it
                processedSize.foods = [food]
                
                processedSizes.append(processedSize)
                processedSizes.sort {
                    ($0.type.rawValue, $0.name) < ($1.type.rawValue, $1.name)
                }
            }
        }
    }
//    func importBackup(from url: URL) {
//        do {
//            if FileManager.default.fileExists(atPath: servingTypesFileUrl.path) {
//                try FileManager.default.removeItem(at: servingTypesFileUrl)
//            }
//            try FileManager.default.moveItem(at: url, to: servingTypesFileUrl)
//            print("Moved: \(url) to \(documentsUrl)")
//            loadBackupFile()
//            updateTestUnits()
//        } catch {
//            fatalError("Error moving backup file \(url): \(error)")
//        }
//    }
    
    func save(inBackground: Bool = false) {
        /// create a dataFrame with `serving, type`
        if !FileManager.default.fileExists(atPath: backupFolderUrl.path) {
            do {
                try FileManager.default.createDirectory(at: backupFolderUrl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating backup folder: \(error)")
                return
            }
        }
        servingTypesDataFrame.write(to: servingTypesFileUrl)
        ServingType.allCases.forEach {
            backupString(for: $0).write(to: backupFileUrl(for: $0))
//            dataFrame(for: $0).write(to: backupFileUrl(for: $0))
        }
        print("Wrote files to: \(backupFolderUrl.absoluteString)")
        self.zipFiles(inBackground: inBackground)
    }
    
    func zipFiles(inBackground: Bool) {
//        do {
//            if FileManager.default.fileExists(atPath: zipUrl.path) {
//                try FileManager.default.removeItem(at: zipUrl)
//            }
//            try FileManager.default.zipItem(at: backupFolderUrl,
//                                            to: zipUrl,
//                                            shouldKeepParent: false)
//            print("Backup created at: \(zipUrl.absoluteString)")
//            if !inBackground {
//                NotificationCenter.default.post(name: .didSave, object: nil)
//            }
//        } catch {
//            print("Creation of ZIP archive failed with error:\(error)")
//        }
    }
    
    func importBackup(from url: URL) {
        clearBackupFolder()
        extractBackupFile(at: url)
        loadBackupFile()
        processFiles() {
            self.updateTestUnits()
        }

//        clearDocumentsFolderOfExtraFiles()
//
//        guard let schemaVersion = backupSchemaVersion else {
//            log.error("No schema version found. Abandoning import.")
//            return
//        }
//
//        clearDataStore()
//        importBackupData(for: schemaVersion)
//        addSaveNotificationObserver()
//        saveMainContext()
    }

    func extractBackupFile(at url: URL) {
//        do {
//            try FileManager.default.unzipItem(at: url, to: backupFolderUrl)
//        } catch {
//            print("Error unzipping")
//            return
//        }

//            //TODO: Read in all files from directory instead of using aboslute values
//        for file in BackupFiles {
//            let path = documentsPath + "Documents/\(file)"
//            let toPath = documentsPath + "\(file)"
//            log.info("Moving: \(path)")
//            log.info("To: \(documentsPath)")
//            do {
//                try FileManager.default.moveItem(atPath: path, toPath: toPath)
//            } catch {
//                log.error("Error moving backup file")
//            }
//        }
//        log.debug("After File removal:")
//        printDocumentsContents()
//
//        let pathToDelete = documentsPath + "Documents"
//        let urlToDelete = URL(fileURLWithPath: pathToDelete, isDirectory: true)
//        do {
//            try FileManager.default.removeItem(at: urlToDelete)
//        } catch {
//            log.error("Error removing item")
//            return false
//        }
//        return true
    }

    func status(for type: ServingType) -> TypeStatus {
        var status = TypeStatus.allValid
        for unit in processedSizes.filter({ $0.type == type }) {
            if let isCorrect = unit.isCorrect {
                if !isCorrect {
                    return .haveInvalids
                }
            } else {
                status = .haveUnknowns
            }
        }
        return status
    }
    
    /// load the csv file of correct types for servings
    /// save this in a dict here in the store so we can look it up
    func loadBackupFile() {
        typesForServings = [:]
        guard let dataFrame = DataFrame.read(from: servingTypesFileUrl) else {
            return
        }
        
        for row in dataFrame.rows {
            guard let serving = row["serving"] as? String,
                  let type = row["type"] as? Int
            else {
                fatalError("Unable to read dataFrame row: \(row)")
            }
            
            guard !typesForServings.keys.contains(serving) else {
                fatalError("Duplicate serving in csv file")
            }
            
            guard let servingType = ServingType(rawValue: type) else {
                fatalError("Invalid serving type in csv file")
            }
            
            typesForServings[serving] = servingType
        }
        print("Imported \(dataFrame.rows) servings")
    }

    
    var servingTypesDataFrame: DataFrame {
        var servings: [String?] = []
        var types: [Int?] = []
        
        for size in processedSizes {
            guard let isCorrect = size.isCorrect else {
                /// skip any that haven't been marked
                continue
            }
            guard !servings.contains(size.name) else {
                print("Serving exists")
                continue
            }
            servings.append(size.name)
            if isCorrect {
                types.append(size.type.rawValue)
            } else if let correctType = size.correctType {
                types.append(correctType.rawValue)
            } else {
                fatalError("Incorrect testUnit with a missing correctType")
            }
        }
        
        let dataFrame: DataFrame = [
            "serving": servings,
            "type": types
        ]
        return dataFrame
    }

    func backupString(for type: ServingType) -> String {
        let validStrings = processedSizes.filter {
            if let isCorrect = $0.isCorrect, isCorrect, $0.type == type {
                return true
            } else if let correctType = $0.correctType, correctType == type {
                return true
            }
            return false
        }.map { $0.name }
        let invalidStrings = processedSizes.filter{!validStrings.contains($0.name)}.map{$0.name}
        
        return validStrings
            .joined(separator: "\n")
            .appending("\n\n")
            .appending("Invalids\n")
            .appending("========\n")
            .appending(invalidStrings.joined(separator: "\n"))
    }

    func dataFrame(for type: ServingType) -> DataFrame {
        var servings: [String?] = []
        
        for testUnit in processedSizes {
            if let isCorrect = testUnit.isCorrect, isCorrect, testUnit.type == type {
                servings.append(testUnit.name)
            } else if let correctType = testUnit.correctType, correctType == type {
                servings.append(testUnit.name)
            }
        }
        
        let dataFrame: DataFrame = [
            "serving": servings
        ]
        return dataFrame
    }
}

extension String {
    func write(to url: URL) {
        do {
            try write(to: url, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to write string to: \(url)")
        }
    }
}

extension Store: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
//            NotificationCenter.default.post(name: .didPickRestoreFile, object: nil)
            importBackup(from: url)
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true) {
        }
        print("cancelled")
    }
}

var backupFolderUrl: URL {
    documentsUrl.appendingPathComponent("backup", isDirectory: true)
}

var imagesFolderUrl: URL {
    backupFolderUrl.appendingPathComponent("images", isDirectory: true)
}

var jsonsFolderUrl: URL {
    backupFolderUrl.appendingPathComponent("jsons", isDirectory: true)
}
func urlForFileInDocuments(named filename: String) -> URL {
    documentsUrl.appendingPathComponent(filename)
}
func urlForFileInBackupFolder(named filename: String) -> URL {
    backupFolderUrl.appendingPathComponent(filename)
}
var servingTypesFileUrl: URL { urlForFileInBackupFolder(named: "servingTypes.csv") }

func backupFileUrl(for type: ServingType) -> URL {
    let filename = type.description.lowercased().replacingOccurrences(of: " ", with: "-")
    return urlForFileInBackupFolder(named: "\(filename).txt")
}

var zipUrl: URL {
    urlForFileInDocuments(named: "Importers-Data.zip")
}

func clearBackupFolder() {
    let fileManager = FileManager.default
    do {
        let filePaths = try fileManager.contentsOfDirectory(atPath: backupFolderUrl.path)
        for filePath in filePaths {
            try fileManager.removeItem(atPath: backupFolderUrl.path + "/" + filePath)
        }
    } catch {
        print("Could not clear backup folder: \(error)")
    }
}
#endif
