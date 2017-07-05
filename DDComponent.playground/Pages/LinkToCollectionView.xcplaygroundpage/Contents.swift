//: # 链接`UICollectionView`
//: 可以链接至任意的`UICollectionView`，一旦链接后不能再手动修改`collectionView`的`dataSource`和`delegate`。
//: 链接的collectionViewLayout必须是`UICollectionViewFlowLayout`及其子类，和IGList一样，我们这套方案都是按照FlowLayout来实现的。
//: `UIScrollDelegate`仍然会按照原来的`delegate`设置回调。

import UIKit
import DDComponent
import PlaygroundSupport

let collectionViewLayout = UICollectionViewFlowLayout()
let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 600), collectionViewLayout: collectionViewLayout)
collectionView.backgroundColor = UIColor.white

PlaygroundPage.current.liveView = collectionView


//: # Link
//: 链接只能通过`DDCollectionViewRootComponent`来进行，一旦链接，不能再修改`collectionView`的`dataSource`和`delegate`。

let rootComponent = DDCollectionViewRootComponent(collectionView: collectionView)

//: # 配置组件

let titlesComponent = TitlesComponent()
titlesComponent.cellModels = [
    TitleModel(title: "Title!"),
    TitleModel(title: "链接只能通过`DDCollectionViewRootComponent`来进行，一旦链接，不能再修改`collectionView`的`dataSource`和`delegate`。")]

rootComponent.subComponents = [titlesComponent]
