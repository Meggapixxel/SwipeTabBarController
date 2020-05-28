//
//  Task.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 28.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

// https://www.swiftbysundell.com/articles/task-based-concurrency-in-swift/

struct Task {
    
    typealias Closure = (Controller) -> Void

    private let closure: Closure

    init(closure: @escaping Closure) {
        self.closure = closure
    }
    
}

extension Task {
    
    struct Controller {
        
        fileprivate let queue: DispatchQueue
        fileprivate let handler: (Output) -> Void

        func finish() {
            handler(.success(()))
        }

        func fail(with error: Error) {
            handler(.failure(error))
        }
        
    }
    
}

extension Task {
    
    typealias Output = Result<Void, Error>
    
}

extension Task {
    
    func perform(on queue: DispatchQueue = .global(), then handler: @escaping (Output) -> Void) {
        queue.async {
            let controller = Controller(queue: queue, handler: handler)
            self.closure(controller)
        }
    }
    
}

extension Task {
    
    static func group(_ tasks: [Task]) -> Task {
        Task { controller in
            let group = DispatchGroup()

            // To avoid race conditions with errors, we set up a private
            // queue to sync all assignments to our error variable
            let errorSyncQueue = DispatchQueue(label: "Task.ErrorSync")
            var anyError: Error?

            for task in tasks {
                group.enter()

                // It’s important to make the sub-tasks execute
                // on the same DispatchQueue as the group, since
                // we might cause unexpected threading issues otherwise.
                task.perform(on: controller.queue) { outcome in
                    switch outcome {
                    case .success:
                        break
                    case .failure(let error):
                        errorSyncQueue.sync {
                            anyError = anyError ?? error
                        }
                    }

                    group.leave()
                }
            }

            group.notify(queue: controller.queue) {
                if let error = anyError {
                    controller.fail(with: error)
                } else {
                    controller.finish()
                }
            }
        }
    }
    
}

extension Task {
    
    static func sequence(_ tasks: [Task]) -> Task {
        var index = 0

        func performNext(using controller: Controller) {
            guard index < tasks.count else {
                // We’ve reached the end of our array of tasks,
                // time to finish the sequence.
                return controller.finish()
            }

            let task = tasks[index]
            index += 1

            task.perform(on: controller.queue) { outcome in
                switch outcome {
                case .success:
                    performNext(using: controller)
                case .failure(let error):
                    // As soon as an error was occurred, we’ll
                    // fail the entire sequence.
                    controller.fail(with: error)
                }
            }
        }

        return Task(closure: performNext)
    }
    
}
