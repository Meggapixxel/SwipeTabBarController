//
//  Predicates.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 28.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//

import Foundation

// https://www.swiftbysundell.com/articles/predicates-in-swift/

//struct SamplePredicates {
//    
//    struct Predicate<T> {
//        var matches: (T) -> Bool
//
//        init(matcher: @escaping (T) -> Bool) {
//            matches = matcher
//        }
//    }
//    
//    struct SampleObject {
//        
//        let isCompleted: Bool
//        let dueDate: Date
//        let priority: Int
//        
//    }
//    
//    let items = [SampleObject]()
//    
//    func items(matching predicate: Predicate<SampleObject>) -> [SampleObject] {
//        items.filter(predicate.matches)
//    }
//    
//    var overdueItems0: [SampleObject] {
//        items(matching: .isOverdue)
//    }
//    var overdueItems1: [SampleObject] {
//        items(matching: !\.isCompleted && \.dueDate < Date())
//    }
//    
//    var futureItems: [SampleObject] {
//        items(matching: !\.isCompleted && \.dueDate > Date())
//    }
//
//    var uncompletedItems: [SampleObject] {
//        items(matching: \.isCompleted == false)
//    }
//    
//    var highPriorityItems: [SampleObject] {
//        items(matching: \.priority > 5)
//    }
//    
//}
//
//extension SamplePredicates.Predicate where T == SamplePredicates.SampleObject {
//    
//    static var isOverdue: Self {
//        Self {
//            !$0.isCompleted && $0.dueDate < Date()
//        }
//    }
//    
//}
//
//func ==<T, V: Equatable>(lhs: KeyPath<T, V>, rhs: V) -> SamplePredicates.Predicate<T> {
//    SamplePredicates.Predicate { $0[keyPath: lhs] == rhs }
//}
//prefix func !<T>(rhs: KeyPath<T, Bool>) -> SamplePredicates.Predicate<T> {
//    rhs == false
//}
//func ><T, V: Comparable>(lhs: KeyPath<T, V>, rhs: V) -> SamplePredicates.Predicate<T> {
//    SamplePredicates.Predicate { $0[keyPath: lhs] > rhs }
//}
//func <<T, V: Comparable>(lhs: KeyPath<T, V>, rhs: V) -> SamplePredicates.Predicate<T> {
//    SamplePredicates.Predicate { $0[keyPath: lhs] < rhs }
//}
//func &&<T>(lhs: SamplePredicates.Predicate<T>, rhs: SamplePredicates.Predicate<T>) -> SamplePredicates.Predicate<T> {
//    SamplePredicates.Predicate { lhs.matches($0) && rhs.matches($0) }
//}
//func ||<T>(lhs: SamplePredicates.Predicate<T>, rhs: SamplePredicates.Predicate<T>) -> SamplePredicates.Predicate<T> {
//    SamplePredicates.Predicate { lhs.matches($0) || rhs.matches($0) }
//}
//func ~=<T, V: Collection>(lhs: KeyPath<T, V>, rhs: V.Element) -> SamplePredicates.Predicate<T> where V.Element: Equatable {
//    SamplePredicates.Predicate { $0[keyPath: lhs].contains(rhs) }
//}
