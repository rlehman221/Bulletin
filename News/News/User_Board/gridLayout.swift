//
//  gridLayout.swift
//  News
//
//  Created by Ryan Lehman on 5/29/18.
//
/* Details:
 Need to get back to!
 */
import UIKit
import Foundation
class GridLayout: UICollectionViewFlowLayout {
    
    private var numberOfColumns: Int = 2
    
    init(numberOfColumns: Int) {
        super.init()
        minimumLineSpacing = 5
        minimumInteritemSpacing = 5
        
        self.numberOfColumns = numberOfColumns
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var itemSize: CGSize {
        get {
            if let collectionView = collectionView {
                let itemWidth: CGFloat = (collectionView.frame.width/CGFloat(self.numberOfColumns)) - self.minimumInteritemSpacing
                let itemHeight: CGFloat = 100.0
                return CGSize(width: itemWidth, height: itemHeight)
            }
            
            // Default fallback
            return CGSize(width: 100, height: 100)
        }
        set {
            super.itemSize = newValue
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        if let collectionView = collectionView {
            return collectionView.contentOffset
        }
        return CGPoint.zero
    }
    
}
