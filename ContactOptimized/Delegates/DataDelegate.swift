protocol DataDelegate: AnyObject
{
    func receiveContact(_ contact: Contacts?, contactID: String?, contactName: String, contactNumber: String)
}
