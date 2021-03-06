/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

// MARK: - Understanding

"""
Publisher           Subscriber
    <----- Subscribes -------- 1
   2 - gives subscription ---->
    <----- Request values ---- 3
   4 ----- send values ------->
   5 ---- Send completion ---->

"""

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Publisher") {
    // 1 Create notification name
    let myNotification = Notification.Name("MyNotification")
    
    // 2 Access notification center call it's publisher method and assign value to a constant
    let subscription = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    
    // 3 Get a handle to the notification center
    let center = NotificationCenter.default
    
    // 4 Create observer to listen for notification
    let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { notification in
        print("Notification received!")
    }
    // 5 Post notification with that name
    center.post(name: myNotification, object: nil)
    
    // 6 Remove observer from notification center
    center.removeObserver(observer)
}


example(of: "Subscriber") {
    
    let myNotification = Notification.Name("MyNotification")
    
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    
    let center = NotificationCenter.default
    
    
    // 1 Create subscribtion by calling sink on publisher
    let subscription = publisher
        .sink { _ in
            print("Notification creceived from a publisher!")
        }
    
    // 2 Post notification
    center.post(name: myNotification, object: nil)
    
    // 3 cancel subscription
    subscription.cancel()
}

example(of: "Just") {
    // 1 Create pubkisher using Just => create publisher from a primitive value type
    let just = Just("Hello world!")
    
    // 2 Create subscription to the publisher and print messages
    _ = just
        .sink(
            receiveCompletion: {
                print("Received completion", $0)
            },
            receiveValue: {
                print("Received value", $0)
            })
    _ = just
        .sink(
            receiveCompletion: {
                print("Received completion (another)", $0)
            }, receiveValue: {
                print("Received value (another)", $0)
            })
}

example(of: "assign(to:on:)") {
    // 1 Define class with a property that has a didSet that prints new value
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    
    // 2create an instance
    let object = SomeObject()
    
    // 3 Create a pusblisher from an array of strings
    let publisher = ["Hello", "world!"].publisher
    
    //4 Subscribe to the publisher, assigning each value received to the value property of the object
    _ = publisher
        .assign(to: \.value, on: object)
}

example(of: "assign(to:)") {
    // 1 Define and create an instance of a class with propert annoted with @published property wrapper
    // Which create a publisher for  value
    class SomeObject {
        @Published var value = 0
    }
    
    let object = SomeObject()
    
    // 2 Use $ prefix on @Published property to gain access to its underlying publisher, subscribe to it and print values
    object.$value
        .sink {
            print($0)
        }
    
    // 3 Create a publisher of numbers and assign each values it emits to the value publisher of object
    // note the use of & to denout inout reference to property
    (0..<10).publisher
        .assign(to: &object.$value)
}

// MARK: - Custom subscriber

example(of: "Custom Subscriber") {
    // 1 Create publisher of integers range's publisher property
    let publisher = (1...6).publisher
    
    // 2 Custom subscriber
    final class IntSubscriber: Subscriber {
        // 3 TypeAlias => Subscriber can receive Int input / will never receive error
        typealias Input = Int
        typealias Failure = Never
        
        // 4 Methods called by publisher using call on subscription specify subscriber receive 3 subs max.
        func receive(subscription: Subscription) {
            subscription.request(.max(3))
        }
        
        // 5 print each values nd return none
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            return .none
        }
        
        // 6 Print completion
        func receive(completion: Subscribers.Completion<Never>) {
            print("Receive completion", completion)
        }
    }
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}

// MARK: - Hello future

//// Async produce single result and complete
//example(of: "Future") {
//    func futurIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
//        Future<Int, Never> { promise in
//            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
//                promise(.success(integer + 1))
//            }
//        }
//    }
//
//    // 1 Create future using function specify integer passed after 3 second delay
//    let future = futurIncrement(integer: 1, afterDelay: 3)
//
//    // 2 subscribe to print receive value and completion even and store result in subscriptions
//    future
//        .sink(receiveCompletion: { print($0) },
//              receiveValue: { print($0) })
//        .store(in: &subscriptions)
//
//    future
//        .sink(receiveCompletion: { print("Second", $0)},
//              receiveValue: { print("Second", $0) })
//        .store(in: &subscriptions)
//
//    print("Original")
//}

// MARK: - Hello subject

example(of: "PassthroughSubject") {
    // 1 Custom error type
    enum MyError: Error {
        case test
    }
    
    
    // 2 custom subscriber receive string and myError errors
    final class StringSubscriber: Subscriber {
        
        typealias Input = String
        typealias Failure = MyError
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value", input)
            // 3 adjust demand base on value
            return input == "World" ? .max(1) : .none
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received Completion", completion)
        }
    }
    
    // 4 create an instance
    let subscriber = StringSubscriber()
    
    // 5 Create an instance of Passthrough of type String
    let subject = PassthroughSubject<String, MyError>()
    
    // 6 subscribe subscriber to subject
    subject.subscribe(subscriber)
    
    // 7 create another subscription using sink
    let subscription = subject
        .sink(receiveCompletion: { completion in
            print("Received Completion (sink)", completion)
        }, receiveValue: {value in
            print("Received value (sink)", value)
        })
    
    subject.send("Hello")
    subject.send("World")
    
    // 8. Cancel second subscription
    subscription.cancel()
    
    // 9. Send another value
    subject.send("Still here")
    
    subject.send(completion: .failure(MyError.test))
    subject.send(completion: .finished)
    subject.send("How about another one")
}

example(of: "CurrentValueSubject") {
    // 1 create a subscription set
    var subcriptions = Set<AnyCancellable>()
    
    // 2 Create a currentValueSubject of type Int and Never. This will publish n error with initial value of 0
    let subject = CurrentValueSubject<Int, Never>(0)
    
    // 3 create a subscription to the subject and print values received from it
    subject
        .print()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions ) // 4 Store the subscription
    subject.send(1)
    subject.send(2)
    print(subject.value)
    
    subject.value = 3
    print(subject.value)
    
    subject
        .print()
        .sink(receiveValue: { print("Second subscriptions:", $0) })
        .store(in: &subscriptions)
    subject.send(completion: .finished)
}

// MARK: - Dynamically adjusting demand

example(of: "Dynamically adjusting on demand") {
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Receive value", input)
            
            switch input {
            case 1:
                return .max(2) // 1 The new max is 4 (original max of 2 + new max of 2)
            case 3:
                return .max(1) // 2 The new max is 5 (previous 4 + new 1)
            default:
                return .none // 3 Max remains 5 (previous 4 + new 0)
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Receive completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    
    let subject = PassthroughSubject<Int, Never>()
    
    subject.subscribe(subscriber)
    
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
    
    // Last value not printed out
}

// MARK: - Type erasure

example(of: "Type erasure") {
    // 1 Create passthrough subject
    let subject = PassthroughSubject<Int, Never>()
    
    // 2 Create a type erase subject
    let publisher = subject.eraseToAnyPublisher()
    
    // 3 subscribe to type erased publisher
    publisher
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    // 4 send new value through passthrough subject
    subject.send(0)
    
    //publisher.send(1)
}

