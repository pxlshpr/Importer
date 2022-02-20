#if !os(macOS)
import Foundation

extension Notification.Name {
    static var didSave: Notification.Name { return .init("didSave") }
    static var didStartDownloading: Notification.Name { return .init("didStartDownloading") }
    static var didDownload: Notification.Name { return .init("didDownload") }
    static var didGetFoodResults: Notification.Name { return .init("didGetFoodResults") }
}
#endif
