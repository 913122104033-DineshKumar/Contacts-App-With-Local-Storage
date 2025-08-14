import CoreData

class ContactsDataHandler
{

    private var context: NSManagedObjectContext
    
    init(_ context: NSManagedObjectContext)
    {
        self.context = context
    }
    
    public func fetchAllContacts(fetchController contactsFetchController: NSFetchedResultsController<Contacts>?)
    {
        do
        {
            try contactsFetchController?.performFetch()
        } catch
        {
            print("Contacts are not fetched")
        }
    }
    
    public func addContact(contactID ID: String, contactName name: String, contactNumber number: String)
    {
        
        let newContact = Contacts(context: self.context)
        
        newContact.contactID = ID
        newContact.contactName = name
        newContact.contactNumber = number
        
        do
        {
            try self.context.save()
        } catch
        {
            print("Contact is not added")
        }
    }
    
    public func updateContact(contactToUpdate contactDetails: Contacts?, updatedContactName updatedName: String, updatedContactNumber updatedNumber: String)
    {
        guard let contact = contactDetails else { return }
        
        contact.contactName = updatedName
        contact.contactNumber = updatedNumber
        
        do
        {
            try self.context.save()
        } catch
        {
            print("Contact is not updated")
        }
    }
    
    public func deleteContact(contactToDelete contact: Contacts)
    {
     
        self.context.delete(contact)
        
        do
        {
            try self.context.save()
        } catch
        {
            print("Contact is not deleted")
        }
    }
    
}

