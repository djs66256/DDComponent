// MIT License
//
// Copyright (c) 2016 Daniel (djs66256@163.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

class TaobaoEntriesComponent: DDCollectionViewHeaderFooterSectionComponent {
    
    var entries: [String] = []
    
    override init() {
        super.init()
        self.itemSpacing = 10
        self.lineSpacing = 10
        self.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    override func prepareCollectionView() {
        super.prepareCollectionView()
        
        self.collectionView?.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: "TaobaoEntries")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaobaoEntries", for: indexPath) as? TitleCollectionViewCell
        cell?.titleLabel.text = self.entries[indexPath.item]
        cell?.titleLabel.font = UIFont.systemFont(ofSize: 12)
        cell?.titleLabel.textAlignment = .center
        cell?.backgroundColor = UIColor.cyan
        
        let width = (collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right - 4*self.itemSpacing) / 5
        cell?.layer.cornerRadius = width / 2
        cell?.clipsToBounds = true
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right - 4*self.itemSpacing) / 5
        return CGSize(width: width, height: width)
    }
}
