import UIKit

class Contact
{
    private let ID: String
    private(set) var name: String
    private(set) var number: String
    
    init(contactID ID: String, contactName name: String, contactNumber number: String)
    {
        self.ID = ID
        self.name = name
        self.number = number
    }
    
    public func setName(name: String)
    {
        self.name = name
    }
    
    public func setNumber(number: String)
    {
        self.number = number
    }
    
    public func getID() -> String
    {
        return self.ID
    }
    
    public func toString() -> String
    {
         return """
            \(self.name)
            \(self.number)
        """
    }
    
}
