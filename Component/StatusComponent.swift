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

enum Status: String {
    case error = "error"
    case normal = "normal"
    case noData = "noData"
    case loading = "loading"
}

class StatusComponent: DDCollectionViewStatusComponent {
    var state: Status? {
        get {
            if self.currentState != nil {
                return Status(rawValue: self.currentState!)
            }
            else {
                return nil
            }
        }
        set {
            self.currentState = newValue?.rawValue
        }
    }
    
    static func component(normalComponent: DDCollectionViewBaseComponent?) -> StatusComponent {
        let status = StatusComponent()
        status.setComponent(StateComponent(text: "Loading...", color:UIColor.yellow), forState: Status.loading.rawValue)
        status.setComponent(StateComponent(text: "Error!", color:UIColor.red), forState: Status.error.rawValue)
        status.setComponent(StateComponent(text: "noData", color:UIColor.green), forState: Status.noData.rawValue)
        status.setComponent(normalComponent, forState: Status.normal.rawValue)
        return status
    }
}

class HeaderFooterStatusComponent: DDCollectionViewHeaderFooterStatusComponent {
    var state: Status? {
        get {
            if self.currentState != nil {
                return Status(rawValue: self.currentState!)
            }
            else {
                return nil
            }
        }
        set {
            self.currentState = newValue?.rawValue
        }
    }
    
    static func component(normalComponent: DDCollectionViewBaseComponent?) -> HeaderFooterStatusComponent {
        let status = HeaderFooterStatusComponent()
        status.setComponent(StateComponent(text: "Loading...", color:UIColor.yellow), forState: Status.loading.rawValue)
        status.setComponent(StateComponent(text: "Error!", color:UIColor.red), forState: Status.error.rawValue)
        status.setComponent(StateComponent(text: "noData", color:UIColor.green), forState: Status.noData.rawValue)
        status.setComponent(normalComponent, forState: Status.normal.rawValue)
        return status
    }
}

class StateComponent: DDCollectionViewHeaderFooterSectionComponent {
    var stateString = ""
    var stateColor = UIColor.black
    
    init(text: String, color: UIColor) {
        super.init()
        self.stateColor = color
        self.stateString = text
        self.size = CGSize(width: DDComponentAutomaticDimension, height: 100)
        self.sectionInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15);
    }
    
    override func prepareCollectionView() {
        super.prepareCollectionView()
        self.collectionView?.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TitleCollectionViewCell.self)+"Status")
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TitleCollectionViewCell.self)+"Status", for: indexPath) as? TitleCollectionViewCell
        cell?.titleLabel.text = self.stateString
        cell?.titleLabel.textColor = self.stateColor
        cell?.titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        cell?.titleLabel.textAlignment = .center
        cell?.backgroundColor = UIColor.lightGray
        return cell!
    }
}
