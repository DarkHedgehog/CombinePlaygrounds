import UIKit
import Combine


let center = NotificationCenter.default
let myNotification = Notification.Name("SimpleTypeNotification")
let publisher = NotificationCenter.default .publisher(for: myNotification, object: nil)

let observer = center.addObserver(
    forName: myNotification, object: nil, queue: nil) { notification in
        print("SimpleTypeNotification received!")
    }

let subscription = publisher.sink{ value in
    print("subscription \(value.object) received!")
}

center.post(name: myNotification, object: nil) // 6
center.post(name: myNotification, object: 1) // 6
center.post(name: myNotification, object: "123aa") // 6
center.removeObserver(observer)
subscription.cancel()

let just = Just("Hello world!")

_ = just.sink(receiveCompletion: {
    print("just Received completion", $0)
}, receiveValue: {
    print("just Received value", $0)
})
