
// EditProfileVC.swift
// CakeShop.2.1
//
// Created by Asadbek Muzaffarov
//
import UIKit

final class EditProfileVC: UIViewController {

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let topHeader = UIView()
    private let backButton = UIButton(type: .custom)
    private let headerTitle = UILabel()

    private let imageContainer = UIView()
    private let profileImageButton = UIButton(type: .custom)
    private let smallPencilButton = UIButton(type: .custom)

    private let cardBackground = UIView()
    private let cardStack = UIStackView()

    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let addressTextView = UITextView()

    private let saveButton = UIButton(type: .system)

    // Keys
    private enum Keys {
        static let firstName = "profile_first_name"
        static let lastName  = "profile_last_name"
        static let address   = "profile_address"
        static let imageData = "profile_image_data"
        static let phone     = "profile_phone" // we will not edit phone here
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        loadSaved()
    }

    // MARK: - Layout
    private func setupLayout() {
        // Scroll
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Top custom header (pink)
        topHeader.translatesAutoresizingMaskIntoConstraints = false
        topHeader.backgroundColor = UIColor(red: 0.93, green: 0.19, blue: 0.54, alpha: 1)
        topHeader.heightAnchor.constraint(equalToConstant: 120).isActive = true
//        topHeader.layer.cornerRadius = 20
//        topHeader.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//        topHeader.clipsToBounds = true

        // Back circular button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.backgroundColor = UIColor(white: 1, alpha: 0.12)
        backButton.layer.cornerRadius = 22
        backButton.setImage(UIImage(named: "chevronBack40x40"), for: .normal)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.text = "Profilni tahrirlash"
        headerTitle.textColor = .white
        headerTitle.font = .systemFont(ofSize: 18, weight: .semibold)

        topHeader.addSubview(backButton)
        topHeader.addSubview(headerTitle)
        contentStack.addArrangedSubview(topHeader)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: topHeader.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: topHeader.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            headerTitle.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            headerTitle.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])

        // Image container
        imageContainer.translatesAutoresizingMaskIntoConstraints = false
        imageContainer.heightAnchor.constraint(equalToConstant: 110).isActive = true
        imageContainer.backgroundColor = .clear
        contentStack.addArrangedSubview(imageContainer)

        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        profileImageButton.layer.cornerRadius = 44
        profileImageButton.clipsToBounds = true
        profileImageButton.layer.borderWidth = 3
        profileImageButton.layer.borderColor = UIColor.white.cgColor
        profileImageButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.addTarget(self, action: #selector(pickImageTapped), for: .touchUpInside)

        smallPencilButton.translatesAutoresizingMaskIntoConstraints = false
        smallPencilButton.setImage(UIImage(systemName: "pencil.circle.fill"), for: .normal)
        smallPencilButton.tintColor = UIColor.systemPink
        smallPencilButton.addTarget(self, action: #selector(pickImageTapped), for: .touchUpInside)

        imageContainer.addSubview(profileImageButton)
        imageContainer.addSubview(smallPencilButton)

        NSLayoutConstraint.activate([
            profileImageButton.centerXAnchor.constraint(equalTo: imageContainer.centerXAnchor),
            profileImageButton.centerYAnchor.constraint(equalTo: imageContainer.centerYAnchor),
            profileImageButton.widthAnchor.constraint(equalToConstant: 88),
            profileImageButton.heightAnchor.constraint(equalToConstant: 88),

            smallPencilButton.topAnchor.constraint(equalTo: profileImageButton.bottomAnchor, constant: -12),
            smallPencilButton.centerXAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: -18),
            smallPencilButton.widthAnchor.constraint(equalToConstant: 32),
            smallPencilButton.heightAnchor.constraint(equalToConstant: 32),
            smallPencilButton.centerXAnchor.constraint(equalTo: profileImageButton.trailingAnchor, constant: -18)

        ])

        // Card with fields
        cardBackground.translatesAutoresizingMaskIntoConstraints = false
        cardBackground.backgroundColor = .white
        cardBackground.layer.cornerRadius = 14
        cardBackground.layer.shadowColor = UIColor.black.cgColor
        cardBackground.layer.shadowOpacity = 0.04
        cardBackground.layer.shadowRadius = 6
        cardBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentStack.addArrangedSubview(cardBackground)

        cardStack.axis = .vertical
        cardStack.spacing = 12
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardBackground.addSubview(cardStack)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 16),
            cardStack.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 12),
            cardStack.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -12),
            cardStack.bottomAnchor.constraint(equalTo: cardBackground.bottomAnchor, constant: -16)
        ])

        // --- FIRST NAME TITLE ---
        let firstNameTitle = UILabel()
        firstNameTitle.text = "Ism *"
        firstNameTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        firstNameTitle.textColor = .secondaryLabel
        cardStack.addArrangedSubview(firstNameTitle)

        // First name field
        firstNameField.placeholder = "Ism *"
        styleTextField(firstNameField)
        cardStack.addArrangedSubview(firstNameField)

        // --- LAST NAME TITLE ---
        let lastNameTitle = UILabel()
        lastNameTitle.text = "Familiya (ixtiyoriy)"
        lastNameTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        lastNameTitle.textColor = .secondaryLabel
        cardStack.addArrangedSubview(lastNameTitle)

        // Last name field
        lastNameField.placeholder = "Familiya (ixtiyoriy)"
        styleTextField(lastNameField)
        cardStack.addArrangedSubview(lastNameField)

        // --- PHONE TITLE ---
        let phoneTitle = UILabel()
        phoneTitle.text = "Telefon raqam"
        phoneTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        phoneTitle.textColor = .secondaryLabel
        cardStack.addArrangedSubview(phoneTitle)

        // Phone wrapper
        let phoneLabel = UILabel()
        phoneLabel.text = UserDefaults.standard.string(forKey: Keys.phone) ?? "+998 90 123 45 67"
        phoneLabel.font = .systemFont(ofSize: 15)
        phoneLabel.textColor = .secondaryLabel
        phoneLabel.numberOfLines = 1
        phoneLabel.layer.cornerRadius = 12
        phoneLabel.layer.masksToBounds = true
        phoneLabel.backgroundColor = UIColor.systemGray6
        phoneLabel.textAlignment = .left
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let phoneWrapper = UIView()
        phoneWrapper.translatesAutoresizingMaskIntoConstraints = false
        phoneWrapper.heightAnchor.constraint(equalToConstant: 48).isActive = true
        phoneWrapper.addSubview(phoneLabel)
        phoneLabel.leadingAnchor.constraint(equalTo: phoneWrapper.leadingAnchor, constant: 12).isActive = true
        phoneLabel.trailingAnchor.constraint(equalTo: phoneWrapper.trailingAnchor, constant: -12).isActive = true
        phoneLabel.centerYAnchor.constraint(equalTo: phoneWrapper.centerYAnchor).isActive = true

        cardStack.addArrangedSubview(phoneWrapper)

        // --- ADDRESS TITLE (already existed) ---
        let addressLabel = UILabel()
        addressLabel.text = "Yetkazib berish manzili (ixtiyoriy)"
        addressLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        addressLabel.textColor = .secondaryLabel
        cardStack.addArrangedSubview(addressLabel)

        addressTextView.translatesAutoresizingMaskIntoConstraints = false
        addressTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        addressTextView.layer.cornerRadius = 12
        addressTextView.layer.borderWidth = 1
        addressTextView.layer.borderColor = UIColor.systemGray5.cgColor
        addressTextView.font = .systemFont(ofSize: 15)
        addressTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        cardStack.addArrangedSubview(addressTextView)

        // Required note
        let requiredNote = UIView()
        requiredNote.translatesAutoresizingMaskIntoConstraints = false
        requiredNote.layer.cornerRadius = 8
        requiredNote.backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.98, alpha: 1)
        requiredNote.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let noteLabel = UILabel()
        noteLabel.numberOfLines = 0
        noteLabel.font = UIFont.systemFont(ofSize: 14)
        noteLabel.textColor = UIColor.systemPink
        noteLabel.text = "* belgilangan maydonlarni to'ldirish majburiy"
        noteLabel.translatesAutoresizingMaskIntoConstraints = false

        requiredNote.addSubview(noteLabel)
        NSLayoutConstraint.activate([
            noteLabel.leadingAnchor.constraint(equalTo: requiredNote.leadingAnchor, constant: 12),
            noteLabel.trailingAnchor.constraint(equalTo: requiredNote.trailingAnchor, constant: -12),
            noteLabel.centerYAnchor.constraint(equalTo: requiredNote.centerYAnchor)
        ])

        cardStack.addArrangedSubview(requiredNote)

        // Save button
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Saqlash", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.layer.cornerRadius = 28
        saveButton.backgroundColor = UIColor.systemPink
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        contentStack.setCustomSpacing(22, after: cardBackground)
        contentStack.addArrangedSubview(saveButton)
        
        saveButton.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor, constant: 24).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor, constant: -24).isActive = true
        // Bottom space after Save button
        let bottomSpacer = UIView()
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacer.heightAnchor.constraint(equalToConstant: 40).isActive = true

        contentStack.addArrangedSubview(bottomSpacer)
    }


    private func styleTextField(_ tf: UITextField) {
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
        tf.borderStyle = .none
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.systemGray5.cgColor
        tf.setLeftPaddingPoints(12)
        tf.font = UIFont.systemFont(ofSize: 15)
    }

    // MARK: - Load / Save
    private func loadSaved() {
        let ud = UserDefaults.standard
        firstNameField.text = ud.string(forKey: Keys.firstName)
        lastNameField.text = ud.string(forKey: Keys.lastName)
        addressTextView.text = ud.string(forKey: Keys.address)
        if let data = ud.data(forKey: Keys.imageData), let img = UIImage(data: data) {
            profileImageButton.setImage(img, for: .normal)
            profileImageButton.imageView?.contentMode = .scaleAspectFill
        } else {
            let placeholder = UIImage(systemName: "person.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
            profileImageButton.setImage(placeholder, for: .normal)
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func pickImageTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            let alert = UIAlertController(title: "Xato", message: "Foto kutubxonaga kira olmadi.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @objc private func saveTapped() {
        // Validate required field: first name
        guard let first = firstNameField.text, !first.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "Xato", message: "Iltimos ism maydonini to'ldiring.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Persist to UserDefaults (phone NOT updated here)
        let ud = UserDefaults.standard
        ud.set(first, forKey: Keys.firstName)
        ud.set(lastNameField.text ?? "", forKey: Keys.lastName)
        ud.set(addressTextView.text ?? "", forKey: Keys.address)
        if let img = profileImageButton.image(for: .normal),
           let data = img.jpegData(compressionQuality: 0.85) {
            ud.set(data, forKey: Keys.imageData)
        }
        ud.synchronize()

        // sample firebase placeholder: you will implement Firestore/Storage later
        // uploadProfileToFirebase(...)

        // show check animation then pop
        showSavedAnimation { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Save animation
    private func showSavedAnimation(completion: @escaping () -> Void) {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.35)
        overlay.alpha = 0
        overlay.isUserInteractionEnabled = false
        view.addSubview(overlay)

        let check = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        check.translatesAutoresizingMaskIntoConstraints = false
        check.tintColor = UIColor.systemGreen
        check.alpha = 0
        view.addSubview(check)

        NSLayoutConstraint.activate([
            check.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            check.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            check.widthAnchor.constraint(equalToConstant: 120),
            check.heightAnchor.constraint(equalToConstant: 120)
        ])

        UIView.animate(withDuration: 0.2, animations: {
            overlay.alpha = 1
            check.alpha = 1
            check.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.35, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
                check.transform = .identity
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIView.animate(withDuration: 0.25, animations: {
                        overlay.alpha = 0
                        check.alpha = 0
                    }, completion: { _ in
                        check.removeFromSuperview()
                        overlay.removeFromSuperview()
                        completion()
                    })
                }
            })
        })
    }
}

// MARK: - Image picker
extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        let chosen = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        if let img = chosen {
            profileImageButton.setImage(img, for: .normal)
            profileImageButton.imageView?.contentMode = .scaleAspectFill
            // save immediately for quick preview
            if let data = img.jpegData(compressionQuality: 0.85) {
                UserDefaults.standard.set(data, forKey: Keys.imageData)
            }
        }
    }
}

// MARK: - Helpers
private extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        leftView = paddingView
        leftViewMode = .always
    }
}















