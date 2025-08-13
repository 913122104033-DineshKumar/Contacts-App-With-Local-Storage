//
//  Contacts+CoreDataProperties.swift
//  ContactOptimized
//
//  Created by Dinesh Kumar K K on 13/08/25.
//
//

import Foundation
import CoreData


extension Contacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contacts> {
        return NSFetchRequest<Contacts>(entityName: "Contacts")
    }

    @NSManaged public var contactName: String?
    @NSManaged public var contactNumber: String?
    @NSManaged public var contactID: String?

}

extension Contacts : Identifiable {

}
