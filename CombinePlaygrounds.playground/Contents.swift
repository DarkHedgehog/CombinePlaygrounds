import UIKit
import Combine
import SwiftUI


public func main(action: () -> Void) {
    action()
}

main {
    var subscriptions = Set<AnyCancellable>()
    var data = TestClass()

    timerStart(timeRange: 1...1000) {
        let publisher = availableProducts()
        publisher
            .sink(receiveCompletion: { completion in
                if case .failure(let err) = completion {
                    print("Retrieving data failed with error \(err)")
                }
            }, receiveValue: { products in
                print("Retrieved products of size \(products.count)")
                data.model.products = products
            })
            .store(in: &subscriptions)
    }


    data.model.$products.sink {
        print("---")
        print($0)
    }

    CFRunLoopRun()

    func timerStart(timeRange: ClosedRange<Int>, handler: @escaping () -> Void) -> Timer {
        let interval = Double(Int.random(in: timeRange)) / 1000
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { timer in
            handler()
        }
        return timer
    }

    func availableProducts() -> AnyPublisher<[ProductShort], any Error> {
        guard let url = URL(string: "https://swiftcleancodemock.onrender.com/products") else {
            return AnyPublisher(
                Fail<[ProductShort], Error>(error: URLError(.cannotConnectToHost))
            )
        }

        let publisher = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .print()
            .decode(type: [ProductShort].self, decoder: JSONDecoder())
            .print()
            .share()
            .eraseToAnyPublisher()

        return publisher
    }
    struct ProductShort: Codable, Identifiable {
        let id: UUID
        let name: String
        let price: Double
        enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case price = "cost"
        }
    }

    class ModelData: ObservableObject {
        @Published var products: [ProductShort] = []
    }

    class TestClass {
        @ObservedObject var model = ModelData()
    }
}
