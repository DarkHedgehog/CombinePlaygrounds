import UIKit
import Combine


public func main(action: () -> Void) {
    action()
}

main {
    var subscriptions = Set<AnyCancellable>()

    let publisher = availableProducts()

    let subscription1 = publisher
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Retrieving data failed with error \(err)")
            }
        }, receiveValue: { products in
            print("Retrieved products of size \(products.count)")
            products.forEach {
                print ("\($0.name): \($0.price)")
            }
        })
        .store(in: &subscriptions)

    let subscription2 = publisher
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Retrieving data failed with error \(err)")
            }
        }, receiveValue: { products in
            print("Retrieved products of size \(products.count)")
            products.forEach {
                print ("\($0.name): \($0.price)")
            }
        })
        .store(in: &subscriptions)

    CFRunLoopRun()

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

}
