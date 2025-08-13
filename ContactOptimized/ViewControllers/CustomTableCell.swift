import UIKit

class CustomTableCell: UITableViewCell
{
    open var profileImage: UIImageView? = {
        let profileImage = UIImageView()
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        return profileImage
    }()
    
    open var contentLabel: UILabel? = {
        let contentLabel = UILabel()
        
        contentLabel.font = .systemFont(ofSize: 16, weight: .bold)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.font = .systemFont(ofSize: 16, weight: .bold)
        contentLabel.numberOfLines = 2
        
        return contentLabel
    }()
    
    open var deleteButton: UIButton? = {
        let deleteButton = UIButton()
        
        let configurations = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        deleteButton.setImage(UIImage(systemName: "minus.circle", withConfiguration: configurations), for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        return deleteButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUIs(_ firstLetter: String)
    {
        let configurations = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let image = UIImage(systemName: "\(firstLetter.lowercased()).circle.fill", withConfiguration: configurations)
        
        guard let profile = profileImage,
              let label = contentLabel,
              let delete = deleteButton else { return }
        
        contentView.addSubview(profile)
        profile.image = image
        contentView.addSubview(label)
        contentView.addSubview(delete)
        
        self.setConstraints()
    }
    
    private func setConstraints()
    {
        
        guard let profile = profileImage,
              let label = contentLabel,
              let delete = deleteButton else { return }
        
        NSLayoutConstraint.activate([
            
            profile.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profile.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profile.widthAnchor.constraint(equalToConstant: 60),
            profile.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            label.leadingAnchor.constraint(equalTo: profile.trailingAnchor, constant: 30),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.widthAnchor.constraint(equalToConstant: 200),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            delete.leadingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -50),
            delete.widthAnchor.constraint(equalToConstant: 50),
            delete.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            delete.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
        ])
    }
    
    public func configure(_ contact: Contact)
    {
        let firstLetter = getFirstLetter(contact.name)
        
        self.setUIs(firstLetter)
        
        self.contentLabel?.text = contact.toString()
    }
    
    private func getFirstLetter(_ name: String) -> String
    {
        return String(name[name.startIndex])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.profileImage?.image = nil
        self.contentLabel?.text = nil
        
        self.contentLabel = nil
        self.deleteButton = nil
    }
    
}
