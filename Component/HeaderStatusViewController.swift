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

class HeaderStatusViewController: UICollectionViewController {
    
    lazy var rootComponent: DDCollectionViewRootComponent = {
        let root = DDCollectionViewRootComponent(collectionView: self.collectionView!)
        return root
    }()
    
    let titleModels = [
        TitleModel(title: "Macrotarsomys petteri, Petter's big-footed mouse, is a Malagasy rodent. It is the largest in its genus, with a head and body length of 150 mm (5.9 in) and body mass of 105 g (3.7 oz). The upperparts are brown, darkest in the middle of the back, and the underparts are white to yellowish. The animal has long whiskers, short forelimbs, and long hindfeet. The tail ends in a prominent tuft of long, light hairs. The skull is robust and the molars are low-crowned and cuspidate. The species most resembles, and may be most closely related to, the greater big-footed mouse. The specific name, petteri, honors French zoologist François Petter for his contributions to the study of Malagasy rodents. M. petteri is now found only in southwestern Madagascar's Mikea Forest, which is threatened by human development. Subfossil records indicate that it used to be more widely distributed in southern Madagascar; climatic changes and competition with introduced species may have led to the shift in its distribution. (Full article...)", controllerClass: nil)
    ]
    
    let textModels = [
        TitleModel(title: "The Conservative Party, (governing since 2010 as a senior coalition partner prior to 2015 and as a majority government thereafter) was defending a majority of 12, against the Labour Party. The official opposition is led by Jeremy Corbyn. In order to \"strengthen [her] hand in forthcoming Brexit negotiations,\"[1] May hoped to secure a larger Parliamentary majority for the Conservative Party.", controllerClass: nil),
        TitleModel(title: "Since the previous general election, opinion polls had shown public opinion consistently increase for the Conservatives over Labour. At the beginning of the campaign, the Conservative Party had a 20-point lead, and peaked by 25 points in the early weeks of canvassing. This triggered widespread expectations of a landslide victory, similar to that of 1983 United Kingdom general election. However, in the latter stages of the campaign, their lead began to diminish as Labour Party support surged in the final weeks. Despite the narrowing opinion polls, the election results still came as a surprise for major political commentators.", controllerClass: nil),
        TitleModel(title: "Following the election results, the Conservatives spoke with Democratic Unionist Party (DUP) of Northern Ireland, whose 10 seats could allow for the formation of a minority Conservative government.[2]", controllerClass: nil)
    ]
    
    let imageModels = [
        ImageModel(imageName: "00ffff", controllerClass: nil),
        ImageModel(imageName: "00ff00", controllerClass: nil),
        ImageModel(imageName: "0000ff", controllerClass: nil),
        ImageModel(imageName: "ff00ff", controllerClass: nil),
        ImageModel(imageName: "ff0000", controllerClass: nil),
        ImageModel(imageName: "ffff00", controllerClass: nil),
        ImageModel(imageName: "000000", controllerClass: nil),
        ]
    
    var subComponents: [HeaderFooterStatusComponent]?
    
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "refresh", style: .plain, target: self, action: #selector(onRefresh(sender:)))
        
        let titles = TitlesComponent()
        titles.cellModels = self.titleModels
        
        let texts = TextsComponent()
        texts.cellModels = self.textModels
        
        let images = ImagesComponent()
        images.headerComponent = {
            let header = HeaderComponent()
            header.text = "IMAGE HEADER"
            return header
        }()
        images.footerComponent = {
            let footer = FooterComponent()
            footer.text = "IMAGE FOOTER"
            return footer
        }()
        images.images = self.imageModels
        images.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        subComponents = [
            HeaderFooterStatusComponent.component(normalComponent: titles),
            {
                let status = HeaderFooterStatusComponent.component(normalComponent: texts)
                status.headerComponent = {
                    let header = HeaderComponent()
                    header.text = "TEXT HEADER"
                    return header
                }()
                status.footerComponent = {
                    let footer = FooterComponent()
                    footer.text = "TEXT FOOTER"
                    return footer
                }()
                return status
            }(),
            HeaderFooterStatusComponent.component(normalComponent: images)
        ]
        self.rootComponent.subComponents = subComponents
        
        for comp in subComponents! {
            comp.state = .loading
        }
        self.collectionView?.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.subComponents![0].state = .noData
            self.subComponents![1].state = .normal
            self.subComponents![2].state = .error
            self.collectionView?.reloadData()
        }
        
    }
    
    func onRefresh(sender: Any) {
        for comp in subComponents! {
            comp.state = .loading
        }
        self.collectionView?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.subComponents![0].state = .noData
            self.subComponents![1].state = .normal
            self.subComponents![2].state = .error
            self.collectionView?.reloadData()
        }
    }

}
