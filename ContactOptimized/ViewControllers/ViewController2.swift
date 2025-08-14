import UIKit

class ViewController2: UIViewController, UITextFieldDelegate
{
    
    weak var delegate: DataDelegate?
    private var contact: Contacts?
    
    private var currentID: Int?
    
    init(_ contact: Contacts?, _ currentID: Int?)
    {
        self.contact = contact
        self.currentID = currentID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private let contactNameLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Contact Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private let contactNameField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8
        
        return textField
    }()
    
    private let contactNumberLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Contact Number"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private let contactNumberField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 8
        
        return textField
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.setUIs()
    }
    
    private func setUIs()
    {
        self.view.addSubview(self.contactNameLabel)
        self.title = "Contact Details"
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.contactNameField.delegate = self
        self.view.addSubview(self.contactNameField)
        
        self.view.addSubview(self.contactNumberLabel)
        
        self.contactNumberField.delegate = self
        self.view.addSubview(self.contactNumberField)
        
        self.submitButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        self.view.addSubview(self.submitButton)
        
        self.setConstraints()
        
        guard let name = contact?.contactName,
              let number = contact?.contactNumber else { return }
        
        self.contactNameField.text = name
        self.contactNumberField.text = number
    }
    
    private func setConstraints()
    {
        
        NSLayoutConstraint.activate([
            
            self.contactNameLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.contactNameLabel.widthAnchor.constraint(equalToConstant: 350),
            self.contactNameLabel.heightAnchor.constraint(equalToConstant: 40),
            self.contactNameLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            
            self.contactNameField.topAnchor.constraint(equalTo: self.contactNameLabel.bottomAnchor, constant: 20),
            self.contactNameField.widthAnchor.constraint(equalToConstant: 350),
            self.contactNameField.heightAnchor.constraint(equalToConstant: 40),
            self.contactNameField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            
            self.contactNumberLabel.topAnchor.constraint(equalTo: self.contactNameField.bottomAnchor, constant: 20),
            self.contactNumberLabel.widthAnchor.constraint(equalToConstant: 350),
            self.contactNameLabel.heightAnchor.constraint(equalToConstant: 40),
            self.contactNumberLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            
            self.contactNumberField.topAnchor.constraint(equalTo: self.contactNumberLabel.bottomAnchor, constant: 20),
            self.contactNumberField.widthAnchor.constraint(equalToConstant: 350),
            self.contactNumberField.heightAnchor.constraint(equalToConstant: 40),
            self.contactNumberField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            
            self.submitButton.topAnchor.constraint(equalTo: self.contactNumberField.bottomAnchor, constant: 20),
            self.submitButton.widthAnchor.constraint(equalToConstant: 350),
            self.submitButton.heightAnchor.constraint(equalToConstant: 40),
            self.submitButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            
        ])
    }
    
    @objc func submitAction()
    {
        let (code, message) = self.validateInput(
            contactName: self.contactNameField.text,
            contactNumber: self.contactNumberField.text
        )
        
        if (code == 200)
        {
            guard let contactName = self.contactNameField.text,
                  let contactNumber = self.contactNumberField.text
            else { return }
            
            guard let contact = self.contact
            // For creating a contact
            else {
                self.delegate?.receiveContact(
                    nil,
                    contactID: self.generateID(),
                    contactName: contactName,
                    contactNumber: contactNumber
                )
                self.navigationController?.popViewController(animated: true)
                return
            }
            
            self.delegate?.receiveContact(
                contact,
                contactID: nil,
                contactName: contactName,
                contactNumber: contactNumber
            )
            
            self.navigationController?.popViewController(animated: true)
        } else
        {
            self.showToast(message: message)
        }
    }
    
    private func validateInput (contactName name: String?, contactNumber number: String?) -> (Int, String)
    {
        
        guard let contactName = name else
        {
            return (202, "Name is required")
        }
        
        guard let contactNumber = number else
        {
            return (202, "Number is required")
        }
        
        if (contactName.isEmpty && contactNumber.isEmpty)
        {
            return (202, "All the fields are required")
        }
        
        if (notMatches(pattern: "[a-zA-Z/s]{2,}", text: contactName))
        {
            return (203, "Name is invalid, for example, Pen, Notebook")
        }
        
        if (notMatches(pattern: "[0-9]{10}", text: contactNumber))
        {
            return (204, "Phone Number is invalid, for example, 1234567890")
        }
        
        return (200, "All the inputs are perfect")
    }
    
    private func notMatches (pattern: String, text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: text.utf16.count)
            return regex.firstMatch(in: text, range: range) == nil
        } catch {
            return true
        }
    }
    
    private func generateID() -> String
    {
        guard let ID = self.currentID else { return "" }
        return "CX" + String(ID)
    }
    
}

extension ViewController2
{
    func showToast(message: String)
    {
        let label = UILabel()
        label.text = message
        label.clipsToBounds = true
        label.backgroundColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        
        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100),
            label.widthAnchor.constraint(equalToConstant: 300),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        UIView.animate(withDuration: 2, delay: 0, animations: {
            label.layer.cornerRadius = 16
            label.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        })
        { isCompleted in
            label.removeFromSuperview()
        }
        
    }
}
