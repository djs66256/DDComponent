import Foundation

protocol DataLoaderService: AnyObject {
    func loadData(completion: @escaping (String) -> Void)
}

final class MockDataLoaderService: DataLoaderService {
    func loadData(completion: @escaping (String) -> Void) {
        print("[ServiceDI] Loader — simulating 1s network delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion("✅ Data loaded at \(Date())")
        }
    }
}
