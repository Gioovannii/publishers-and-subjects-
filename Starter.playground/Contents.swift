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


import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Publisher") {
    // 1 Create notification name
    let myNotification = Notification.Name("MyNotification")
    
    // 2 Access notification center call it's publisher method and assign value to a constant
    let _ = NotificationCenter.default
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
