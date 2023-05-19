import UIKit
import Combine


var subscriptions = Set<AnyCancellable>()

public func main(action: () -> Void) {
    action()
}

// 1. Создайте пример, который публикует коллекцию чисел от 1 до 100, и используйте операторы фильтрации, чтобы выполнить следующие действия:
// Пропустите первые 50 значений, выданных вышестоящим издателем.
// Возьмите следующие 20 значений после этих первых 50.
// Берите только чётные числа.
main {
    print("First ----")
    [Int](1 ... 100)
        .publisher
        .dropFirst(50)
        .prefix(20)
        .filter { $0.isMultiple(of: 2) }
        .sink {
            print($0)
        }
        .store(in: &subscriptions)
}

// 2. Создайте пример, который собирает коллекцию строк, преобразует её в коллекцию чисел и вычисляет среднее арифметическое этих значений.
main {
    print("Second ----")
    let publisher = ["a", "1", "10", "b", "0x0a", "asf", "5"].publisher

    let intPublisher = publisher.compactMap { Int($0) }
    intPublisher
        .reduce(0, { accum, next in accum + next })
        .sink {
            let count = intPublisher.sequence.count
            let adv = $0 / count
            print("sum = \($0), count = \(count), adv = \(adv)")
        }
        .store(in: &subscriptions)
}


main {
    print("3 ----")
    let publisher = [5, 6, 7].publisher
    publisher.prepend([3, 4])
        .prepend(Set(1...2))
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

main {

}
