import XCTest
@testable import Importer

final class ImporterTests: XCTestCase {
    
    func testFoodFromJSON() async throws {
        guard let mfpFood = await MFPFood.getFoodAt(urlString: urlString) else {
            XCTFail("Couldn't get food json from json string")
            return
        }
        
        XCTAssertTrue(true)
    }
}

//let urlString = "https://www.myfitnesspal.com/food/calories/banana-1774572771"
let urlString = "https://www.myfitnesspal.com/food/calories/banana-platano-1961211846"
