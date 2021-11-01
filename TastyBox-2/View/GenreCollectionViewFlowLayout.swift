//
//  GemreCollectionViewFlowLayout.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-10-22.
//

import UIKit

class GenreCollectionViewFlowLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout {
    
    var numlines = 0

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        
        var attributesToReturn = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        for (index, attr) in attributes.enumerated() where attr.representedElementCategory == .cell {
            attributesToReturn[index] = layoutAttributesForItem(at: attr.indexPath) ?? UICollectionViewLayoutAttributes()
        }
        
        return attributesToReturn
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let currentAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes,
              
                let viewWidth = collectionView?.frame.width else {
                    return nil
                }
        
        let sectionInsetsLeft = sectionInsets(at: indexPath.section).left
        
        guard indexPath.item > 0 else {
            currentAttributes.frame.origin.x = sectionInsetsLeft
//            numlines += 1
            return currentAttributes
        }
        
        let prevIndexPath = IndexPath(row: indexPath.item - 1, section: indexPath.section)
       
        guard let prevFrame = layoutAttributesForItem(at: prevIndexPath)?.frame else {
            return nil
        }
        
        let validWidth = viewWidth - sectionInset.left - sectionInset.right
        
        let currentColumnRect = CGRect(x: sectionInsetsLeft, y: currentAttributes.frame.origin.y, width: validWidth, height: currentAttributes.frame.height)
        
        guard prevFrame.intersects(currentColumnRect) else {

            currentAttributes.frame.origin.x = sectionInsetsLeft
//            numlines += 1

            return currentAttributes
        }
        
        let prevItemTailX = prevFrame.origin.x + prevFrame.width
        
        currentAttributes.frame.origin.x = prevItemTailX + minimumInteritemSpacing(at: indexPath.section)
        
        return currentAttributes
    }
    
    private func sectionInsets(at index: Int) -> UIEdgeInsets {
        guard
            let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
        
                return self.sectionInset
            
            }

        return delegate.collectionView?(collectionView, layout: self, insetForSectionAt: index) ?? self.sectionInset

    }
    
    private func minimumInteritemSpacing(at index: Int) -> CGFloat {
        guard
            let collectionView = collectionView,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {

                return self.minimumInteritemSpacing

            }

        return delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: index) ?? self.minimumInteritemSpacing
    }
    

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        
//        // Get the view for the first header
//        let indexPath = IndexPath(row: 0, section: section)
//        
//        if let headerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
//            
//            // Use this view to calculate the optimal size based on the collection view's width
//            return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
//                                                      withHorizontalFittingPriority: .required, // Width is fixed
//                                                      verticalFittingPriority: .fittingSizeLevel) // Height can be as large as needed
//        }
//
//        
//        return CGSize.zero
//        
//    }
}
