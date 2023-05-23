import UIKit
import Combine


public func main(action: () -> Void) {
    action()
}

main {
    guard let url = URL(string: "https://api.domainsdb.info/v1/domains/search?domain=facebook&zone=com") else { return }

    let subscription = URLSession.shared .dataTaskPublisher(for: url) .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
            print("Retrieving data failed with error \(err)")
        }
    }, receiveValue: { data, response in
        print("Retrieved data of size \(data.count), response = \(response)") }
    )
}
