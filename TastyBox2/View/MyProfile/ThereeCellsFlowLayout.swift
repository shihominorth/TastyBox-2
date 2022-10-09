//
//  ThereeCellsFlowLayout.swift
//  TastyBox-2
//
//  Created by 北島　志帆美 on 2021-11-11.
//

import UIKit


final class ThereeCellsFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)?
            .reduce(into: [UICollectionViewLayoutAttributes]()) { result, attribute in
                let isFirstCellInColumn: Bool = {
                    if attribute.representedElementCategory != .cell {
                        return false
                    } else if let previousAttribute = result.last,
                              previousAttribute.frame.origin.y + previousAttribute.frame.height >= attribute.frame.origin.y {
                        return false
                    } else {
                        return true
                    }
                }()
                if isFirstCellInColumn {
                    attribute.frame.origin.x = self.sectionInset.left
                }
                result += [attribute]
            }
    }
    
    // ==================================================
    // レイアウト開始時の動きを制御する必要がある場合、上記と合わせて追加する
    // ==================================================
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attribute = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        let isFirstCellInColumn: Bool = {
            if indexPath.item > 1,
               let previousAttribute = super.layoutAttributesForItem(at: IndexPath(item: indexPath.item - 1, section: indexPath.section)),
               previousAttribute.frame.origin.y + previousAttribute.frame.height >= attribute.frame.origin.y {
                return false
            } else {
                return true
            }
        }()
        if isFirstCellInColumn {
            attribute.frame.origin.x = self.sectionInset.left
        }
        
        return attribute
        
    }
    
}
