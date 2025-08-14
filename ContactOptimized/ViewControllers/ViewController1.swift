import UIKit
import CoreData

class ViewController1: UIViewController, UITableViewDelegate
{
    private var context: NSManagedObjectContext
    
    private var contactsFetchController: NSFetchedResultsController<Contacts>?
    
    private var contactHandler: ContactsDataHandler
    
    private lazy var contactSearchController: UISearchController = UISearchController()
    
    private var currentID: Int = 0
    
    init()
    {
        guard let context = UIApplication.shared.delegate as? AppDelegate else { fatalError() }

        self.context = context.persistentContainer.viewContext
        
        self.contactHandler = ContactsDataHandler(self.context)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let contactTableView: UITableView =
    {
        let contactTableView = UITableView()
        
        contactTableView.register(
            CustomTableCell.self,
            forCellReuseIdentifier: "CustomTableCell"
        )
        contactTableView.translatesAutoresizingMaskIntoConstraints = false
        contactTableView.estimatedRowHeight = 300
        contactTableView.rowHeight = 70
        
        return contactTableView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setUIs()
        
        self.contactHandler.fetchAllContacts(fetchController: self.contactsFetchController)
        
        self.contactTableView.reloadData()
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
        
        self.view.addSubview(self.contactTableView)
        self.contactTableView.delegate = self
        self.contactTableView.dataSource = self
        
        self.setConstraints()
        
        self.configureFetchController()
        
        self.configureSearchController()
    }
    
    private func setConstraints()
    {
        NSLayoutConstraint.activate([
            
            self.contactTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            self.contactTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contactTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contactTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
    
    @objc private func addButtonTapAction()
    {
        let viewController2 = ViewController2(nil, self.currentID)
        self.currentID += 1
        viewController2.delegate = self
        self.navigationController?.pushViewController(viewController2, animated: true)
    }
    
    private func handleNavigation(contact: Contacts)
    {
        let viewController2 = ViewController2(contact, nil)
        viewController2.delegate = self
        self.navigationController?.pushViewController(viewController2, animated: true)
    }
    
}

extension ViewController1: UITableViewDataSource
{
    func tableView(_ contactTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = CustomTableCell()
        
        guard let contact = self.contactsFetchController?.object(at: indexPath) else { return cell }
        
        cell.configure(contact)
        cell.deleteButton?.addAction(
            UIAction
            { action in
                
                self.contactHandler.deleteContact(contactToDelete: contact)
                self.contactHandler.fetchAllContacts(fetchController: self.contactsFetchController)
                self.contactTableView.reloadData()
            },
            for: .touchUpInside
        )
        
        return cell
    }
    
    func tableView(_ contactTableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.contactsFetchController?.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ contactTableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        guard let contact = self.contactsFetchController?.object(at: indexPath) else { return }
        
        self.handleNavigation(contact: contact)
        
        self.contactTableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ViewController1: DataDelegate
{
    func receiveContact(
        _ contact: Contacts?,
        contactID: String?,
        contactName: String,
        contactNumber: String
    ) {
        
        if contact == nil
        {
            guard let ID = contactID else { return }
            
            self.contactHandler.addContact(
                contactID: ID,
                contactName: contactName,
                contactNumber: contactNumber
            )
        } else
        {
            self.contactHandler.updateContact(
                contactToUpdate: contact,
                updatedContactName: contactName,
                updatedContactNumber: contactNumber
            )
        }
        
        self.contactHandler.fetchAllContacts(fetchController: self.contactsFetchController)
        self.contactTableView.reloadData()
    }
}

extension ViewController1: UISearchBarDelegate, UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController)
    {
        let searchQuery = searchController.searchBar.text
        
        guard let searchText = searchQuery else { return }
        
        var searchPredicate: NSPredicate? = nil
        
        if !searchText.isEmpty
        {
            searchPredicate = NSPredicate(format: "(contactName contains[cd] %@ OR contactNumber contains[cd] %@)", searchText, searchText)
        }
        
        self.contactsFetchController?.fetchRequest.predicate = searchPredicate
        self.contactHandler.fetchAllContacts(fetchController: self.contactsFetchController)
        
        self.contactTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        searchBar.text = ""
        
        self.contactsFetchController?.fetchRequest.predicate = nil
        self.contactHandler.fetchAllContacts(fetchController: self.contactsFetchController)
        
        self.contactTableView.reloadData()
    }
    
    private func configureSearchController()
    {
        self.contactSearchController = UISearchController(searchResultsController: nil)
        self.contactSearchController.searchResultsUpdater = self
        self.contactSearchController.searchBar.delegate = self
        self.contactSearchController.searchBar.placeholder = "Search"
        self.contactSearchController.searchBar.sizeToFit()
        
        self.contactTableView.tableHeaderView = self.contactSearchController.searchBar
    }
    
}

extension ViewController1: NSFetchedResultsControllerDelegate
{
    private func configureFetchController()
    {
        let request = Contacts.fetchRequest()
        let sort = NSSortDescriptor(key: "contactID", ascending: true)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 15
        
        self.contactsFetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: self.context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.contactsFetchController?.delegate = self
    }
}
