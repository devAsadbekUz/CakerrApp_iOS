//
//  CategoryHeaderView.swift
//  CakeShop.2.1
//
//  Created by Asadbek Muzaffarov on 17/11/25.
//

import Foundation
import UIKit


// MARK: - Category Header View (Sticky horizontal scrolling categories)


import UIKit

protocol CategoryHeaderViewDelegate: AnyObject {
    func categoryHeaderView(_ view: CategoryHeaderView, didSelectCategoryAt index: Int)
}

final class CategoryHeaderView: UICollectionReusableView {

    static let identifier = "CategoryHeaderView"
    weak var delegate: CategoryHeaderViewDelegate?

    private var collectionView: UICollectionView!
    private var categories: [CategoryItem] = []
    private var selectedIndex: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white

        // Bottom border
        let borderView = UIView()
        borderView.backgroundColor = .systemGray5
        borderView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderView)

        // Horizontal collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    // ⭐ FIX SELF-SIZING WARNING
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutIfNeeded()
        let size = systemLayoutSizeFitting(
            CGSize(width: layoutAttributes.frame.width,
                   height: UIView.layoutFittingCompressedSize.height)
        )
        var newFrame = layoutAttributes.frame
        newFrame.size.height = size.height
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }

    func configure(with categories: [CategoryItem], selectedIndex: Int) {
        self.categories = categories
        self.selectedIndex = selectedIndex
        collectionView.reloadData()

        if selectedIndex < categories.count {
            let indexPath = IndexPath(item: selectedIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }

    func selectCategory(at index: Int) {
        guard index != selectedIndex, index < categories.count else { return }

        let previous = selectedIndex
        selectedIndex = index

        collectionView.reloadItems(at: [
            IndexPath(item: previous, section: 0),
            IndexPath(item: index, section: 0)
        ])

        collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                    at: .centeredHorizontally,
                                    animated: true)
    }
}

extension CategoryHeaderView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as! CategoryCell

        cell.configure(with: categories[indexPath.item],
                       isSelected: indexPath.item == selectedIndex)

        return cell
    }
}

extension CategoryHeaderView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.categoryHeaderView(self, didSelectCategoryAt: indexPath.item)
        selectCategory(at: indexPath.item)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
}





















//protocol CategoryHeaderViewDelegate: AnyObject {
//    func categoryHeaderView(_ view: CategoryHeaderView, didSelectCategoryAt index: Int)
//}
//
//class CategoryHeaderView: UICollectionReusableView {
//    static let identifier = "CategoryHeaderView"
//    weak var delegate: CategoryHeaderViewDelegate?
//    
//    private var collectionView: UICollectionView!
//    private var categories: [CategoryItem] = []
//    private var selectedIndex: Int = 0
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    private func setupViews() {
//        backgroundColor = .white
//        
//        // Add subtle bottom border
//        let borderView = UIView()
//        borderView.backgroundColor = UIColor.systemGray5
//        borderView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(borderView)
//        
//        // Setup horizontal collection view for categories
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumInteritemSpacing = 16
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24)
//        
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = .clear
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
//        addSubview(collectionView)
//        
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            
//            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            borderView.heightAnchor.constraint(equalToConstant: 1)
//        ])
//    }
//    
//    func configure(with categories: [CategoryItem], selectedIndex: Int) {
//        self.categories = categories
//        self.selectedIndex = selectedIndex
//        collectionView.reloadData()
//        
//        // Scroll to selected category
//        if selectedIndex < categories.count {
//            let indexPath = IndexPath(item: selectedIndex, section: 0)
//            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//        }
//    }
//    
//    func selectCategory(at index: Int) {
//        guard index != selectedIndex, index < categories.count else { return }
//        let previousIndex = selectedIndex
//        selectedIndex = index
//        
//        // Reload both cells
//        collectionView.reloadItems(at: [
//            IndexPath(item: previousIndex, section: 0),
//            IndexPath(item: index, section: 0)
//        ])
//        
//        // Scroll to center
//        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
//    }
//}
//
//extension CategoryHeaderView: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return categories.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
//        cell.configure(with: categories[indexPath.item], isSelected: indexPath.item == selectedIndex)
//        return cell
//    }
//}
//
//extension CategoryHeaderView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        delegate?.categoryHeaderView(self, didSelectCategoryAt: indexPath.item)
//        selectCategory(at: indexPath.item)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 80, height: 100)
//    }
//}
