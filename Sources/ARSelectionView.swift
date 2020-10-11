//
//  ARSelectionView.swift
//  ARSelectableView
//
//  Created by Rohit Makwana on 03/10/20.
//  Copyright © 2020 Rohit Makwana. All rights reserved.
//

import UIKit

final class ARSelectionView: UIView {

    // MARK: - Declared Variables
    static let DEFAULT_LINE_SPACING: CGFloat = 0
    static let DEFAULT_INTERITEM_SPACING : CGFloat = 0
    private var reseource: (cell: ARSelectableCell?, identifier: String)?
    public var cellDesignOptions = ARCellDesignOptions()
    public var options: ARCollectionLayoutOptions?
    public var alignment: ARSelectionAlignment?

    public var selectionType : ARSelectionType = ARSelectionType.radio {
        didSet {

            let tagLayout = ARTagFlowLayout()
            tagLayout.sectionInset = self.options?.sectionInset ?? UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
            tagLayout.minimumInteritemSpacing = options?.interitemSpacing ?? ARSelectionView.DEFAULT_INTERITEM_SPACING
            tagLayout.minimumLineSpacing = options?.lineSpacing ?? ARSelectionView.DEFAULT_LINE_SPACING
            tagLayout.scrollDirection = options?.scrollDirection ?? .vertical
            if selectionType == .tags {
                if options?.scrollDirection == .horizontal {
                    tagLayout.align = .none
                }
                else {
                    tagLayout.align = self.alignment == .right ? .right : .left
                }
            }
            else {
                tagLayout.align = .none
            }
            self.collectionView.collectionViewLayout = tagLayout
            self.items.forEach { $0.selectionType = self.selectionType }
            self.collectionView.reloadData()
        }
    }

    fileprivate lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.bounces = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(ARSelectableCell.self, forCellWithReuseIdentifier: String(describing: ARSelectableCell.self))
        return cv
    }()


    var items: [ARSelectModel] = [] {
        didSet {
            self.items.forEach { $0.selectionType = self.selectionType }
            self.collectionView.reloadData()
            self.layoutIfNeeded()
        }
    }

    // MARK: - Init Methods
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.addViews()
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func addViews() {

        self.setupCollectionView()
    }

    // MARK: - Hepler Methods
    func setupCollectionView() {

        self.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self

        self.reseource = (cell: ARSelectableCell(), String(describing: ARSelectableCell.self))

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([collectionView.topAnchor.constraint(equalTo: topAnchor),
                                     collectionView.leftAnchor.constraint(equalTo: leftAnchor),
                                     collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
                                     collectionView.rightAnchor.constraint(equalTo: rightAnchor)])
    }

    fileprivate func updateSelection(_ selectItem: ARSelectModel) {

        let status = selectItem.isSelected
        if self.selectionType == .radio {
            self.items.filter { $0.isSelected == true }.forEach { ($0).isSelected = false }
            selectItem.isSelected = !status
        }
        else {
            selectItem.isSelected.toggle()
        }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension ARSelectionView: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = collectionView.dequeueCell(ARSelectableCell.self, indexpath: indexPath) {

            cell.delegate = self
            if let alignment = self.alignment, alignment == .right, self.selectionType != .tags {
                cell.alignment = alignment
            }
            cell.configeCell(self.items[indexPath.row], designOptions: self.cellDesignOptions)
            cell.layoutIfNeeded()
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.updateSelection(self.items[indexPath.row])
    }
}

//MARK:- UICollectionViewDelegateFlowLayout
extension ARSelectionView: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if self.selectionType == .tags {
            guard let cell = reseource?.cell else { return .zero }
            cell.configeCell(self.items[indexPath.row])
            let size = cell.fittingSize
            return CGSize(width: size.width, height: self.cellDesignOptions.rowHeight)
        }
        else {
            if self.options?.scrollDirection == .horizontal {
                return CGSize(width: self.items[indexPath.row].width, height: self.cellDesignOptions.rowHeight)
            }
            else {
                return CGSize(width: self.frame.width, height: self.cellDesignOptions.rowHeight)
            }
        }
    }
}

//MARK:- ARSelectionDelegate
extension ARSelectionView: ARSelectionDelegate {

    func ARSelectionAction(_ selectItem: ARSelectModel) {
        self.updateSelection(selectItem)
    }
}

struct ARCollectionLayoutOptions {
    public let sectionInset: UIEdgeInsets
    public let lineSpacing: CGFloat
    public let interitemSpacing: CGFloat
    public let scrollDirection : UICollectionView.ScrollDirection

    public init(sectionInset: UIEdgeInsets = .zero,
                lineSpacing: CGFloat = ARSelectionView.DEFAULT_LINE_SPACING,
                interitemSpacing: CGFloat = ARSelectionView.DEFAULT_INTERITEM_SPACING,
                scrollDirection: UICollectionView.ScrollDirection = .vertical) {

        self.sectionInset = sectionInset
        self.lineSpacing = lineSpacing
        self.interitemSpacing = interitemSpacing
        self.scrollDirection = scrollDirection
    }
}