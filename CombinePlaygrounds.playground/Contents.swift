import UIKit
import Combine


public func main(action: () -> Void) {
    action()
}

main {
    typealias StringPublisher = PassthroughSubject<String, Never>

    var subscriptions = Set<AnyCancellable>()

    let stringArray = Array("abcdefghijklmnopqrstuvwxyz").map {
        String($0) + "foo"
    }


    let publisher = firstPublisher()
    let emojyPublisher = emojyPublisher()
    let mergedPublisher = StringPublisher()

    mergedPublisher
        .merge(with: emojyPublisher, publisher)
        .filter { !$0.isEmpty }
        .sink {
            print($0)
        }

    CFRunLoopRun()

    func firstPublisher() -> AnyPublisher<String, Never> {
        let queue = DispatchQueue(label: "Collect")
        let publisher = StringPublisher()
        let resultPublisher = publisher
            .collect(.byTime(queue, .milliseconds(500)))
                // here [String]
            .map { stringArrayToUnicodeScalarArray($0) }
                // here [UnicodeScalar]
            .map { $0.map { Character($0) }}
                // here [Character]
            .map { $0.reduce("", { $0 + String($1)})}
                // here String
            .eraseToAnyPublisher()

        randomlyPublish(strings: stringArray, for: publisher, withIntervalRange: 0...1000)

        return resultPublisher
    }

    func emojyPublisher() -> AnyPublisher<String, Never> {
        var startDate = Date()
        let publisher = StringPublisher()
        let emojyPublisher = publisher
            .map { _ in
                let interval = Date().timeIntervalSince(startDate)
                startDate = Date()
                if  interval < 0.9 {
                    return "😄"
                } else {
                    return ""
                }
            }
            .eraseToAnyPublisher()

        randomlyPublish(strings: stringArray, for: publisher, withIntervalRange: 0...3000)
        return emojyPublisher
    }

    func stringArrayToUnicodeScalarArray(_ values: [String]) -> [UnicodeScalar] {
        let scalar = values.map { $0.unicodeScalars.map { UnicodeScalar($0.value) } }
        return scalar.reduce([], +).compactMap { $0 }
    }

    func timerStart(timeRange: ClosedRange<Int>, handler: @escaping () -> Void) -> Timer {
        let interval = Double(Int.random(in: timeRange)) / 1000
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { timer in
            handler()
        }
        return timer
    }

    func randomlyPublish(strings: [String], for publisher: StringPublisher, withIntervalRange delayRangeMs: ClosedRange<Int>) {
        timerStart(timeRange: delayRangeMs) {
            publisher.send(strings[Int.random(in: 0..<strings.count)])
            randomlyPublish(strings: strings, for: publisher, withIntervalRange: delayRangeMs)
        }
    }
}
