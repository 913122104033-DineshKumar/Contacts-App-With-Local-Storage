import UIKit

class ViewController1: UIViewController, UITableViewDelegate
{
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var contactList: [Contact] = []
    private var displayContactList: [Contact] = []
    
    private var currentID: Int = 0
    
    private var contactTableSize: Int = 0
    
    private lazy var indexToUpdate: Int? = nil
    
    private lazy var contactSearchController: UISearchController = UISearchController()
    
    private let contacTableView: UITableView =
    {
        let contacTableView = UITableView()
        
        contacTableView.register(
            CustomTableCell.self,
            forCellReuseIdentifier: "CustomTableCell"
        )
        contacTableView.translatesAutoresizingMaskIntoConstraints = false
        contacTableView.estimatedRowHeight = 300
        contacTableView.rowHeight = 70
        
        return contacTableView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setUIs()
    }
    
}

extension ViewController1
{
    private func setUIs()
    {
        self.title = "Contacts"
        let configurations = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.fill.badge.plus", withConfiguration: configurations),
            style: .done,
            target: self,
            action: #selector(self.addButtonTapAction)
        )
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(self.contacTableView)
        self.contacTableView.delegate = self
        self.contacTableView.dataSource = self
        
        self.configureSearchController()
        
        self.setConstraints()
    }
    
    private func setConstraints()
    {
        NSLayoutConstraint.activate([
            
            self.contacTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            self.contacTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contacTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contacTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
    
    @objc private func addButtonTapAction()
    {
        let viewController2 = ViewController2(nil, self.currentID)
        self.currentID += 1
        viewController2.delegate = self
        self.navigationController?.pushViewController(viewController2, animated: true)
    }
    
    private func updateContactData(contactToUpdate: Contact)
    {
        let ID = contactToUpdate.getID()
        
        if let indexInDisplayList = self.displayContactList.firstIndex(where: { $0.getID() == ID })
        {
            self.displayContactList[indexInDisplayList] = contactToUpdate
        }
        
        if let indexInContactList = self.contactList.firstIndex(where: { $0.getID() == ID })
        {
            self.contactList[indexInContactList] = contactToUpdate
        }
        
        self.contacTableView.reloadData()
    }
    
    private func onDelete(_ ID: String)
    {
        
        if let indexInDisplayList = self.displayContactList.firstIndex(where: { $0.getID() == ID })
        {
            self.displayContactList.remove(at: indexInDisplayList)
        }
        
        if let indexInContactList = self.contactList.firstIndex(where: { $0.getID() == ID })
        {
            self.contactList.remove(at: indexInContactList)
        }

        self.contacTableView.reloadData()
    }
    
    private func handleNavigation(contact: Contact)
    {
        let viewController2 = ViewController2(contact, nil)
        viewController2.delegate = self
        self.navigationController?.pushViewController(viewController2, animated: true)
    }
    
}

extension ViewController1: UITableViewDataSource
{
    func tableView(_ contacTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CustomTableCell()
        
        cell.configure(self.displayContactList[indexPath.row])
        cell.deleteButton?.addAction(
            UIAction
            { action in
                self.onDelete(self.displayContactList[indexPath.row].getID())
            },
            for: .touchUpInside
        )
        
        return cell
    }
    
    func tableView(_ contacTableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.displayContactList.count
    }
    
    func tableView(_ contacTableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        self.handleNavigation(contact: self.displayContactList[indexPath.row])
        
        self.contacTableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ViewController1: DataDelegate
{
    func receiveContact(_ contact: Contact, isCreated: Bool)
    {
        if isCreated
        {
            self.displayContactList.removeAll()
            self.contactList.append(contact)
            self.displayContactList = self.contactList
            self.contacTableView.reloadData()
        } else
        {
            self.updateContactData(contactToUpdate: contact)
        }
    }
}

extension ViewController1: UISearchBarDelegate, UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchQuery = searchController.searchBar.text
        
        guard let searchText = searchQuery else { return }
        
        self.displayContactList.removeAll()
        
        if searchText.isEmpty
        {
            self.displayContactList = self.contactList
        }
        
        var filteredList: [Contact] = []
        
        for index in 0..<self.contactList.count
        {
            if self.contactList[index].name.lowercased().starts(with: searchText.lowercased()) || self.contactList[index].number.starts(with: searchText)
            {
                filteredList.append(self.contactList[index])
            }
        }
        
        self.displayContactList.removeAll()
        self.displayContactList = filteredList
        
        self.contacTableView.reloadData()
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool
    {
        
        guard let searchQuery = searchBar.text else { return false }
        
        self.displayContactList.removeAll()
        
        if searchQuery.isEmpty
        {
            self.displayContactList = self.contactList
        } else
        {
            self.displayContactList = []
        }
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.displayContactList.removeAll()
        self.displayContactList = self.contactList
        self.contacTableView.reloadData()
    }
    
    private func configureSearchController()
    {
        self.contactSearchController = UISearchController(searchResultsController: nil)
        self.contactSearchController.searchResultsUpdater = self
        self.contactSearchController.searchBar.delegate = self
        self.contactSearchController.searchBar.placeholder = "Search"
        self.contactSearchController.searchBar.sizeToFit()
        
        self.contacTableView.tableHeaderView = self.contactSearchController.searchBar
    }
    
}

extension ViewController1
{
    private func fetchAllContacts()
    {
        do
        {
            let contacts = try self.context.fetch(Contacts.fetchRequest())
            
            contacts.forEach { contact in
                
                guard let name = contact.contactName,
                let ID = contact.contactID,
                let number = contact.contactNumber else { return }
                
                self.contactList.append(
                    Contact(
                        contactID: ID,
                        contactName: name,
                        contactNumber: number
                    )
                )
            }
            
        } catch
        {
            print("Contacts are not fetched")
        }
    }
    
    private func addContact(contactID ID: String, contactName name: String, contactNumber number: String)
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
    
    private func updateContact(contactToUpdate contact: Contacts, updatedContactName updatedName: String, updatedContactNumber updatedNumber: String)
    {
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
    
    private func deleteContact(contactToDelete contact: Contacts)
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
