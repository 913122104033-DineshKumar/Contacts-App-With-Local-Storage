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

extension Contacts
{
    public func toString() -> String
    {
        
        guard let name = self.contactName,
              let number = self.contactNumber else { return "" }
        
        return """
           \(name)
           \(number)
       """
    }
    
    public static func buildContact(contactID ID: String, contactName name: String, contactNumber number: String, appContext context: NSManagedObjectContext) -> Contacts
    {
        let contact = Contacts(context: context)
        
        contact.contactID = ID
        contact.contactName = name
        contact.contactNumber = number
        
        return contact
    }
    
}
