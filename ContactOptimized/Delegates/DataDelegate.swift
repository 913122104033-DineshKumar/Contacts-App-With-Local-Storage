protocol DataDelegate: AnyObject
{
    func receiveContact(_ contact: Contact, isCreated: Bool)
}
