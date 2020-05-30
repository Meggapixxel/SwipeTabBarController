//
//  AuthorDO+CoreDataProperties.swift
//  SwipeTabBarController
//
//  Created by Vadim Zhydenko on 27.05.2020.
//  Copyright © 2020 Vadym Zhydenko. All rights reserved.
//
//

import CoreData

extension AuthorDO {

    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var commits: NSSet

}

// MARK: Generated accessors for commits
extension AuthorDO {

    @objc(addCommitsObject:)
    @NSManaged public func addToCommits(_ value: CommitDO)

    @objc(removeCommitsObject:)
    @NSManaged public func removeFromCommits(_ value: CommitDO)

    @objc(addCommits:)
    @NSManaged public func addToCommits(_ values: NSSet)

    @objc(removeCommits:)
    @NSManaged public func removeFromCommits(_ values: NSSet)

}
