//: # Header Footer
//: 有很多场景，每个模块需要有标题，而且模块间的标题也是可以复用的，这里便将这部分独立出来。
import UIKit
import DDComponent
import PlaygroundSupport

let collectionViewLayout = UICollectionViewFlowLayout()
let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 600), collectionViewLayout: collectionViewLayout)
collectionView.backgroundColor = UIColor.white

PlaygroundPage.current.liveView = collectionView

let rootComponent = DDCollectionViewRootComponent(collectionView: collectionView)

//: 配置组件
let titlesComponent = TitlesComponent()
titlesComponent.cellModels = [
    TitleModel(title: "Title!"),
    TitleModel(title: "链接只能通过`DDCollectionViewRootComponent`来进行，一旦链接，不能再修改`collectionView`的`dataSource`和`delegate`。")]

//: Header可以简单的通过配置完成
titlesComponent.headerComponent = {
    let header = HeaderComponent()
    header.text = "Header!"
    return header
}()

rootComponent.subComponents = [titlesComponent]
//: [Next](@next)
