//: # Status 状态机
//: 有些场景，比如网络请求，在请求过程中，模块位置需要显示loading，而在请求失败需要显示fail，请求内容为空需要显示null，完全正常才显示内容，这时候就需要状态机来控制各种状态了。
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

//: 这里演示一个简单的状态切换，模拟一个请求

let statusComponent = DDCollectionViewStatusComponent()
statusComponent.setComponent({
    let loadingComponent = TitlesComponent()
    loadingComponent.cellModels = [TitleModel(title: "loading")]
    loadingComponent.size = CGSize(width: DDComponentAutomaticDimension, height: DDComponentAutomaticDimension)
    return loadingComponent
}(), forState: "loading")
statusComponent.setComponent(titlesComponent, forState: "normal")
statusComponent.currentState = "normal"

var loading = true
Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
    loading = !loading
    statusComponent.currentState = loading ? "loading" : "normal"
    print("current state \(statusComponent.currentState)")
//: 数据源变更时需要reloadData
    collectionView.reloadData()
}

rootComponent.subComponents = [statusComponent]

//: [Next](@next)
